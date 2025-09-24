#' Access a static snapshot of the medRxiv repository
#'
#' @description [Available for medRxiv only] This function allows users to import
#'   a maintained static snapshot of the medRxiv repository, instead of downloading
#'   a copy from the API, which can become unavailable during peak usage times.
#'   The function dynamically retrieves multiple snapshot parts from the specified
#'   repository and combines them into a single dataframe.
#'
#' @param commit Commit hash or branch name for the snapshot, taken from
#'   https://github.com/yaoxiangli/medrxivr-data. Allows for reproducible searching
#'   by specifying the exact snapshot used to perform the searches. Defaults to
#'   "main", which will return the most recent snapshot from the main branch.
#' @param from_date Optional earliest date of interest ("YYYY-MM-DD" or Date).
#'   If supplied, records with `date` earlier than this are excluded.
#' @param to_date Optional latest date of interest ("YYYY-MM-DD" or Date).
#'   If supplied, records with `date` later than this are excluded.
#'
#' @return A formatted dataframe containing the combined data from the snapshot
#'   parts, with reconstructed `link_page` and `link_pdf` columns.
#' @export
#' @family data-source
mx_snapshot <- function(commit    = "main",
                        from_date = NULL,
                        to_date   = NULL) {
  # tiny internal helper to parse optional date args
  .parse_date_arg <- function(x, nm) {
    if (is.null(x)) return(NULL)
    if (inherits(x, "Date")) return(x)
    if (is.character(x)) {
      d <- as.Date(x)
      if (is.na(d)) stop(sprintf("`%s` must be a valid 'YYYY-MM-DD' or Date.", nm), call. = FALSE)
      return(d)
    }
    stop(sprintf("`%s` must be character 'YYYY-MM-DD' or Date.", nm), call. = FALSE)
  }

  from_date <- .parse_date_arg(from_date, "from_date")
  to_date   <- .parse_date_arg(to_date,   "to_date")

  # Construct the API URL for listing the repository contents
  api_url <- paste0(
    "https://api.github.com/repos/YaoxiangLi/medrxivr-data/contents/",
    "?ref=", commit
  )

  # Get the list of files in the repository using the GitHub API
  response <- tryCatch({
    jsonlite::fromJSON(api_url)
  }, error = function(e) {
    stop("Failed to retrieve file list from GitHub. Please check the commit or branch name.")
  })

  # Filter to find snapshot part files
  part_files <- response$name[grepl("^snapshot_part\\d+\\.csv$", response$name)]
  if (length(part_files) == 0) {
    stop("No snapshot part files found. Please check the commit or branch name.")
  }

  # Base URL for raw files
  base_url <- paste0(
    "https://github.com/YaoxiangLi/medrxivr-data/raw/refs/heads/", commit, "/"
  )

  df_list <- list()

  for (part_file in part_files) {
    url <- paste0(base_url, part_file)

    mx_part <- tryCatch({
      suppressMessages(data.table::fread(url, showProgress = FALSE))
    }, error = function(e) {
      message("Failed to read file: ", part_file)
      NULL
    })

    if (!is.null(mx_part)) {
      # Normalize critical column types to avoid bind_rows() type conflicts
      if ("date" %in% names(mx_part)) {
        # Coerce to character "YYYY-MM-DD" for consistency
        if (inherits(mx_part$date, "IDate")) {
          mx_part[, date := format(as.Date(date), "%Y-%m-%d")]
        } else {
          mx_part[, date := as.character(date)]
        }
      }
      for (nm in c("link", "pdf")) {
        if (nm %in% names(mx_part)) mx_part[[nm]] <- as.character(mx_part[[nm]])
      }
      # store as plain data.frame to keep deps minimal
      df_list[[length(df_list) + 1L]] <- as.data.frame(mx_part, stringsAsFactors = FALSE)
    }
  }

  if (length(df_list) == 0) {
    stop("No data could be loaded from the snapshot part files.")
  }

  # Combine parts (now with harmonized types)
  mx_data <- dplyr::bind_rows(df_list)

  # Optional date filtering (consistent with mx_api_content())
  if (!is.null(from_date) || !is.null(to_date)) {
    # work on a temporary Date vector; keep original `date` column as character
    dvec <- suppressWarnings(as.Date(mx_data$date))
    if (!is.null(from_date)) mx_data <- mx_data[!is.na(dvec) & dvec >= from_date, , drop = FALSE]
    if (!is.null(to_date))   mx_data <- mx_data[!is.na(dvec) & dvec <= to_date, , drop = FALSE]
  }

  # Reconstruct the link_page and link_pdf columns if source columns present
  if ("link" %in% names(mx_data)) mx_data$link_page <- paste0("https://www.medrxiv.org", mx_data$link)
  if ("pdf"  %in% names(mx_data)) mx_data$link_pdf  <- paste0("https://www.medrxiv.org", mx_data$pdf)

  mx_data
}

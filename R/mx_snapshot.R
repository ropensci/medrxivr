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
#'
#' @return A formatted dataframe containing the combined data from the snapshot
#'   parts, with reconstructed `link_page` and `link_pdf` columns.
#' @export
#' @family data-source
mx_snapshot <- function(commit = "main") {
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

  # Get the base URL for the data repository
  base_url <- paste0(
    "https://github.com/YaoxiangLi/medrxivr-data/raw/refs/heads/", commit, "/"
  )
  # Initialize an empty list to store dataframes
  df_list <- list()

  # Try to read each part file and add it to the list
  for (part_file in part_files) {
    url <- paste0(base_url, part_file)

    # Attempt to read the file
    mx_part <- tryCatch({
      suppressMessages(data.table::fread(url, showProgress = FALSE))
    }, error = function(e) {
      message("Failed to read file: ", part_file)
      NULL
    })

    # Add the data to the list if it was successfully read
    if (!is.null(mx_part)) {
      df_list[[length(df_list) + 1]] <- mx_part
    }
  }

  # Combine all the loaded parts into a single dataframe
  if (length(df_list) == 0) {
    stop("No data could be loaded from the snapshot part files.")
  }
  mx_data <- dplyr::bind_rows(df_list)

  # Reconstruct the link_page and link_pdf columns
  mx_data$link_page <- paste0("https://www.medrxiv.org", mx_data$link)
  mx_data$link_pdf <- paste0("https://www.medrxiv.org", mx_data$pdf)

  # Return the combined dataframe
  mx_data
}

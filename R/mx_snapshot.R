#' Access a static snapshot of the medRxiv repository
#'
#' @description [Available for medRxiv only] This function allows users to import
#'   a maintained static snapshot of the medRxiv repository, instead of downloading
#'   a copy from the API, which can become unavailable during peak usage times.
#'   The function reads a manifest-driven snapshot artifact from the package's
#'   GitHub release assets by default.
#'
#' @param commit Deprecated. Only the default value "main" is supported. Use
#'   `manifest_url` to read a specific snapshot manifest.
#' @param from_date Optional earliest date of interest ("YYYY-MM-DD" or Date).
#'   If supplied, records with `date` earlier than this are excluded.
#' @param to_date Optional latest date of interest ("YYYY-MM-DD" or Date).
#'   If supplied, records with `date` later than this are excluded.
#' @param manifest_url URL for a JSON snapshot manifest. Defaults to option
#'   `medrxivr.snapshot_manifest`, or the package's latest GitHub release
#'   manifest if that option is unset.
#' @param cache Logical. If TRUE, downloaded manifest snapshot files are cached
#'   between sessions. Defaults to TRUE.
#'
#' @return A formatted dataframe containing the data from the snapshot artifact,
#'   with reconstructed `link_page` and `link_pdf` columns.
#' @export
#' @family data-source
mx_snapshot <- function(commit    = "main",
                        from_date = NULL,
                        to_date   = NULL,
                        manifest_url = default_snapshot_manifest_url(),
                        cache = TRUE) {
  if (!identical(commit, "main")) {
    stop("`commit` is no longer supported. Use `manifest_url` for a specific snapshot manifest.", call. = FALSE)
  }

  from_date <- parse_snapshot_date(from_date, "from_date")
  to_date <- parse_snapshot_date(to_date, "to_date")

  if (is.null(manifest_url) || !nzchar(manifest_url)) {
    stop("`manifest_url` must point to a snapshot manifest.", call. = FALSE)
  }

  mx_data <- suppressWarnings(read_snapshot_manifest_data(manifest_url, cache = cache))
  mx_data <- filter_snapshot_dates(mx_data, from_date, to_date)
  mx_data <- reconstruct_snapshot_links(mx_data)

  inform_snapshot_date(mx_data)

  mx_data
}

default_snapshot_manifest_url <- function() {
  getOption(
    "medrxivr.snapshot_manifest",
    "https://github.com/ropensci/medrxivr/releases/download/snapshot/snapshot-manifest.json"
  )
}

parse_snapshot_date <- function(x, nm) {
  if (is.null(x)) return(NULL)
  if (inherits(x, "Date")) return(x)
  if (is.character(x)) {
    date_value <- as.Date(x)
    if (is.na(date_value)) {
      stop(sprintf("`%s` must be a valid 'YYYY-MM-DD' or Date.", nm), call. = FALSE)
    }
    return(date_value)
  }

  stop(sprintf("`%s` must be character 'YYYY-MM-DD' or Date.", nm), call. = FALSE)
}

read_snapshot_manifest_data <- function(manifest_url, cache = TRUE) {
  manifest <- jsonlite::fromJSON(manifest_url, simplifyVector = FALSE)
  files <- snapshot_manifest_files(manifest)
  urls <- cache_snapshot_files(files, cache = cache)

  read_snapshot_files(urls)
}

snapshot_manifest_files <- function(manifest) {
  files <- manifest$files
  if (is.null(files)) {
    stop("Snapshot manifest must contain a `files` entry.", call. = FALSE)
  }

  files <- as.data.frame(files, stringsAsFactors = FALSE)
  required <- c("name", "url")
  missing <- setdiff(required, names(files))
  if (length(missing)) {
    stop("Snapshot manifest files must contain `name` and `url`.", call. = FALSE)
  }

  files[required]
}

cache_snapshot_files <- function(files, cache = TRUE) {
  if (!isTRUE(cache)) {
    return(files$url)
  }

  cache_dir <- file.path(tools::R_user_dir("medrxivr", "cache"), "snapshots")
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)

  vapply(seq_len(nrow(files)), function(i) {
    dest <- file.path(cache_dir, basename(files$name[i]))
    if (!file.exists(dest)) {
      utils::download.file(files$url[i], destfile = dest, mode = "wb", quiet = TRUE)
    }
    dest
  }, character(1))
}

read_snapshot_files <- function(urls) {
  df_list <- lapply(urls, function(url) {
    mx_part <- read_snapshot_file(url)
    normalize_snapshot_part(mx_part)
  })

  dplyr::bind_rows(df_list)
}

read_snapshot_file <- function(url) {
  if (grepl("[.]gz$", url)) {
    if (grepl("^https?://", url)) { # nocov start
      con <- gzcon(base::url(url, open = "rb"))
    } else { # nocov end
      con <- gzfile(url, open = "rt")
    }
    on.exit(close(con), add = TRUE)
    return(utils::read.csv(con, stringsAsFactors = FALSE))
  }

  suppressMessages(data.table::fread(url, showProgress = FALSE))
}

normalize_snapshot_part <- function(mx_part) {
  mx_part <- as.data.frame(mx_part, stringsAsFactors = FALSE)

  if ("date" %in% names(mx_part)) {
    mx_part$date <- format(as.Date(mx_part$date), "%Y-%m-%d")
  }
  for (nm in c("link", "pdf")) {
    if (nm %in% names(mx_part)) mx_part[[nm]] <- as.character(mx_part[[nm]])
  }

  mx_part
}

filter_snapshot_dates <- function(mx_data, from_date = NULL, to_date = NULL) {
  if (!is.null(from_date) || !is.null(to_date)) {
    dvec <- suppressWarnings(as.Date(mx_data$date))
    keep <- !is.na(dvec)
    if (!is.null(from_date)) keep <- keep & dvec >= from_date
    if (!is.null(to_date))   keep <- keep & dvec <= to_date
    mx_data <- mx_data[keep, , drop = FALSE]
  }

  mx_data
}

reconstruct_snapshot_links <- function(mx_data) {
  if ("link" %in% names(mx_data)) {
    mx_data$link_page <- paste0(rep("https://www.medrxiv.org", length(mx_data$link)), mx_data$link)
  }
  if ("pdf" %in% names(mx_data)) {
    mx_data$link_pdf <- paste0(rep("https://www.medrxiv.org", length(mx_data$pdf)), mx_data$pdf)
  }

  mx_data
}

#' Report the latest record date in a snapshot
#'
#' @param data Snapshot data frame
#'
#' @return Invisibly returns the latest snapshot date
#' @keywords internal

inform_snapshot_date <- function(data) {
  if (!"date" %in% names(data)) {
    return(invisible(NA))
  }

  dates <- suppressWarnings(as.Date(data$date))
  if (!any(!is.na(dates))) {
    return(invisible(NA))
  }

  latest_date <- max(dates, na.rm = TRUE)

  if (is.finite(latest_date)) {
    message("Snapshot includes records through ", latest_date)
  }

  invisible(latest_date)
}

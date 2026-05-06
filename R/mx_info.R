#' Provide information on the medRxiv snapshot used to perform the search
#'
#' @param commit Commit hash for the legacy snapshot repository. Defaults to
#'   "main".
#' @param manifest_url URL for a JSON snapshot manifest. Defaults to option
#'   `medrxivr.snapshot_manifest`, or the package's snapshot release manifest if
#'   that option is unset.
#' @keywords internal
#' @return Message with snapshot details

mx_info <- function(commit = "main",
                    manifest_url = getOption(
                      "medrxivr.snapshot_manifest",
                      "https://github.com/ropensci/medrxivr/releases/download/snapshot/snapshot-manifest.json"
                    )) {
  manifest_time <- tryCatch({
    manifest <- suppressWarnings(jsonlite::fromJSON(manifest_url, simplifyVector = FALSE))
    manifest$snapshot_date
  }, error = function(e) NULL)

  if (!is.null(manifest_time) && length(manifest_time) && nzchar(manifest_time)) {
    message("Using medRxiv snapshot - ", manifest_time)
    return(invisible(manifest_time))
  }

  current_time <- readLines(paste0(
    "https://raw.githubusercontent.com/",
    "YaoxiangLi/",
    "medrxivr-data/",
    commit,
    "/timestamp.txt"
  ))

  mess <- paste0(
    "Using medRxiv snapshot - ",
    current_time
  )
  message(mess)
  invisible(current_time)
}

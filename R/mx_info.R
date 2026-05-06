#' Provide information on the medRxiv snapshot used to perform the search
#'
#' @param commit Deprecated. Only the default value "main" is supported. Use
#'   `manifest_url` to read a specific snapshot manifest.
#' @param manifest_url URL for a JSON snapshot manifest. Defaults to option
#'   `medrxivr.snapshot_manifest`, or the package's snapshot release manifest if
#'   that option is unset.
#' @keywords internal
#' @return Message with snapshot details

mx_info <- function(commit = "main",
                    manifest_url = default_snapshot_manifest_url()) {
  if (!identical(commit, "main")) {
    stop("`commit` is no longer supported. Use `manifest_url` for a specific snapshot manifest.", call. = FALSE)
  }

  manifest <- suppressWarnings(jsonlite::fromJSON(manifest_url, simplifyVector = FALSE))
  manifest_time <- manifest$snapshot_date

  if (!is.null(manifest_time) && length(manifest_time) && nzchar(manifest_time)) {
    message("Using medRxiv snapshot - ", manifest_time)
    return(invisible(manifest_time))
  }

  stop("Snapshot manifest must contain a `snapshot_date` entry.", call. = FALSE)
}

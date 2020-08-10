#' Provide information on the snapshot used to perform the search
#'
#' @param commit Commit hash for the snapshot, taken from
#'   https://github.com/mcguinlu/medrxivr-data. Defaults to "master", which will
#'   return info on the most recent snapshot.
#' @keywords internal
#' @return Message with snapshot details
#'
#' @examples
#' \dontrun{
#' mx_info()
#' }
#'
mx_info <- function(commit = "master") {
  current_time <- readLines(paste0(
    "https://raw.githubusercontent.com/",
    "mcguinlu/",
    "medrxivr-data/",
    commit,
    "/timestamp.txt"
  ))

  mess <- paste0(
    "Using medRxiv snapshot - ",
    current_time
  )
  message(mess)
}

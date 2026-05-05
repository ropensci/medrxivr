#' Provide information on the medRxiv snapshot used to perform the search
#'
#' @param commit Commit hash for the snapshot, taken from
#'   https://github.com/YaoxiangLi/medrxivr-data. Defaults to "main", which will
#'   return info on the most recent snapshot.
#' @keywords internal
#' @return Message with snapshot details

mx_info <- function(commit = "main") {
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
}

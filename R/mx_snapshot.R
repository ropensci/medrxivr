#' Access a static snapshot of the medRxiv repository
#'
#' @description [Available for medRxiv only] Rather than downloading a copy of
#'   the medRxiv database from the API, which can become unavailable at peak
#'   usage times, this allows users to import a maintained static snapshot of
#'   the medRxiv repository.
#'
#' @param commit Commit hash for the snapshot, taken from
#'   https://github.com/mcguinlu/medrxivr-data. Allows for reproducible
#'   searching by specifying the exact snapshot used to perform the searches.
#'   Defaults to "master", which will return the most recent snapshot.
#'
#' @return Formatted dataframe
#' @export
#' @family data-source
#' @examples
#' \donttest{
#' mx_data <- mx_snapshot()
#' }
#'
mx_snapshot <- function(commit = "master") {
  mx_info(commit)

  mx_data <- suppressMessages(vroom::vroom(
    paste0(
      "https://raw.githubusercontent.com/",
      "/mcguinlu/medrxivr-data/", commit, "/snapshot.csv"
    ),
    delim = ",",
    progress = FALSE
  ))

  mx_data$link_page <- paste0("https://www.medrxiv.org", mx_data$link)
  mx_data$link_pdf <- paste0("https://www.medrxiv.org", mx_data$pdf)

  mx_data
}

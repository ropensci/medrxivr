#' Live check against medRxiv
#' @description Cross-check whether the dataset you are using is current
#' @examples
#' \dontrun{
#' mx_crosscheck()
#' }
#' @family helper
#' @export

mx_crosscheck <- function() {
  mx_info()

  # Get number of unique records in the medRxiv archive ---------------------

  base_link <- api_link("medrxiv", "2019-01-01", as.character(Sys.Date()), "0")

  details <- api_to_df(base_link)

  reference <- details$messages[1, 6]

  # Get number of unique records extracted ----------------------------------
  data <- suppressMessages(mx_search(mx_snapshot(), query = "*", deduplicate = FALSE))

  extracted <- nrow(data)

  diff <- reference - extracted

  if (identical(reference, extracted) == TRUE) {
    message("No records added/updated since last snapshot.")
  } else {
    message(paste0(
      diff,
      " new record(s) added/updated since last snapshot"
    ))
  }
}

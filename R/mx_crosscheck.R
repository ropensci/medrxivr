#' Live check against medRxiv
#' @description Cross-check whether the dataset you are using is current
#' @examples \dontrun{
#' mx_crosscheck()
#' }
#' @family helper
#' @export

mx_crosscheck <- function(){

  mx_info()


# Get number of unique records in the medRxiv archive ---------------------

  page <- xml2::read_html("https://www.medrxiv.org/archive")

  page_no <- page %>%
    rvest::html_nodes(".pager-last a") %>%
    rvest::html_text()

  page_no <- as.numeric(page_no)-1 # Important as offset by one!

  page <-
    xml2::read_html(
      paste0(
        "https://www.medrxiv.org/",
        "archive?field_highwire_a_epubdate_value%5Bvalue%5D&page=",
        page_no
      )
    )

  tmp <- page %>%
    rvest::html_nodes(".highwire-cite-linked-title") %>%
    rvest::html_attr('href') %>%
    data.frame(stringsAsFactors = FALSE)

  reference <- length(tmp$.) + (page_no)*10


# Get number of unique records extracted ----------------------------------

  data <- suppressMessages(mx_search(query = "*"))

  extracted <- as.numeric(length(unique(data$doi)))

  diff <- reference-extracted

  if (identical(reference,extracted)==TRUE) {
    message("No new records added to medRxiv since last snapshot.")
  } else {
    message(paste0(diff,
                   " new record(s) added to medRxiv since last snapshot"))
  }
}

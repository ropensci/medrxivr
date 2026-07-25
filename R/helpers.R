#' Checks whether the user has internet, and returns a helpful message it not.
#'
#' @return Informative error if not connected to the internet
#' @keywords internal

internet_check <- function() {
  if (!isTRUE(curl::has_internet())) { # nocov start
    stop(paste0(
      "No internet connection detected - ",
      "please connect to the internet and try again"
    ), call. = FALSE)
  } # nocov end
}

validate_flag <- function(x, name) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    stop(sprintf("`%s` must be TRUE or FALSE.", name), call. = FALSE)
  }

  invisible(x)
}

#' Convert API data to data frame
#'
#' @param url API endpoint from which to extract and format data
#'
#' @return Raw API data in a dataframe
#' @keywords internal
#'
#' @importFrom dplyr %>%

api_to_df <- function(url) { # nocov start
  details <- httr::RETRY(
    verb = "GET",
    times = 3,
    url = url,
    httr::timeout(30)
  )

  httr::stop_for_status(
    details,
    task = paste(
      "extract data from API. As this is usually due to current user load,",
      "please try again in a little while, or use the maintained",
      "static snapshot (available for medRxiv only)"
    )
  )

  code <- details$status_code

  message <- httr::content(details, as = "text", encoding = "UTF-8")

  if (code == 200 &
    message == "Error : (2002) Connection refused") { # nocov start
    stop(paste(
      "API connection refused.",
      "As this is usually due to current user load,",
      "please try again in a little while, or use the maintained",
      "static snapshot (available for medRxiv only)"
    ))
  } # nocov end

  # Extract cursor from url and check if first page is empty This causes an
  # error only if the very first page, indicated by cursor == "0", is empty.
  # This approach allows for elegant handling of the discrepancy between the
  # expected total number of records as per the metadata and the actual number
  # available, while maintaining the informative error if the first page is
  # empty.
  cursor <-
    stringr::str_split(url, "/") %>%
    unlist() %>%
    dplyr::last()

  if (code == 200 & grepl("no posts found", message) & cursor == "0") {
    stop(paste(
      "No records found. Please double check your date range,",
      "as this is the usual cause of this error."
    ))
  }

  details <- details %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
} # nocov end

#' Create link for API
#'
#' @param ... Arguments to specify the path to the API endpoint
#'
#' @return Formatted link to API endpoint
#' @keywords internal

api_link <- function(...) {
  path_arg <- c(...)

  httr::modify_url("https://api.biorxiv.org/",
    path = c(
      "details",
      path_arg
    )
  )
}

#' Extract the total number of records from API metadata
#'
#' @param messages API metadata messages data frame
#'
#' @return Numeric record count
#' @keywords internal

api_record_count <- function(messages) {
  count <- api_metadata_number(messages, "total")

  if (!is.finite(count) || is.na(count)) {
    count <- api_metadata_number(messages, "count")
  }

  count
}

#' Extract the page size from API metadata
#'
#' @param messages API metadata messages data frame
#'
#' @return Numeric page size
#' @keywords internal

api_page_size <- function(messages) {
  page_size <- api_metadata_number(messages, "count")

  if (!is.finite(page_size) || is.na(page_size) || page_size < 1L) {
    page_size <- 100L
  }

  page_size
}

api_metadata_number <- function(messages, column) {
  if (!column %in% names(messages) || nrow(messages) < 1L) {
    return(NA_real_)
  }

  suppressWarnings(as.numeric(messages[[column]][1]))
}

#' Helper script to clean data from API to make it compatible with mx_search()
#'
#' @param df Raw dataframe from API
#'
#' @return Cleaned dataframe
#' @keywords internal
#'
#' @importFrom dplyr %>%

clean_api_df <- function(df) {
  df$node <- seq_len(nrow(df))

  df <- df %>%
    dplyr::select(-dplyr::all_of("type"))

  if (nrow(df) == 0L) {
    df$link <- character()
    df$pdf <- character()
  } else {
    df$link <- paste0("/content/", df$doi, "v", df$version, "?versioned=TRUE")
    df$pdf <- paste0("/content/", df$doi, "v", df$version, ".full.pdf")
  }
  df$category <- stringr::str_to_title(df$category)
  df$authors <- stringr::str_to_title(df$authors)
  df$author_corresponding <- stringr::str_to_title(df$author_corresponding)

  if (nrow(df) == 0L) {
    df$link_page <- character()
    df$link_pdf <- character()
  } else {
    df$link_page <- paste0("https://www.", df$server, ".org", df$link)
    df$link_pdf <- paste0("https://www.", df$server, ".org", df$pdf)
  }

  df <- df %>%
    dplyr::select(-dplyr::all_of(c("server", "link", "pdf")))

  df
}


#' Skips API tests if API isn't working correctly
#'
#' @keywords internal

skip_if_api_message <- function() { # nocov start
  details <- httr::RETRY(
    verb = "GET",
    times = 3,
    url = "https://api.biorxiv.org/details/medrxiv/2020-06-21/2020-08-28/45",
    httr::timeout(30)
  )
  code <- details$status_code

  message <- httr::content(details, as = "text", encoding = "UTF-8")

  if (code == 200 & message == "Error : (2002) Connection refused") {
    testthat::skip("API connection refused") # nocov
  }
} # nocov end

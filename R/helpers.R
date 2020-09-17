#' Checks whether the user has internet, and returns a helpful message it not.
#'
#' @return Informative error if not connected to the internet
#' @keywords internal

internet_check <- function() {
  if (curl::has_internet() == FALSE) { # nocov start
    stop(paste0(
      "No internet connect detected - ",
      "please connect to the internet and try again"
    ))
  } # nocov end
}

#' Convert API data to data frame
#'
#' @param url API endpoint from which to extract and format data
#'
#' @return Raw API data in a dataframe
#' @keywords internal
#'
#' @importFrom dplyr %>%

api_to_df <- function(url) {
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
      "static daily snapshot (available for medRxiv only)"
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
      "static daily snapshot (available for medRxiv only)"
    ))
  } # nocov end

  if (code == 200 & grepl("no posts found", message)) {
    stop(paste(
      "No records found. Please double check your date range,",
      "as this is the usual cause of this error."
    ))
  }

  details <- details %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()
}

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
    dplyr::select(-c(.data$type))

  df$link <- paste0("/content/", df$doi, "v", df$version, "?versioned=TRUE")
  df$pdf <- paste0("/content/", df$doi, "v", df$version, ".full.pdf")
  df$category <- stringr::str_to_title(df$category)
  df$authors <- stringr::str_to_title(df$authors)
  df$author_corresponding <- stringr::str_to_title(df$author_corresponding)

  df$link_page <- paste0("https://www.", df$server, ".org", df$link)
  df$link_pdf <- paste0("https://www.", df$server, ".org", df$pdf)

  df <- df %>%
    dplyr::select(-c(.data$server, .data$link, .data$pdf))

  df
}


#' Skips API tests if API isn't working correctly
#'
#' @keywords internal

skip_if_api_message <- function() {
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
}

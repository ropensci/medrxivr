#' Access the Cold Spring Harbour Laboratory API
#'
#' @description Provides programmatic access to all preprints available through
#'   the Cold Spring Harbour Laboratory API, which serves both the medRxiv and
#'   bioRxiv preprint repositories.
#' @param from_date Earliest date of interest. Defaults to 1st June 2019
#'   (earliest medRxiv record was posted on 25th June 2019).
#' @param to_date Latest date of interest. Defaults to current date.
#' @param include.info Logical, indicating whether to include variables
#'   containing information returned by the API (e.g. cursor number, total count
#'   of papers, etc). Default is FALSE.
#' @param server Specify the server you wish to use: "medrxiv" (default) or
#'   "biorxiv"
#' @param clean Logical, indicating whether to clean the data returned for use
#'   with other mx_* functions. Default is TRUE.
#'
#' @return Dataframe with 1 record per row
#'
#' @family data-source
#' @export
#'
#' @examples
#' \dontrun{
#' mx_data <- mx_api_content()
#' }
#' @importFrom dplyr %>%
#' @importFrom rlang .data

mx_api_content <- function(from_date = "2013-01-01",
                           to_date = as.character(Sys.Date()),
                           clean = TRUE,
                           server = "medrxiv",
                           include.info = FALSE) {


  # Check that the user is connected to the internet
  internet_check()

  # Check server

  '%notin%' <- Negate('%in%')

  if (server %notin% c("medrxiv","biorxiv")) {
    stop(paste("Server not recognised -",
    "must be one of \"medrxiv\" or \"biorxiv\""))
  }

  # Get descriptive details and page number
  details_link <- api_link(server, from_date, to_date, "0")

  details <- api_to_df(details_link)

  count <- details$messages[1, 6]
  message("Total number of records found: ", count)
  pages <- floor(count / 100)

  # Create empty dataset
  df <- details$collection %>%
    dplyr::filter(doi == "")

  # Get data
  pb <-
    progress::progress_bar$new(
      format = paste0(
        "Downloading... [:bar] :current/:total ",
        "(:percent) Est. time remaining: :eta"
      ),
      total = count
    )

  pb$tick(0)

  for (cursor in 0:pages) {
    page <- cursor * 100

    page_link <- api_link(server, from_date, to_date, page)

    tmp <- api_to_df(page_link)

    tmp <- tmp$collection

    df <- rbind(df, tmp)

    pb$tick(100)
  }

  # Clean data

  if (clean == TRUE) {
    df <- clean_api_df(df)
  }

  if (include.info == TRUE) {
    details <-
      details$messages %>% dplyr::slice(rep(1:dplyr::n(), each = nrow(df)))
    df <- cbind(df, details)
  }

  df
}


#' Access data on a single record from the Cold Spring Harbour Laboratory API
#'
#' @description Provides programmatic access to data on a single preprint
#'   identified by a unique Digital Object Identifier (DOI).
#' @param doi Digital object identifier of the preprint you wish to retrieve
#'   data on.
#' @param server Specify the server you wish to use: "medrxiv" (default) or
#'   "biorxiv"
#' @param clean Logical, indicating whether to clean the data returned for use
#'   with other mx_* functions.
#'
#' @return Dataframe containing details on the preprint identified by the DOI.
#'
#' @family data-source
#' @export
#'
#' @examples
#' \dontrun{
#' mx_data <- mx_api_doi("10.1101/2020.02.25.20021568")
#' }
#' @importFrom dplyr %>%
#' @importFrom rlang .data

mx_api_doi <- function(doi,
                       server = "medrxiv",
                       clean = TRUE) {

  '%notin%' <- Negate('%in%')

  if (server %notin% c("medrxiv","biorxiv")) {
    stop(paste("Server not recognised -",
               "must be one of \"medrxiv\" or \"biorxiv\""))
  }

  details <- api_to_df(api_link(server, doi))

  df <- details$collection

  # Clean data

  if (clean == TRUE) {
    df <- clean_api_df(df)
  }

  df
}

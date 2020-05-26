#' Access medrxiv API
#'
#' @param from.date Earliest date of interst. Defaults to 1st June 2019
#'   (earliest medRxiv record was posted on 25th June 2019).
#' @param to.date Latest date of interest. Defaults to current date.
#' @param include.info Logical, indicating whether to include variables
#'   containing information returned by the API (e.g. cursor number, total count
#'   of papers, etc). Default is FALSE.
#' @param clean Logical, indicating whether to clean the data returned for use
#'   with other mx_* functions.
#'
#' @return Dataframe with 1 record per row
#'
#' @family api
#' @export
#'
#' @examples \dontrun{
#' mx_data <- mx_api()
#' }
#' @importFrom dplyr %>%

mx_api_content <- function(from.date = "2019-06-01",
                           to.date = Sys.Date(),
                           clean = TRUE,
                           include.info = FALSE) {

# Create baseline link
base_link <- paste0("https://api.biorxiv.org/details/medrxiv/",
               from.date,
               "/",
               to.date)

details <-
  httr::RETRY(
    verb = "GET",
    times = 3,
    url = paste0(base_link, "/0"),
    httr::timeout(30)
  ) %>%
  httr::content(as = "text", encoding = "UTF-8") %>%
  jsonlite::fromJSON()

# Check if API is working?

count <- details$messages[1,6]
message("Total number of records found: ",count)
pages <- floor(count/100)

# Create empty dataset
df <- details$collection %>%
  dplyr::filter(doi == "")



# Get data
message("Starting extraction from API")


for (cursor in 0:pages) {

  page <- cursor*100

  message(paste0("Extracting records ",page+1," to ",page+100, " of ", count))

  link <- paste0(base_link,"/",page)

  tmp <- httr::RETRY(verb = "GET", url = link) %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()

  tmp <- tmp$collection

  df <- rbind(df, tmp)

}

# Clean data

if (clean == TRUE) {


df$node <- seq_len(nrow(df))


df <- df %>%
  dplyr::select(-c(.data$type,.data$server))

df$link <- paste0("/content/",df$doi,"v",df$version,"?versioned=TRUE")
df$pdf <- paste0("/content/",df$doi,"v",df$version,".full.pdf")
df$category <- stringr::str_to_title(df$category)
df$authors <- stringr::str_to_title(df$authors)
df$author_corresponding <- stringr::str_to_title(df$author_corresponding)

}

if (include.info == TRUE) {
  details <-
    details$messages %>% dplyr::slice(rep(1:dplyr::n(), each = nrow(df)))
  df <- cbind(df, details)
}

df

}


#' Access medRxiv API, based on single DOI
#'
#' @param doi Digital object identifier of the preprint you wish to retrieve
#'   data on.
#' @param include.info Logical, indicating whether to include variables
#'   containing information returned by the API (e.g. cursor number, total count
#'   of papers, etc). Default is FALSE.
#' @param clean Logical, indicating whether to clean the data returned for use
#'   with other mx_* functions.
#'
#' @return Dataframe containing details on the preprint identified by the DOI.
#'
#' @family api
#' @export
#'
#' @examples \dontrun{
#' mx_data <- mx_api_doi("10.1101/2020.02.25.20021568")
#' }
#' @importFrom dplyr %>%

mx_api_doi <- function(doi,
                       clean = TRUE){

base_link <- paste0("https://api.biorxiv.org/details/medrxiv/",doi)

details <- httr::RETRY(verb = "GET", url = base_link, httr::timeout(30)) %>%
  httr::content(as = "text", encoding = "UTF-8") %>%
  jsonlite::fromJSON()

df <- details$collection

# Clean data

if (clean == TRUE) {



  df$node <- seq_len(nrow(df))

  df <- df %>%
    dplyr::select(-c(.data$type,.data$server))

  df$link <- paste0("/content/",df$doi,"v",df$version,"?versioned=TRUE")
  df$pdf <- paste0("/content/",df$doi,"v",df$version,".full.pdf")
  df$category <- stringr::str_to_title(df$category)
  df$authors <- stringr::str_to_title(df$authors)
  df$author_corresponding <- stringr::str_to_title(df$author_corresponding)

}

df

}




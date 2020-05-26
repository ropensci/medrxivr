#' Search medRxiv
#' @description Search medRxiv using a string
#' @param data Users can define a dataset they have created themselves using the
#' API (see mx_raw()). The default (data = NULL) is to use a daily static
#' snapshot of the database rather than requerying the API.
#' @param query Character string, vector or list
#' @param fields Fields of the database to search - default is Title, Abstract,
#'   Authors, Category, and DOI.
#' @param from.date Defines earlist date of interest. Written as a number in
#'   format YYYYMMDD. Note, records published on the date specified will also be
#'   returned.
#' @param to.date Defines latest date of interest. Written as a number in
#'   format YYYYMMDD. Note, records published on the date specified will also be
#'   returned.
#' @param NOT Vector of regular expressions to exclude from the search. Default
#'   is NULL.
#' @param deduplicate Logical. Only return the most recent version of a record.
#'   Default is TRUE.
#' @examples \dontrun{
#' mx_results <- mx_raw() %>%
#' mx_search(query = "dementia")
#' }
#' @family main
#' @export
#' @importFrom utils download.file
#' @importFrom utils read.csv
#' @importFrom dplyr %>%


mx_search <- function(data = NULL,
                      query,
                      fields = c("title","abstract","authors","category","doi"),
                      from.date = NULL,
                      to.date = NULL,
                      NOT = "",
                      deduplicate = TRUE
                      ){

  . <- NULL
  node <- NULL
  link_group <- NULL
  doi <- NULL
  link <- NULL



  # Error handling ----------------------------------------------------------

  # Require internet connection
  if (curl::has_internet() == FALSE) {
    stop(paste0(
      "No internet connect detected - ",
      "please connect to the internet and try again"
    ))
  }


  # Search ------------------------------------------------------------------



  # Load data

  if (is.null(data)) {
  # If data argument is NULL use the static snapshot
  # Print information on snapshot being used
  mx_info()

  mx_data <-
    read.csv(

      paste0("https://raw.githubusercontent.com/",
             "/mcguinlu/medrxivr-data/master/snapshot.csv"),

      sep = ",",
      stringsAsFactors = FALSE,
      fileEncoding = "UTF-8",
      header = TRUE
    )
  } else {
    #Alternatively, use the dataset provided (most likely from mx_raw())
    mx_data <- data
  }



  # Implement data limits ---------------------------------------------------


  mx_data$date <- as.numeric(gsub("-", "", mx_data$date))

  if (!is.null(to.date)) {
    mx_data <- mx_data %>% dplyr::filter(date <= to.date)
  }

  if (!is.null(from.date)) {
    mx_data <- mx_data %>% dplyr::filter(date >= from.date)
  }


  # Run search --------------------------------------------------------------


  if (is.list(query)) {
    # General code to find matches

    query_length <- as.numeric(length(query))

    and_list <- list()

    for (list in seq_len(query_length)) {
      tmp <- mx_data %>%
        dplyr::filter_at(dplyr::vars(fields),
                         dplyr::any_vars(grepl(paste(
                           query[[list]],
                           collapse = '|'
                         ), .))) %>%
        dplyr::select(node)
      tmp <- tmp$node
      and_list[[list]] <- tmp
    }

    and <- Reduce(intersect, and_list)

  }

  if (!is.list(query) & is.vector(query)) {
    # General code to find matches
    tmp <- mx_data %>%
      dplyr::filter_at(dplyr::vars(fields),
                       dplyr::any_vars(grepl(paste(query,
                                                   collapse = '|'), .))) %>%
      dplyr::select(node)

    and <- tmp$node

  }

  # Exclude those in the NOT category ---------------------------------------

  if (NOT!="") {
    tmp <- mx_data %>%
      dplyr::filter_at(dplyr::vars(fields),
                       dplyr::any_vars(grepl(paste(NOT,
                                                   collapse = '|'), .))) %>%
      dplyr::select(node)

    `%notin%` <- Negate(`%in%`)

    and <- and[and %notin% tmp$node]

    results <- and

  } else {
    results <- and
  }


  if (length(query) > 1) {
    mx_results <- mx_data[which(mx_data$node %in% results), ]
  } else {
    if (query == "*") {
      mx_results <- mx_data
    } else {
      mx_results <- mx_data[which(mx_data$node %in% results), ]
    }
  }


  # Clean and process results -----------------------------------------------

  if (nrow(mx_results) > 0) {

  names(mx_results)[names(mx_results) == "link"] <- "link_page"
  names(mx_results)[names(mx_results) == "pdf"] <- "link_pdf"
  names(mx_results)[names(mx_results) == "date_posted"] <- "link_pdf"
  names(mx_results)[names(mx_results) == "node"] <- "ID"

  mx_results$link_page <-
      paste0("https://www.medrxiv.org", mx_results$link_page)
  mx_results$link_pdf <-
      paste0("https://www.medrxiv.org", mx_results$link_pdf)


  mx_results <-
    mx_results[, c(
      "ID",
      "title",
      "abstract",
      "authors",
      "date",
      "category",
      "doi",
      "version",
      "author_corresponding",
      "author_corresponding_institution",
      "link_page",
      "link_pdf",
      "license",
      "published"
    )]


  # Deduplicate -------------------------------------------------------------
  if (deduplicate == TRUE) {

    mx_results <- mx_results %>%
      dplyr::group_by(doi) %>%
      dplyr::slice(which.max(version))


    # Post message and return dataframe
    message(paste0(
      "Found ",
      length(mx_results$ID),
      " record(s) matching your search."
    ))

    mx_results

  } else {
    # Post message and return dataframe
    message(
      paste0(
        "Found ",
        length(mx_results$ID),
        " record(s) matching your search.\n",
        "Note, there may be >1 version of the same record."
      )
    )

    mx_results

  }
  } else {
    message("No records found matching your search.")
  }

}



#' Search medRxiv
#' @description Search medRxiv using a string
#' @param query Character string, vector or list
#' @param fields Fields of the database to search - default is Title, Abstract,
#'   First author, Subject, and Link (which includes the DOI)
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
#' mx_results <- mx_search("dementia")
#' }
#' @family main
#' @export
#' @importFrom utils download.file
#' @importFrom utils read.csv
#' @importFrom dplyr %>%


mx_search <- function(query,
                      fields = c("title","abstract","authors","subject","link"),
                      from.date = NULL,
                      to.date = NULL,
                      NOT = "",
                      deduplicate = TRUE
                      ){

  . <- NULL
  node <- NULL
  link_group <- NULL
  or_1 <- NULL
  or_2 <- NULL
  or_3 <- NULL
  or_4 <- NULL
  or_5 <- NULL
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

  # Print information on snapshot being used
  mx_info()

  # Load data
  mx_data <-
    read.csv(
      paste0(
        "https://raw.githubusercontent.com/mcguinlu/",
        "autosynthesis/master/data/",
        "medRxiv_abstract_list.csv"
      ),
      sep = ",",
      stringsAsFactors = FALSE,
      fileEncoding = "UTF-8",
      header = TRUE
    )



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

  colnames(mx_results)[3] <- "link_page"
  colnames(mx_results)[4] <- "link_pdf"
  colnames(mx_results)[5] <- "date_posted"
  colnames(mx_results)[7] <- "first_author"
  colnames(mx_results)[8] <- "link_bibtex"
  colnames(mx_results)[12] <- "ID"

    mx_results$doi <-
      gsub("/content/", "", gsub("v.*", "", mx_results$link_page))
    mx_results$link_page <-
      paste0("https://www.medrxiv.org", mx_results$link_page)
    mx_results$link_pdf <-
      paste0("https://www.medrxiv.org", mx_results$link_pdf)
    mx_results$link_bibtex <-
      paste0("https://www.medrxiv.org", mx_results$link_bibtex)


  mx_results <-
    mx_results[, c(
      "ID",
      "title",
      "abstract",
      "first_author",
      "date_posted",
      "subject",
      "doi",
      "link_page",
      "link_pdf",
      "link_bibtex"
    )]


  # Deduplicate -------------------------------------------------------------
  if (deduplicate == TRUE) {
    mx_results$link_page <- gsub("\\?versioned=TRUE", "", mx_results$link_page)

    mx_results$version <- substr(mx_results$link_page,
                                 nchar(mx_results$link_page),
                                 nchar(mx_results$link_page))

    mx_results$link_group <-
      substr(mx_results$link_page, 1, nchar(mx_results$link_page) - 2)

    mx_results <- mx_results %>%
      dplyr::group_by(link_group) %>%
      dplyr::slice(which.max(version))

    mx_results <- mx_results[1:10]

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



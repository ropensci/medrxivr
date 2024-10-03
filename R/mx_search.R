#' Search preprint data
#' @param data The preprint dataset that is to be searched, created either using
#'   mx_api_content() or mx_snapshot()
#' @param query Character string, vector or list
#' @param fields Fields of the database to search - default is Title, Abstract,
#'   Authors, Category, and DOI.
#' @param from_date Defines earliest date of interest. Written in the format
#'   "YYYY-MM-DD". Note, records published on the date specified will also be
#'   returned.
#' @param to_date Defines latest date of interest. Written in the format
#'   "YYYY-MM-DD". Note, records published on the date specified will also be
#'   returned.
#' @param auto_caps As the search is case sensitive, this logical specifies
#'   whether the search should automatically allow for differing capitalisation
#'   of search terms. For example, when TRUE, a search for "dementia" would find
#'   both "dementia" but also "Dementia". Note, that if your term is multi-word
#'   (e.g. "systematic review"), only the first word is automatically
#'   capitalised (e.g your search will find both "systematic review" and
#'   "Systematic review" but won't find "Systematic Review". Note that this
#'   option will format terms in the query and NOT arguments (if applicable).
#' @param NOT Vector of regular expressions to exclude from the search. Default
#'   is "".
#' @param deduplicate Logical. Only return the most recent version of a record.
#'   Default is TRUE.
#' @param report Logical. Run mx_reporter. Default is FALSE.
#' @examples
#' \donttest{
#' # Using the daily snapshot
#' mx_results <- mx_search(data = mx_snapshot(), query = "dementia")
#' }
#' @family main
#' @export
#' @importFrom utils download.file
#' @importFrom utils read.csv
#' @importFrom dplyr %>%


mx_search <- function(data = NULL,
                      query = NULL,
                      fields = c(
                        "title",
                        "abstract",
                        "authors",
                        "category",
                        "doi"
                      ),
                      from_date = NULL,
                      to_date = NULL,
                      auto_caps = FALSE,
                      NOT = "",
                      deduplicate = TRUE,
                      report = FALSE) {
  # Error handling ----------------------------------------------------------

  # Require search terms
  if (is.null(data)) {
    stop(
      paste0(
        "Please provide preprint data to search, accessed from either ",
        "from either the mx_api_content(), or mx_snapshot() functions."
      )
    )
  }
  # Require search terms
  if (is.null(query)) {
    stop("Please specify search terms in the `query` argument.")
  }

  # Require internet connection
  if (curl::has_internet() == FALSE) { # nocov start
    stop(paste0(
      "No internet connect detected - ",
      "please connect to the internet and try again"
    ))
  } # nocov end


  # Search ------------------------------------------------------------------

  # Load data
  mx_data <- data

  # Implement data limits ---------------------------------------------------
  mx_data$date <- as.numeric(gsub("-", "", mx_data$date))

  if (!is.null(to_date)) {
    to_date <- as.numeric(gsub("-", "", to_date))
    mx_data <- mx_data %>% dplyr::filter(date <= to_date)
  }

  if (!is.null(from_date)) {
    from_date <- as.numeric(gsub("-", "", from_date))
    mx_data <- mx_data %>% dplyr::filter(date >= from_date)
  }


  # Clean query ----------------------------------------------------------------

  # Fix capitalisation
  if (auto_caps == TRUE) {
    query <- fix_caps(query)
    if (NOT[1] != "") {
      NOT <- fix_caps(NOT)
    }
  }

  query <- query %>%
    fix_near() %>%
    fix_wildcard()


  # Run full search  and process results -------------------------------------
  mx_results <- run_search(mx_data, query, fields, deduplicate, NOT)
  num_results <- nrow(mx_results)
  print_full_results(num_results, deduplicate)


  # Run mx_reporter and process results --------------------------------------
  if (report) {
    mx_reporter(mx_data, num_results, query, fields, deduplicate, NOT)
  }

  # Return full search results
  if (num_results > 0) {
    mx_results
  }
}


#' Search and print output for individual search items
#' @param mx_data The mx_dataset filtered for the date limits
#' @param num_results The number of results returned by the overall search
#' @param query Character string, vector or list
#' @param fields Fields of the database to search - default is Title, Abstract,
#'   Authors, Category, and DOI.
#' @param deduplicate Logical. Only return the most recent version of a record.
#'   Default is TRUE.
#' @param NOT Vector of regular expressions to exclude from the search. Default
#'   is "".
#' @family main
mx_reporter <- function(mx_data,
                        num_results,
                        query,
                        fields,
                        deduplicate,
                        NOT) {
  # run mx_search on individual topics, count hits and print message
  for (i in 1:length(query)) {
    ifelse(is.list(query),
      query_i <- query[[i]],
      query_i <- query[i]
    )

    mx_results <- run_search(mx_data, query_i, fields, deduplicate)
    topic_hits <- nrow(mx_results)
    message(cat("\n"), paste0("Total topic ", i, " records: ", topic_hits))

    # run mx_search for and individual terms within each topic,...
    # count hits and print message
    for (j in 1:length(query_i)) {
      mx_results <- run_search(mx_data, query_i[j], fields, deduplicate)
      term_hits <- nrow(mx_results)
      message(paste0(query_i[j], ": ", term_hits))
    }
  }

  if (NOT[1] != "") {
    # Run search excluding not term and subtract num_results
    # This gives number of hits which were excluded by NOT term
    not_hits <-
      nrow(
        run_search(mx_data, query, fields, deduplicate, NOT = "")
      ) - num_results

    message(
      cat("\n"),
      paste0(
        not_hits,
        " records matched by NOT (",
        paste0("'", paste0(NOT, collapse = "' OR '"), "'"),
        ") were excluded."
      )
    )
  }
}


#' Search for terms in the dataset
#' @param mx_data The mx_dataset filtered for the date limits
#' @param query Character string, vector or list
#' @param fields Fields of the database to search - default is Title, Abstract,
#'   Authors, Category, and DOI.
#' @param deduplicate Logical. Only return the most recent version of a record.
#'   Default is TRUE.
#' @param NOT Vector of regular expressions to exclude from the search. Default
#'   is NULL.
#' @family main
#' @importFrom dplyr %>%
run_search <- function(mx_data,
                       query,
                       fields,
                       deduplicate,
                       NOT = "") {
  . <- NULL
  node <- NULL
  link_group <- NULL
  doi <- NULL
  link <- NULL

  if (is.list(query)) {
    # General code to find matches

    query_length <- as.numeric(length(query))

    and_list <- list()

    for (list in seq_len(query_length)) {
      tmp <- mx_data %>%
        dplyr::filter_at(
          dplyr::vars(fields),
          dplyr::any_vars(grepl(paste(
            query[[list]],
            collapse = "|"
          ), .))
        ) %>%
        dplyr::select(node)
      tmp <- tmp$node
      and_list[[list]] <- tmp
    }

    and <- Reduce(intersect, and_list)
  }

  if (!is.list(query) & is.vector(query)) {
    # General code to find matches
    tmp <- mx_data %>%
      dplyr::filter_at(
        dplyr::vars(fields),
        dplyr::any_vars(grepl(paste(query,
          collapse = "|"
        ), .))
      ) %>%
      dplyr::select(node)

    and <- tmp$node
  }

  # Exclude those in the NOT category

  if (NOT[1] != "") {
    tmp <- mx_data %>%
      dplyr::filter_at(
        dplyr::vars(fields),
        dplyr::any_vars(grepl(paste(NOT,
          collapse = "|"
        ), .))
      ) %>%
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

  if (nrow(mx_results) > 0) {
    names(mx_results)[names(mx_results) == "date_posted"] <- "date_posted"
    names(mx_results)[names(mx_results) == "node"] <- "ID"

    mx_results$date <- lubridate::as_date(as.character(mx_results$date))

    mx_results <- mx_results[, c(
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

    if (deduplicate) {
      mx_results <- mx_results %>%
        dplyr::group_by(doi) %>%
        dplyr::slice(which.max(version)) %>%
        dplyr::ungroup()
    }
  }
  mx_results
}


#' Search for terms in the dataset
#' @param num_results number of searched terms returned
#' @param deduplicate Logical. Only return the most recent version of a record.
#'   Default is TRUE.
#' @family main
print_full_results <- function(num_results,
                               deduplicate) {
  if (num_results > 0) {
    # Create Message
    message <- paste0(
      "Found ",
      num_results,
      " record(s) matching your search."
    )

    if (!deduplicate) {
      message <- paste0(
        message, "\n",
        "Note, there may be >1 version of the same record."
      )
    }

    # Print Message
    message(message)
  } else {
    message("No records found matching your search.")
  }
}

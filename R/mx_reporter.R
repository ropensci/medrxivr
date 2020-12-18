#' Search preprint data and report hits per individual search items
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
#'   "Systematic review" but won't find "Systematic Review".
#' @param NOT Vector of regular expressions to exclude from the search. Default
#'   is NULL.
#' @param deduplicate Logical. Only return the most recent version of a record.
#'   Default is TRUE.
#' @examples
#' \donttest{
#' # Using the daily snapshot
#' reporter_results <- mx_reporter(data = mx_snapshot(), query = "dementia")
#' }
#' @family main
#' @export
#' @importFrom utils download.file
#' @importFrom utils read.csv
#' @importFrom dplyr %>%

mx_reporter <- function(data = NULL,
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
                      deduplicate = TRUE) {

  #run mx_search to get full query results
  results <- mx_search(data, query, fields, from_date, to_date,
                       auto_caps, NOT, deduplicate)
  #count hits
  search_hits <- nrow(results)

  #run mx_search on individual topics, count hits and print message
  for(i in 1:length(query)){

    ifelse(is.list(query),
           query_i <- query[[i]],
           query_i <- query[i])


    suppressMessages(
      topic_hits <- nrow(mx_search(data, query_i, fields, from_date, to_date,
                                   auto_caps, NOT, deduplicate)))

      message(cat("\n"), paste0("Total topic ", i, " records: ", topic_hits))

      # run mx_search for and individual terms within each topic,...
      # count hits and print message
      for(j in 1:length(query_i)){
        suppressMessages(
        term_hits <- nrow(mx_search(data, query_i[j], fields, from_date, to_date,
                                    auto_caps, NOT, deduplicate)))

        message(paste(query_i[j], ": ", term_hits))
      }
  }
  #return results from full search
  results
}

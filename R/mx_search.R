#' Search medRxiv
#' @description Search medRxiv using a string
#' @param query Character string, vector or list
#' @param limit The number of results to return
#' @param NOT Vector of regular expressions to exclude from the search. Default is NULL.
#' @param deduplicate Logical. Only return the most recent version of a record. Default is TRUE
#' @examples \dontrun{
#' mx_results <- mx_search("dementia",limit=20)
#' }
#' @export
#' @importFrom utils download.file
#' @importFrom utils read.csv
#' @importFrom magrittr %>%


mx_search <- function(query,
                      limit = 10,
                      NOT = NULL,
                      deduplicate = FALSE # Change to true at some point
                      ){

  . = NULL
  abstract = NULL
  title = NULL
  node = NULL
  or_1 = NULL
  or_2 = NULL
  or_3 = NULL
  or_4 = NULL
  or_5 = NULL


  mx_data <-
    read.csv(
      paste0(
        "https://raw.githubusercontent.com/mcguinlu/",
        "autosynthesis/master/data/",
        "medRxiv_abstract_list.csv?"
      ),
      stringsAsFactors = FALSE)

  mx_data <- mx_data[,c(2:13)]

  mx_info()

if (length(query)==1) {
  if (query=="*") {
      return(mx_data)
  }
}



#Code to find common matches

if (is.list(query)) {

  # General code to find matches
  for (list in 1:length(query)) {
    tmp <- mx_data %>%
      dplyr::filter_at(dplyr::vars(title, abstract), dplyr::any_vars(grepl(paste(query[[list]], collapse = '|'), .))) %>%
      dplyr::select(node)
    tmp <- tmp$node
    assign(paste0("or_",list), tmp)
  }

  if (length(query)==1) {and <- or_1}
  if (length(query)==2) {and <- Reduce(intersect, list(or_1, or_2))}
  if (length(query)==3) {and <- Reduce(intersect, list(or_1, or_2, or_3))}
  if (length(query)==4) {and <- Reduce(intersect, list(or_1, or_2, or_3, or_4))}
  if (length(query)==5) {and <- Reduce(intersect, list(or_1, or_2, or_3, or_4,
                                                       or_5))}

}

if (!is.list(query) & is.vector(query)) {

  # General code to find matches
    tmp <- mx_data %>%
      dplyr::filter_at(dplyr::vars(title, abstract), dplyr::any_vars(grepl(paste(query, collapse = '|'), .))) %>%
      dplyr::select(node)

    and <- tmp$node

}

if (is.character(query) & !is.vector(query) & !is.list(query)) {

    # General code to find matches
    tmp <- mx_data %>%
      dplyr::filter_at(dplyr::vars(title, abstract), dplyr::any_vars(grepl(query, .))) %>%
      dplyr::select(node)

    and <- tmp$node

}

#Exclude those in the NOT category

if (!is.null(NOT)) {
  # Code to exclude matches
} else {
  results <- and
}

if (deduplicate==FALSE) {
    # Code to exclude matches
} else {
  results <- and
}


mx_results <- mx_data[which(mx_data$node %in% results),]

}



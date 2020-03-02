#' Search medRxiv
#' @description Search medRxiv using a string
#' @param query Character string, vector or list
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
#' @export
#' @importFrom utils download.file
#' @importFrom utils read.csv
#' @importFrom magrittr %>%


mx_search <- function(query,
                      from.date = NULL,
                      to.date = NULL,
                      NOT = NULL,
                      deduplicate = TRUE # Change to true at some point
                      ){

  . <- NULL
  abstract <- NULL
  title <- NULL
  node <- NULL
  or_1 <- NULL
  or_2 <- NULL
  or_3 <- NULL
  or_4 <- NULL
  or_5 <- NULL
  link <- NULL


  # Need to add some error handling here
  # - Capture bad inputs
  # - Cpature when people are not connected to the internet

  # Need a way for people to define which snapshot to use
  mx_info()

  mx_data <-
    read.csv(
      paste0(
        "https://raw.githubusercontent.com/mcguinlu/",
        "autosynthesis/master/data/",
        "medRxiv_abstract_list.csv?"
      ),
      stringsAsFactors = FALSE)

# Limit by dates
mx_data$date <- as.numeric(gsub("-","",mx_data$date))

if (!is.null(to.date)) {
  mx_data <- mx_data %>% dplyr::filter(date <= to.date)
}

if (!is.null(from.date)) {
  mx_data <- mx_data %>% dplyr::filter(date >= from.date)
}


#Code to find common matches

if (is.list(query)) {

  # General code to find matches

  query_length <- as.numeric(length(query))

  for (list in seq_len(query_length)) {
    tmp <- mx_data %>%
      dplyr::filter_at(dplyr::vars(title, abstract),
                       dplyr::any_vars(grepl(paste(query[[list]],
                                                   collapse = '|'), .))) %>%
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
      dplyr::filter_at(dplyr::vars(title, abstract),
                       dplyr::any_vars(grepl(paste(query,
                                                   collapse = '|'), .))) %>%
      dplyr::select(node)

    and <- tmp$node

}

if (is.character(query) & !is.vector(query) & !is.list(query)) {

    # General code to find matches
    tmp <- mx_data %>%
      dplyr::filter_at(dplyr::vars(title, abstract),
                       dplyr::any_vars(grepl(query, .))) %>%
      dplyr::select(node)

    and <- tmp$node

}

#Exclude those in the NOT category

if (!is.null(NOT)) {
  tmp <- mx_data %>%
    dplyr::filter_at(dplyr::vars(title, abstract),
                     dplyr::any_vars(grepl(paste(NOT,
                                                 collapse = '|'), .))) %>%
    dplyr::select(node)

  `%notin%` <- Negate(`%in%`)

  and <- and[and %notin% tmp$node]

  results <- and

} else {
  results <- and
}


if(length(query) > 1){
  mx_results <- mx_data[which(mx_data$node %in% results),]
} else {
  if(query == "*") {
    mx_results <- mx_data
  } else {
    mx_results <- mx_data[which(mx_data$node %in% results),]
  }
}


if (deduplicate==TRUE) {
  mx_results$link <- gsub("\\?versioned=TRUE","", mx_results$link)

  mx_results$version <- substr(mx_results$link,nchar(mx_results$link),nchar(mx_results$link))

  mx_results$link_group <- substr(mx_results$link,1,nchar(mx_results$link)-2)

  mx_results <- mx_results %>%
    dplyr::group_by(link_group) %>%
    dplyr::slice(which.max(version))

  mx_results <- mx_results[1:12]

  # Post message and return dataframe
  message(paste0("Found ",
                 length(mx_results$node),
                 " record(s) matching your search."))

  mx_results

} else {

  # Post message and return dataframe
  message(paste0("Found ",
                 length(mx_results$node),
                 " record(s) matching your search.\n",
                 "Note, there may be >1 version of the same record."))

  mx_results

}

}



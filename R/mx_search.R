#' Search medRxiv
#' @description Search medRxiv using a string
#' @param query Character string, vector or list
#' @param limit The number of results to return
#' @examples \dontrun{
#' mx_results <- mx_search("dementia",limit=20)
#' }
#' @export
#' @importFrom utils download.file
#' @importFrom magrittr %>%


mx_search <- function(query,
                      limit = 10,
                      NOT = NULL
                      ){

  mx_data <-
    read.csv(
      paste0(
        "https://raw.githubusercontent.com/mcguinlu/",
        "autosynthesis/master/data/",
        "medRxiv_abstract_list.csv?"
      ),
      stringsAsFactors = FALSE)

  mx_info()

if (length(query)==1) {
  if (query=="*") {
      return(mx_data)
  }
}


# Check if list
if (is.list(query)) {
  list.indicator <- TRUE
}

if (is.vector(query) & length(query)==1) {
  single.indicator <- TRUE
} else {
  vector.indicator <- TRUE
}

or_no <- 1

# General code to find matches
for (list in 1:length(query)) {
  tmp <- mx_data %>%
    dplyr::filter_at(dplyr::vars(title,abstract), dplyr::any_vars(grepl(paste(query[[list]], collapse = '|'), .))) %>%
    dplyr::select(node)
  tmp <- tmp$node
  assign(paste0("or_",list), tmp)
  or_no <- or_no + 1
}

#Code to find common matches

and <- Reduce(intersect, list(or_1,or_2))

#Exclude those in the NOT category

if (!is.null(NOT)) {
  # Code to exclude matches
} else {
  results <- and
}

mx_results <- mx_data[which(mx_data$node %in% results),]

}



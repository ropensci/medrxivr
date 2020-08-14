#' Export references for preprints returning by a search to a .bib file
#'
#' @param data Dataframe returned by mx_search()
#' @param file File location to save to. Must have the .bib file extension
#'
#' @return Exports a formatted .BIB file, for import into a reference manager
#' @export
#' @family main

#' @examples
#' \dontrun{
#' mx_results <- mx_search(mx_snapshot(), query = "brain")
#' mx_export(mx_results, "references.bib")
#' }
#'
mx_export <- function(data,
                      file = "medrxiv_export.bib") {
  bib_results <- tibble::tibble(
    TITLE = data$title,
    ABSTRACT = data$abstract,
    AUTHOR = gsub(";", " and ", data$authors),
    URL = data$link_page,
    DOI = data$doi,
    YEAR = lubridate::year(data$date),
    NOTE = paste0(
      "Category: ",
      data$category,
      "\nPublished DOI : ",
      data$published
    ),
    CATEGORY = rep("Article", dim(data)[1]),
    BIBTEXKEY = paste0("mx-", seq(1, dim(data)[1]))
  )

  bib2df::df2bib(x = bib_results, file = file)

  message(paste("References exported to", file))
}

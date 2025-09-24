#' Access medRxiv/bioRxiv data via the Cold Spring Harbour Laboratory API
#'
#' @description Provides programmatic access to all preprints available through
#'   the Cold Spring Harbour Laboratory API, which serves both the medRxiv and
#'   bioRxiv preprint repositories.
#' @param from_date Earliest date of interest, written as "YYYY-MM-DD". Defaults
#'   to 1st Jan 2013 ("2013-01-01"), ~6 months prior to earliest preprint
#'   registration date.
#' @param to_date Latest date of interest, written as "YYYY-MM-DD". Defaults to
#'   current date.
#' @param include_info Logical, indicating whether to include variables
#'   containing information returned by the API (e.g. API status, cursor number,
#'   total count of papers, etc). Default is FALSE.
#' @param server Specify the server you wish to use: "medrxiv" (default) or
#'   "biorxiv"
#' @param clean Logical, defaulting to TRUE, indicating whether to clean the
#'   data returned by the API. If TRUE, variables containing absolute paths to
#'   the preprints web-page ("link_page") and PDF ("link_pdf") are generated
#'   from the "server", "DOI", and "version" variables returned by the API. The
#'   "title", "abstract" and "authors" variables are converted to title case.
#'   Finally, the "type" and "server" variables are dropped.
#'
#' @return Dataframe with 1 record per row
#'
#' @family data-source
#' @export
#'
#' @examples
#' if (interactive()) {
#'   mx_data <- mx_api_content(
#'     from_date = "2020-01-01",
#'     to_date = "2020-01-07"
#'   )
#' }
#' @importFrom dplyr %>%
#' @importFrom rlang .data

mx_api_content <- function(from_date = "2013-01-01",
                           to_date = as.character(Sys.Date()),
                           clean = TRUE,
                           server = "medrxiv",
                           include_info = FALSE) {
  # Check that the user is connected to the internet
  internet_check()

  # Check server
  "%notin%" <- Negate("%in%")
  if (server %notin% c("medrxiv", "biorxiv")) {
    stop(paste(
      "Server not recognised -",
      "must be one of \"medrxiv\" or \"biorxiv\""
    ))
  }

  # Get descriptive details and page number
  details_link <- api_link(server, from_date, to_date, "0")
  details <- api_to_df(details_link)

  count <- suppressWarnings(as.numeric(details$messages[1, 6]))
  per_page <- 100L

  if (is.finite(count) && !is.na(count)) {
    message("Estimated total number of records as per API metadata: ", count)
  } else {
    message("Estimated total number of records as per API metadata: <unavailable>")
  }

  # Create empty dataset
  df <- details$collection %>%
    dplyr::filter(doi == "")

  # Progress bar: track pages, not records (avoids finished-assertions)
  total_pages <- if (is.finite(count) && !is.na(count)) ceiling(count / per_page) else NA_integer_
  if (!is.finite(total_pages) || is.na(total_pages) || total_pages < 1L) total_pages <- 1L

  pb_total <- if (!is.finite(count) || is.na(count)) NA_integer_ else total_pages
  pb <- progress::progress_bar$new(
    format = paste0(
      "Downloading... [:bar] :current/:total ",
      "(:percent) Est. time remaining: :eta"
    ),
    total = pb_total,
    clear = TRUE
  )
  on.exit({ if (!pb$finished) pb$terminate() }, add = TRUE)
  pb$tick(0)

  # Get data
  page_starts <- (seq_len(total_pages) - 1L) * per_page
  for (page in page_starts) {
    page_link <- api_link(
      server,
      from_date,
      to_date,
      format(page, scientific = FALSE)
    )
    tmp <- api_to_df(page_link)
    tmp <- tmp$collection
    df <- rbind(df, tmp)
    if (!pb$finished) pb$tick()
  }

  # Clean data
  message("Number of records retrieved from API: ", nrow(df))

  if (is.finite(count) && !is.na(count) && nrow(df) != count) {
    message(paste0(
      "The estimated \"total number\" as per the metadata ",
      "can sometimes be artificially inflated."
    ))
  }

  if (clean == TRUE) {
    df <- clean_api_df(df)
  }

  if (include_info == TRUE) {
    meta <- details$messages
    if (nrow(df) > 0) {
      meta <- meta %>%
        dplyr::slice(rep(1:dplyr::n(), each = nrow(df)))
    } else {
      meta <- meta[0, , drop = FALSE]
    }
    # Avoid name collisions with collection columns
    colliding <- intersect(names(meta), names(df))
    if (length(colliding)) {
      idx <- match(colliding, names(meta))
      names(meta)[idx] <- paste0("api_", colliding)
    }
    df <- dplyr::bind_cols(df, meta)
  }

  tibble::as_tibble(unclass(df))
}


#' Access data on a single medRxiv/bioRxiv record via the Cold Spring Harbour
#' Laboratory API
#'
#' @description Provides programmatic access to data on a single preprint
#'   identified by a unique Digital Object Identifier (DOI).
#' @param doi Digital object identifier of the preprint you wish to retrieve
#'   data on.
#' @param server Specify the server you wish to use: "medrxiv" (default) or
#'   "biorxiv"
#' @param clean Logical, defaulting to TRUE, indicating whether to clean the
#'   data returned by the API. If TRUE, variables containing absolute paths to
#'   the preprints web-page ("link_page") and PDF ("link_pdf") are generated
#'   from the "server", "DOI", and "version" variables returned by the API. The
#'   "title", "abstract" and "authors" variables are converted to title case.
#'   Finally, the "type" and "server" variables are dropped.
#'
#' @return Dataframe containing details on the preprint identified by the DOI.
#'
#' @family data-source
#' @export
#'
#' @examples
#' if (interactive()) {
#'   mx_data <- mx_api_doi("10.1101/2020.02.25.20021568")
#' }
#' @importFrom dplyr %>%
#' @importFrom rlang .data

mx_api_doi <- function(doi,
                       server = "medrxiv",
                       clean = TRUE) {
  "%notin%" <- Negate("%in%")
  if (server %notin% c("medrxiv", "biorxiv")) {
    stop(paste(
      "Server not recognised -",
      "must be one of \"medrxiv\" or \"biorxiv\""
    ))
  }

  details <- api_to_df(api_link(server, doi))
  df <- details$collection

  if (clean == TRUE) {
    df <- clean_api_df(df)
  }

  tibble::as_tibble(unclass(df))
}

#' Download PDF's of preprints returned by a search
#' @description Download PDF's of all the papers in your search results
#' @param mx_results Vector containing the links to the medRxiv PDFs
#' @param directory The location you want to download the PDF's to
#' @param create TRUE or FALSE. If TRUE, creates the directory if it doesn't
#'   exist
#' @param name How to name the downloaded PDF. By default, both the ID number of
#'   the record and the DOI are used.
#' @param print_update How frequently to print an update
#' @examples
#' if (interactive()) {
#'   mx_results <- mx_search(mx_snapshot(), query = "10.1101/2020.02.25.20021568")
#'   mx_download(mx_results, directory = tempdir())
#' }
#' @family helper
#' @export
#' @importFrom utils download.file
#' @importFrom stats runif
#' @importFrom dplyr %>%


mx_download <- function(mx_results,
                        directory,
                        create = TRUE,
                        name = c("ID", "DOI"),
                        print_update = 10) {
  required <- c("link_pdf", "ID", "doi")
  if (!inherits(mx_results, "data.frame") ||
      !all(required %in% names(mx_results))) {
    stop(
      "`mx_results` must be a data frame containing link_pdf, ID, and doi.",
      call. = FALSE
    )
  }
  if (!is.character(directory) || length(directory) != 1L ||
      is.na(directory) || !nzchar(directory)) {
    stop("`directory` must be one non-empty path.", call. = FALSE)
  }
  if (!is.logical(create) || length(create) != 1L || is.na(create)) {
    stop("`create` must be TRUE or FALSE.", call. = FALSE)
  }
  if (!is.numeric(print_update) || length(print_update) != 1L ||
      is.na(print_update) || !is.finite(print_update) ||
      print_update < 1 || print_update != as.integer(print_update)) {
    stop("`print_update` must be one positive whole number.", call. = FALSE)
  }
  if (!is.character(name) || !length(name) ||
      anyNA(name) || !all(name %in% c("ID", "DOI"))) {
    stop("`name` must contain \"ID\", \"DOI\", or both.", call. = FALSE)
  }
  name <- unique(name)

  if (setequal(name, c("ID", "DOI"))) {
    mx_results$filename <- paste0(mx_results$ID, "_", mx_results$doi)
  } else if (identical(name, "ID")) {
    mx_results$filename <- mx_results$ID
  } else {
    mx_results$filename <- mx_results$doi
  }

  mx_results$filename <- gsub("/", "_", mx_results$filename)

  message(paste0(
    "Estimated time to completion: ",
    round(length(mx_results$link_pdf) * 13 / 60 / 60, 2), " hours"
  ))

  if (!dir.exists(directory) && create) {
    dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  }
  if (!dir.exists(directory)) {
    stop("Download directory does not exist: ", directory, call. = FALSE)
  }

  output_files <- file.path(directory, paste0(mx_results$filename, ".pdf"))
  max_attempts <- getOption("medrxivr.download_retries", 3L)
  if (!is.numeric(max_attempts) || length(max_attempts) != 1L ||
      is.na(max_attempts) || max_attempts < 1 ||
      max_attempts != as.integer(max_attempts)) {
    stop("Option `medrxivr.download_retries` must be a positive whole number.",
         call. = FALSE)
  }
  max_attempts <- as.integer(max_attempts)

  for (number in seq_along(mx_results$link_pdf)) {
    file_location <- mx_results$link_pdf[[number]]
    output_file <- output_files[[number]]
    if (file.exists(output_file)) {
      message(paste0(
        "PDF already downloaded for DOI: ",
        mx_results$filename[[number]]
      ))
      next
    }

    for (attempt in seq_len(max_attempts)) {
      message(paste0(
        "Downloading PDF ",
        number,
        " of ",
        length(mx_results$link_pdf),
        " (DOI: ",
        mx_results$filename[[number]],
        "). . . "
      ))

      sleep_time <- runif(1, 10, 13)
      if (nrow(mx_results) > 1) { # nocov start
        Sys.sleep(sleep_time)
      } # nocov end

      download_result <- tryCatch(
        download.file(
          url = file_location,
          destfile = output_file,
          method = "auto",
          mode = "wb"
        ),
        error = identity
      )
      if (!inherits(download_result, "error") &&
          identical(download_result, 0L) &&
          file.exists(output_file)) {
        break
      }
      if (file.exists(output_file)) {
        unlink(output_file)
      }
      if (attempt == max_attempts) {
        detail <- if (inherits(download_result, "error")) {
          conditionMessage(download_result)
        } else {
          paste0("download.file returned status ", download_result)
        }
        stop(
          "Failed to download PDF for DOI ",
          mx_results$filename[[number]],
          " after ", max_attempts, " attempts: ", detail,
          call. = FALSE
        )
      }
    }

    if (number %% print_update == 0) {
      message(paste0(
        "PDF ",
        number,
        " of ",
        length(mx_results$link_pdf),
        " downloaded! (",
        round(number / length(mx_results$link_pdf) * 100, 0),
        "%) "
      ))
    }
  }

  invisible(output_files)
}

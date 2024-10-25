#' Access a static snapshot of the medRxiv repository
#'
#' @description [Available for medRxiv only] Rather than downloading a copy of
#'   the medRxiv database from the API, which can become unavailable at peak
#'   usage times, this allows users to import a maintained static snapshot of
#'   the medRxiv repository.
#'
#' @param commit Commit hash for the snapshot, taken from
#'   https://github.com/mcguinlu/medrxivr-data. Allows for reproducible
#'   searching by specifying the exact snapshot used to perform the searches.
#'   Defaults to "master", which will return the most recent snapshot.
#'
#' @return Formatted dataframe
#' @export
#' @family data-source
#' @examples
#' \donttest{
#' mx_data <- mx_snapshot()
#' }
#'
mx_snapshot <- function(commit = "main") {

  # Get the base URL for the data repository
  base_url <- paste0(
    "https://github.com/YaoxiangLi/medrxivr-data/raw/refs/heads/", commit, "/"
  )

  # Generate a list of potential snapshot part files
  # Assuming the files follow the pattern "snapshot_part1.csv", "snapshot_part2.csv", etc.
  part_files <- paste0("snapshot_part", 1:20, ".csv")

  # Initialize an empty list to store dataframes
  df_list <- list()

  # Try to read each file and add it to the list
  for (part_file in part_files) {
    url <- paste0(base_url, part_file)

    # Attempt to read the file; skip if it doesn't exist
    try({
      mx_part <- suppressMessages(data.table::fread(url, showProgress = FALSE))
      df_list[[length(df_list) + 1]] <- mx_part
    }, silent = TRUE)
  }


  # Combine all the loaded parts into a single dataframe
  if (length(df_list) == 0) {
    stop("No data could be loaded. Please check the commit or data availability.")
  }
  mx_data <- dplyr::bind_rows(df_list)

  # Reconstruct the link_page and link_pdf columns
  mx_data$link_page <- paste0("https://www.medrxiv.org", mx_data$link)
  mx_data$link_pdf <- paste0("https://www.medrxiv.org", mx_data$pdf)

  # Return the combined dataframe
  mx_data
}

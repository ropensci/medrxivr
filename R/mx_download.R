#' Download PDF's
#' @description Download PDF's of all the papers in your search results
#' @param mx_results Vector containing the links to the medRxiv PDFs
#' @param directory The location you want to download the PDF's to
#' @param create TRUE or FALSE. If TRUE, creates the directory if it doesn't exist
#' @param print_update How frequently to print an update
#' @examples \dontrun{
#' mx_results <- mx_search("ecology",limit=20)
#' mx_download(mx_results,"~/medrxivPDF")
#' }
#' @export
#' @importFrom utils download.file
#' @importFrom methods is
#' @importFrom stats runif


mx_download <- function(mx_results,
                        directory,
                        create = TRUE,
                        print_update = 10){

  print(paste0("Estimated time to completion: ",
               round(length(mx_results$pdf)*13/60/60, 2), " hours"))

  if(!file.exists(directory)  && create){
    dir.create(file.path(directory))
  }

  # Add trailing forward slash to the directory path
  if(substr(directory,nchar(directory), nchar(directory)) != "/"){
    directory <- paste(directory,"/",sep="")
  }

  number <- 1

  for (file_location in mx_results$pdf) {
    if (file.exists(paste0(directory,
                           mx_results$node[which(mx_results$pdf ==
                                                 file_location)],
                           ".pdf"))) {
      print(paste0("PDF for ID ", mx_results$node[which(mx_results$pdf ==
                                                           file_location)],
                   " already downloaded."))

      number <- number + 1

      next
    }

    while (TRUE) {
      print(paste0("Downloading PDF ",
                   number,
                   " of ",
                   length(mx_results$link),
                   " (ID: ",
                   mx_results$node[which(mx_results$pdf ==
                                                       file_location)],
                   "). . . "))

      sleep_time <- runif(1, 10, 13)
      Sys.sleep(sleep_time)

      pmx_results <-
        try(download.file(
          url = paste0("https://www.medrxiv.org", file_location),
          destfile = paste0(directory, mx_results$node[number], ".pdf"),
          method = "auto",
          mode = "wb"
        ))
      if (!is(pmx_results, 'try-error'))
        break
    }



    if ((number %% print_update == 0) == TRUE) {
      print(paste0(
        "PDF ",
        number,
        " of ",
        length(mx_results$link),
        " downloaded! (",
        round(number / length(mx_results$link) * 100, 0),
        "%) "
      ))
    }

    number <- number + 1

  }
}

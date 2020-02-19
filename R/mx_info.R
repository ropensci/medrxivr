#' Search medRxiv
#' @description Get information about the data dump you are using
#' @examples \dontrun{
#' mx_info()
#' }
#' @export

mx_info <- function(){

  # Need code to read current version of it

  current_time <- readLines(paste0("https://raw.githubusercontent.com/",
                                   "mcguinlu/",
                                   "autosynthesis/master/data/timestamp.txt"))

  mess<- paste0("Using medRxiv DataDump - ",
                current_time)
  message(mess)
}

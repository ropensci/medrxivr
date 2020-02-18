#' Search medRxiv
#' @description Get information about the data dump you are using
#' @examples \dontrun{
#' mx_info()
#' }
#' @export

mx_info <- function(){

  # Need code to read current version of it

  mess<- paste0("Using medRxivr DataDump V",
                " - Up to date as of 9:00am on",
                "")
  message(mess)
}

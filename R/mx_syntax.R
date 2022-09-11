#' Search term wrapper that allows for different capitalisation of term
#'
#' @description Inspired by the varying capitalisation of "NCOV" during the
#'   coronavirus pandemic (e.g. ncov, nCoV, NCOV, nCOV), this function allows
#'   for all possible configurations of lower- and upper-case letters in your
#'   search term.
#'
#' @param x Search term to be formatted
#'
#' @return The input string is return, but with each non-space character
#'   repeated in lower- and upper-case, and enclosed in square brackets. For
#'   example, mx_caps("ncov") returns "[Nn][Cc][Oo][Vv]"
#' @export
#' @family helper
#'
#' @examples
#' \donttest{
#'
#' query <- c("coronavirus", mx_caps("ncov"))
#'
#' mx_search(mx_snapshot("6c4056d2cccd6031d92ee4269b1785c6ec4d555b"), query)
#' }
#'
mx_caps <- function(x) {

  x_v <- stringr::str_to_lower(x) %>%
    stringr::str_split(stringr::boundary()) %>%
    unlist()

  for (position in 1:nchar(x)) {
    if (x_v[position] == " ") {
      next
    }
    x_v[position] <- paste0("[",stringr::str_to_upper(x_v[position]),x_v[position],"]")
  }

  x_v <- paste0(x_v, collapse = "")

  return(x_v)
}

#' Allow for capitalisation of search terms
#'
#' @param x Search query to be formatted. Note, any search term already
#'   containing a square bracket will not be reformatted to preserve
#'   user-defined regexes.
#'
#' @return The same list or vector search terms, but with proper regular
#'   expression syntax to allow for capitalisation of the first letter of each
#'   term.
#' @keywords internal

fix_caps <- function(x){

  x_clean <- lapply(x, function(y){

     purrr::map_chr(y, function(z){

       # Stop if first character in string is square-brackets
       if (grepl("\\[",substr(z,1,1))==TRUE) {
         return(z)
       }

       z_v <- stringr::str_squish(z) %>%
         lapply(function(z) {
           paste0("[",
                  toupper(substr(z, 1, 1)),
                  tolower(substr(z, 1, 1)),
                  "]",
                  substr(z, 2, nchar(z)))
         }) %>%
         unlist()

       return(z_v)
     })

    }

  )

  if (!is.list(x)) {
    x_clean <- unlist(x_clean)
  }

  return(x_clean)

}


#' Replace user-friendly 'wildcard' operator with appropriate regex syntax
#'
#' @param x Search query to be reformatted
#'
#' @keywords internal

fix_wildcard <- function(x) {

  x_clean <- lapply(x, function(y) {
   purrr::map_chr(y, function(z) {
      stringr::str_replace_all(z, "\\*", "([[:alpha:]])")
    })
  })

if (!is.list(x)) {
  x_clean <- unlist(x_clean)
}


  return(x_clean)

}


#' Replace user-friendly 'NEAR' operator with appropriate regex syntax
#'
#' @param x Search query to be reformatted
#'
#' @keywords internal

fix_near <- function(x) {

  x_clean <- lapply(x, function(y) {
    purrr::map_chr(y, function(z) {
      stringr::str_replace_all(z,"\\s?[Nn][Ee][Aa][Rr](\\d)\\s?","NEAR\\1") %>%
      stringr::str_replace_all("NEAR(\\d)","(\\\\s+)([[:graph:]]+\\\\s+){0,\\1}")
    })
  })

  if (!is.list(x)) {
    x_clean <- unlist(x_clean)
  }

  return(x_clean)

}



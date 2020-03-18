# library(stringr)
# library(here)
# library(pushoverr)
# library(rvest)

cross_check <- function(){

page <- read_html("https://www.medrxiv.org/search/%252A")

results <- page %>%
  html_nodes("#page-title") %>%
  html_text()

results <- gsub(",","",results)

results <- as.numeric(word(results))

data <- read.csv(here("data","medRxiv_abstract_list.csv"), stringsAsFactors = FALSE, 
fileEncoding = "UTF-8")

data$link <- gsub("\\?versioned=TRUE","", data$link)

data$link <- substr(data$link,1,nchar(data$link)-2)

extracted <- as.numeric(length(unique(data$link)))

# Check number extracted matches number returned by general search
if (identical(results,extracted)==TRUE) {
  x <- "Success"
} else {
  x <- "Failure"
}

x

}
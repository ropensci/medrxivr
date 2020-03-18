check_subjects <- function(){

# Get links for those records without subjects
df <- read.csv("data/medRxiv_abstract_list.csv", 
               fileEncoding = "UTF-8")

number_no_sub <- length(df$subject[which(df$subject=="No category recorded" | is.na(df$subject)==TRUE)])

print(paste0("Estimated time to completion: ",
             round(as.numeric(number_no_sub)*13/60/60,2),
             " hours"))

for(row in 1:length(df$title)){
  
  if(!is.na(df$subject[row])){
    if(df$subject[row] != "No category recorded"){
      next
    }
  }
  
  while(TRUE){
    sleep_time <- runif(1,10,13)
    Sys.sleep(sleep_time)
    page <- try(read_html(paste0("https://www.medrxiv.org/node/",df$node[row])))
    if(!is(page, 'try-error')) break
  }

  subject <- page %>%
    html_node(".highlight") %>%
    html_text()
  
  if(is.na(subject)) {
    subject <- "No category recorded"
  }

  df$subject[row] <- subject
}

write.csv(df,
          "data/medRxiv_abstract_list.csv",
          fileEncoding = "UTF-8",
          row.names = FALSE)
}


# QC for dates ------------------------------------------------------------

check_dates <- function(){

df <- read.csv("data/medRxiv_abstract_list.csv", 
               fileEncoding = "UTF-8")


for (row in 1:length(df$title)) {
  if (!is.na(df$date[row])) {
    next
  }
  
  while (TRUE) {
    sleep_time <- runif(1, 10, 13)
    Sys.sleep(sleep_time)
    page <-
      try(read_html(paste0("https://www.medrxiv.org/node/", df$node[row])))
    if (!is(page, 'try-error'))
      break
  }
  
  date <- page %>%
    html_node(".pane-1 .pane-content") %>%
    html_text()
  
  date  <- gsub("Posted", "", date)
  date  <- gsub("\\.", "", date)
  date  <- trimws(date)
  date <- gsub(" ", "", date)
  date <- gsub(",", "", date)
  date <- gsub("\u00a0", "", date)
  date <- as.character(as.Date(date, format = "%B%d%Y"))
  date <- gsub("Â", "", date)
  
  df$date[row] <- date
}
  
for(row in 1:length(df$title)) {
  if (grepl("/", df$date[row]) == TRUE) {
    df$date[row] <- gsub("/", "", df$date[row])
    df$date[row] <-
      paste0(
        substring(df$date[row], 5, 8),
        "-",
        substring(df$date[row], 3, 4),
        "-",
        substring(df$date[row], 1, 2)
      )
  }
  
}

dates <- as.numeric(gsub("-", "", df$date)
)
  
print(paste0("Number of records with impossible date: ", 
               length(dates[which(dates <= 20190625)])
               ))  

for(row in 1:length(df$title)) {
  if (dates[row] >= 20190625) {
    next
  }
  
  while (TRUE) {
    sleep_time <- runif(1, 10, 13)
    Sys.sleep(sleep_time)
    page <-
      try(read_html(paste0("https://www.medrxiv.org/node/", df$node[row])))
    if (!is(page, 'try-error'))
      break
  }
  
  date <- page %>%
    html_node(".pane-1 .pane-content") %>%
    html_text()
  
  date  <- gsub("Posted", "", date)
  date  <- gsub("\\.", "", date)
  date  <- trimws(date)
  date <- gsub(" ", "", date)
  date <- gsub(",", "", date)
  date <- gsub("\u00a0", "", date)
  date <- as.character(as.Date(date, format = "%B%d%Y"))
  date <- gsub("Â", "", date)
  
  df$date[row] <- date
}

write.csv(
  df,
  "data/medRxiv_abstract_list.csv",
  fileEncoding = "UTF-8",
  row.names = FALSE
)
}




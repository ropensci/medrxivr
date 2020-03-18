

# PUSHOVER_USER=readLines("PUSHOVER_USER.txt")
# PUSHOVER_APP=readLines("PUSHOVER_APP.txt")

extractdailyfn <- function(){
  
message2 <- "Starting medRxiv daily extraction. . ."
  
pushover(message2, user = PUSHOVER_USER, app = PUSHOVER_APP)  


if (interactive()) {
for (t in c(1,2,3)) {
  print(paste0("Loading inital site - ", t, " of 3"))
  browseURL("https://medrxiv.org")
  Sys.sleep(t*10)
}
}

# Get most recent node ----------------------------------------------------

node_recent <- read.csv("data/medRxiv_last_extracted.csv", stringsAsFactors = FALSE)
node_recent <- node_recent[1,1]

# Get target node ---------------------------------------------------------

page <- read_html("https://www.medrxiv.org/archive?field_highwire_a_epubdate_value%5Bvalue%5D&page=0")

tmp <- page %>%
  html_nodes(".highwire-cite-linked-title") %>%
  html_attr('href') %>%
  data.frame(stringsAsFactors = FALSE)

tmp <- tmp[1,1]

page2 <- try(read_html(paste0("https://www.medrxiv.org/",tmp)))

target_node <- page2 %>%
  html_node(".first .hw-download-citation-link") %>%
  html_attr('href')

#Clean target node
target_node <- gsub("/highwire/citation/","",target_node)
target_node <- gsub("/bibtext","",target_node)

# Check that new records exist --------------------------------------------

node_recent <- as.numeric(node_recent)
target_node <- as.numeric(target_node)

if (node_recent==target_node) {
  # cc <- cross_check()
  # pushover(message = paste0("No new medRxiv records found. Cross check: ",cc),
  #          user = PUSHOVER_USER,
  #          app = PUSHOVER_APP)
  stop("No new links")
}

# Extract data ------------------------------------------------------------

# Create empty dataframe

abstract_data_daily <- data.frame(
  title = character(),
  abstract = character(),
  link = character(),
  date = character(),
  subject = character(),
  authors = character(),
  bibtex = character(),
  pdf = character(), 
  extraction_date = character(), 
  node = numeric())

print(paste0("Estimated time to completion: ",
             round((as.numeric(target_node)-as.numeric(node_recent))*13/60/60,2),
             " hours"))

start_node <- node_recent+1

for (node in start_node:target_node) {
    
  try <- 1
  while (try <= 5) {
    Sys.sleep(runif(1,10,13))
    print(paste0("Node ", node, " of ", target_node))
    link <-  paste0("https://www.medrxiv.org/node/", node, "?versioned=TRUE")
    page <- try(read_html(link))
    if (!is(page, 'try-error')) break
    try <- try + 1
  }
  
  if (is(page, 'try-error')) next
  
  id <- as.numeric(node)-node_recent+1
  
  title_try <- try(page %>%
    html_node(".highwire-cite-title") %>%
    html_text())
  
  if (is(title_try, 'try-error')) next
  
  title <- title_try
  
  abstract <- page %>%
    html_node("#p-2") %>%
    html_text()
  
  pdf_link <- page %>%
    html_node(".article-dl-pdf-link") %>%
    html_attr('href')
  
  date <- page %>%
    html_node(".pane-1 .pane-content") %>%
    html_text()
  
  subject <- page %>%
    html_node(".highlight") %>%
    html_text()
  
  if(is.na(subject)) {
    subject <- "No category recorded"
  }
  
  authors <- page %>%
    html_node(".nlm-surname") %>%
    html_text
  
  ### Only exists for bioRxiv ###
  # article_type <- page %>%
  #                 html_node(".biorxiv-article-type") %>%
  #                 html_text()
  
  bibtex <- page %>%
    html_node(".first .hw-download-citation-link") %>%
    html_attr('href')
  
  node <- gsub("/highwire/citation/","",bibtex)
  node <- gsub("/bibtext","",node)
  
  link <- gsub(".full.pdf","", pdf_link)
  link <- paste0(link,"?versioned=TRUE")
  
  tmp <- data.frame(title = title,
                    abstract = abstract,
                    link = link,
                    pdf = pdf_link, 
                    date = date,
                    subject = subject,
                    authors = authors,
                    bibtex = bibtex,
                    id=id, 
                    node = node)
  
  abstract_data_daily <- rbind(abstract_data_daily, tmp)
  
}

# Drop NA values
abstract_data_daily <- abstract_data_daily %>%
  drop_na(title)

#Clean dataset
abstract_data_daily$date  <- gsub("Posted","", abstract_data_daily$date)
abstract_data_daily$date  <- gsub("\\.","", abstract_data_daily$date)
abstract_data_daily$date  <- trimws(abstract_data_daily$date)
abstract_data_daily$date <- gsub(" ","",abstract_data_daily$date)
abstract_data_daily$date <- gsub("\u00a0","",abstract_data_daily$date)
abstract_data_daily$date <- as.Date(abstract_data_daily$date,"%B%d,%Y")
abstract_data_daily$date <- as.character(abstract_data_daily$date)

abstract_data_daily$authors  <- trimws(abstract_data_daily$authors)

abstract_data_daily$id <- seq(length(abstract_data_daily$title):1)

abstract_data_daily$pdf_name <- paste0(format(Sys.Date(),"%d%m%y"),"-",abstract_data_daily$id)
abstract_data_daily$extraction_date <- format(Sys.Date(), format="%d-%m-%Y")

# Save data and reference node --------------------------------------------

# Save data
print("Saving new abstract list . . .")
abstract_data <- read.csv("data/medRxiv_abstract_list.csv", 
                          fileEncoding = "UTF-8")

if (ncol(abstract_data)>12) {
  abstract_data <- abstract_data[,c(2:13)]
}

abstract_data <- rbind(abstract_data, abstract_data_daily)

abstract_data$date <- gsub("Â","",abstract_data$date)
abstract_data$date <- trimws(abstract_data$date)

abstract_data$abstract <- gsub("\\.","xxxxxx",abstract_data$abstract)
abstract_data$abstract <- gsub("\\,","yyyyyy",abstract_data$abstract)
abstract_data$title <- gsub("\\.","xxxxxx",abstract_data$title)
abstract_data$title <- gsub("\\,","yyyyyy",abstract_data$title)

# Remove all punctuation, due to encoding errors at a later stage!
abstract_data$abstract <- gsub(paste0(c("Â","â","Ã","[^[:alnum:][:blank:]?&/\\-]","\\n","ÃƒÂ¢Ã¢â\200šÂ¬Ã¢â\200žÂ¢s", "ÃƒÂ¢Ã¢â\200šÂ¬Ã¢â\200žÂ¢s", "ÃƒÂ¢Ã¢â\200šÂ¬Ã", "ÃƒÂ¢Ã¢â\200šÂ¬Ã…â\200œ", "ÃƒÂ¢Ã¢â\200šÂ¬Ã", "Â\\\\u009d", "\\\\"),collapse = "|"),
                               "",
                               abstract_data$abstract)


abstract_data$title <- gsub(paste0(c("Â","â","[^[:alnum:][:blank:]?&/\\-]","\\\\n","ÃƒÂ¢Ã¢â\200šÂ¬Ã¢â\200žÂ¢s", "ÃƒÂ¢Ã¢â\200šÂ¬Ã¢â\200žÂ¢s", "ÃƒÂ¢Ã¢â\200šÂ¬Ã", "ÃƒÂ¢Ã¢â\200šÂ¬Ã…â\200œ", "ÃƒÂ¢Ã¢â\200šÂ¬Ã", "Â\\\\u009d","\\\\"),collapse = "|"),
                               "",
                               abstract_data$title)

abstract_data$abstract <- gsub("xxxxxx","\\.",abstract_data$abstract)
abstract_data$abstract <- gsub("yyyyyy","\\,",abstract_data$abstract)
abstract_data$title <- gsub("xxxxxx","\\.",abstract_data$title)
abstract_data$title <- gsub("yyyyyy","\\,",abstract_data$title)


abstract_data$subject <- gsub("\\n", "",abstract_data$subject)
abstract_data$subject <- gsub("\\", "", abstract_data$subject, fixed=TRUE)

for (col in c(1:8,10,11)){
  if (!is.character(abstract_data[1,col])) {
    next
  }
  abstract_data[,col] <- utf8_encode(abstract_data[,col])
}

write.csv(abstract_data,
          "data/medRxiv_abstract_list.csv",
          fileEncoding = "UTF-8",
          row.names = FALSE)

#Save reference node
print("Saving new reference link. . .")
new_node <- as.character(abstract_data_daily$node[length(abstract_data_daily$node)])
write.csv(new_node,"data/medRxiv_last_extracted.csv", row.names = FALSE)

}

# extractdailyfn()

library(jsonlite)
library(dplyr)

today <- Sys.Date()

link <- paste0("https://api.biorxiv.org/details/medrxiv/2019-06-01/",today,"/0")

df <- fromJSON(link) %>%
  data.frame()

count <- df[1,6]

df <- df %>%
  filter(messages.status == "not.ok")

pages <- floor(count/100)


# Get data
for (cursor in 0:pages) {

  print(paste0("Starting page ",cursor))

  page <- cursor*100

  link <- paste0("https://api.biorxiv.org/details/medrxiv/2019-06-01/",today,"/",
                 page)

  tmp <- fromJSON(link) %>%
    as.data.frame()

  df <- rbind(df, tmp)

}

# Clean

df$node = seq(1:nrow(df))
names(df) <- gsub("collection.","",names(df))

df <- df %>%
  select(-c(type,server))

df <- df %>%
  select(-starts_with("messages"))

df$link <- paste0("/content/",df$doi,"v",df$version,"?versioned=TRUE")
df$pdf <- paste0("/content/",df$doi,"v",df$version,".full.pdf")
df$category <- stringr::str_to_title(df$category)
df$authors <- stringr::str_to_title(df$authors)
df$author_corresponding <- stringr::str_to_title(df$author_corresponding)


write.csv(df,
          "extract/snapshot.csv",
          fileEncoding = "UTF-8",
          row.names = FALSE)


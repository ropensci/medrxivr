plot_results <- function(df_total, result_list){

  # Clean data for search hits ----
  df_search <- data.frame(
    Title = result_list$title,
    url = gsub("\\?.*", "", result_list$link_page),
    doi = result_list$doi,
    First_posted = as.Date(strptime(result_list$date, "%Y%m%d")),
    Group = "Search hits"
  )

  df_search <- df_search[!duplicated(df_search$doi), ]

  df_search$First_posted <-
    as.Date(df_search$First_posted, format = "%Y-%m-%d")
  df_search <- df_search[with(df_search, order(First_posted)), ]
  if (nrow(df_search) != 0) {
    df_search$Total_papers <- 1:nrow(df_search)
  }

  # Clean data for total number of results ----
  df_all <- data.frame(
    Title = df_total$title,
    url = gsub("\\?.*", "", df_total$link_page),
    doi = df_total$doi,
    First_posted = as.Date(strptime(df_total$date, "%Y%m%d")),
    Group = "All papers"
  )

  df_all <- df_all[!duplicated(df_all$doi), ]

  df_all$First_posted <-
    as.Date(df_all$First_posted, format = "%Y-%m-%d")
  df_all <- df_all[with(df_all, order(First_posted)), ]
  if (nrow(df_all) != 0) {
    df_all$Total_papers <- 1:nrow(df_all)
  }

  # Merge dataframes ----
  df <- rbind(df_search, df_all)

  # Wrap long titles so tooltips are ridiculous ----
  df$Title <- stringr::str_wrap(
    string = df$Title,
    width = 50,
    indent = 1,
    # let's add extra space from the margins
    exdent = 1  # let's add extra space from the margins
  )

  # Create ggplot and subsequent ggplotly objects ----
  g <-
    ggplot(df, aes(x = First_posted, y = Total_papers, label = Title)) +
    geom_step(
      data = df,
      mapping = aes(group = 1, color = Group),
      alpha = 1
    ) +
    geom_point(aes(color = Group), size = 0.5) +
    xlab('Date') +
    ylab("medRxiv pre-prints") +
    scale_x_date(limits = c(as.Date('2019-06-24'), as.Date(Sys.time()))) +
    theme_bw(base_size = 17) +
    scale_color_manual(values = c("gray50", "#333333")) +
    theme(legend.title = element_blank()) +
    NULL

  ggp <- ggplotly(g) %>%
    add_annotations(
      text = "",
      xref = "paper",
      yref = "paper",
      x = 1.02,
      xanchor = "left",
      y = 0.6,
      yanchor = "bottom",
      legendtitle = TRUE,
      showarrow = FALSE
    ) %>%
    layout(legend = list(y = 0.7, yanchor = "top"))

  # Add URLs, which direct to record on medRxiv when clicked
  ggp$x$data[[1]]$customdata <- df_all$url


  ggp$x$data[[2]]$customdata <- df_search$url


  # Clean text in tooltip ----
  ggp$x$data[[1]]$text <-
    gsub("Group: All papers<br />", "", ggp$x$data[[1]]$text)
  ggp$x$data[[1]]$text <-
    gsub("Group: Search hits<br />", "", ggp$x$data[[1]]$text)
  ggp$x$data[[1]]$text <-
    gsub("First_posted",
         "First version of record posted",
         ggp$x$data[[1]]$text)
  ggp$x$data[[1]]$text <-
    gsub("Total_papers",
         "Total number of papers to date",
         ggp$x$data[[1]]$text)

  # Return plot ----
  ggp
}


plot_histogram <- function(result_list){


  # Clean data ----
  df_search <- data.frame(
    Title = result_list$title,
    url = gsub("\\?.*", "", result_list$link_page),
    doi = result_list$doi,
    subject = result_list$category,
    First_posted = as.Date(strptime(result_list$date, "%Y%m%d")),
    Group = ""
  )

  df_search <- df_search[!duplicated(df_search$doi), ]

  df_search$First_posted <-
    as.Date(df_search$First_posted, format = "%Y-%m-%d")

  df_search$subject <- gsub("and", "&", df_search$subject)

  df_search$subject[is.na(df_search$subject)] <-
    "No category recorded"

  df_search$subject <- gsub("\\n", "", df_search$subject)

  # Define groups to colour by ----
  df_search <- df_search  %>%
    group_by(subject) %>%
    mutate(count = n()) %>%
    ungroup(subject)

  df_search$colour <- "nomax"

  df_search$colour[which(df_search$count == max(df_search$count))] <-
    "max"

  # Create ggplot and subsequent ggplotly objects ----
  g <- ggplot(df_search, aes(subject)) +
    geom_histogram(aes(fill = colour), stat = "count") +
    theme_void() +
    scale_fill_manual(values = c("#333333", "gray50")) +
    theme(
      panel.grid = element_blank(),
      axis.line = element_blank(),
      legend.position = "none"
    )

  ggp <- ggplotly(g)


  # Clean text in tooltip ----
  ggp$x$data[[1]]$text <-
    gsub("colour: max<br />", "", ggp$x$data[[1]]$text)
  ggp$x$data[[1]]$text <-
    gsub("<br />count:", "\nNumber of preprints:", ggp$x$data[[1]]$text)
  ggp$x$data[[1]]$text <- gsub("subject.*", "", ggp$x$data[[1]]$text)
  ggp$x$data[[1]]$text <-
    gsub("count:", "Subject:", ggp$x$data[[1]]$text)


  if (length(unique(df_search$colour)) != 1) {
    ggp$x$data[[2]]$text <-
      gsub("colour: nomax<br />", "", ggp$x$data[[2]]$text)
    ggp$x$data[[2]]$text <-
      gsub("<br />count:", "\nNumber of preprints:", ggp$x$data[[2]]$text)
    ggp$x$data[[2]]$text <- gsub("subject.*", "", ggp$x$data[[2]]$text)
    ggp$x$data[[2]]$text <-
      gsub("count:", "Subject:", ggp$x$data[[2]]$text)
  }

  # Return plot ----
  ggp

}


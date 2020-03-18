word_cloud <- function(df){

df_tiab <- df[, 1:2]

df_tiab <- tidyr::gather(df_tiab, key, word) %>% select(word)

tokens <- df_tiab %>%
  unnest_tokens(word, word) %>%
  dplyr::count(word, sort = TRUE) %>%
  ungroup()

tokens %>% head(10)

data("stop_words")
tokens_clean <- tokens %>%
  anti_join(stop_words)

nums <- tokens_clean %>% filter(str_detect(word, "^[0-9]")) %>% select(word) %>% unique()

tokens_clean <- tokens_clean %>%
  anti_join(nums, by = "word")

uni_sw <- data.frame(word = c("al","figure","i.e"))

tokens_clean <- tokens_clean %>%
  anti_join(uni_sw, by = "word")

tokens_clean %>% head(10)

pal <- rev(brewer.pal(9,"Greys"))

# plot the 50 most common words
# tokens_clean %>%
#   with(wordcloud(word, n, random.order = FALSE, max.words = 100, colors=pal, scale=c(3.5,0.25)))
wordcloud2(tokens_clean, color = pal, shuffle = FALSE )

}



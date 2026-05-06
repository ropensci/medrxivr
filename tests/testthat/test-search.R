test_that("Search validates required inputs", {
  expect_error(mx_search(), "preprint data")
  expect_error(mx_search(data = sample_preprint_data()), "search terms")
  expect_error(mx_search(data = list(other = data.frame()), query = "dementia"), "data.frame element")
  expect_error(mx_search(data = data.frame(title = "dementia"), query = "dementia"), "date")
})

test_that("Search handles string, vector, list, date, and deduplication inputs", {
  mx_data <- sample_preprint_data()
  wrapped_data <- list(data = mx_data)

  wrapped <- suppressMessages(mx_search(wrapped_data, query = "Dementia", deduplicate = FALSE))
  expect_equal(nrow(wrapped), 3L)

  dementia <- suppressMessages(mx_search(mx_data, query = "Dementia", deduplicate = FALSE))
  expect_equal(nrow(dementia), 3L)

  deduplicated <- suppressMessages(mx_search(mx_data, query = "Dementia", deduplicate = TRUE))
  expect_equal(nrow(deduplicated), 2L)
  expect_equal(deduplicated$version[deduplicated$doi == "10.1101/2020.01.02.1"], 2L)

  vector_query <- suppressMessages(mx_search(mx_data, query = c("Dementia", "Asthma"), deduplicate = FALSE))
  expect_equal(nrow(vector_query), 4L)

  list_query <- suppressMessages(mx_search(mx_data, query = list("Dementia", "Alzheimer"), deduplicate = FALSE))
  expect_equal(nrow(list_query), 2L)

  dated <- suppressMessages(mx_search(
    mx_data,
    query = "Dementia",
    from_date = "2020-02-01",
    to_date = "2020-03-01",
    deduplicate = FALSE
  ))
  expect_equal(dated$ID, 2L)

  all_results <- suppressMessages(mx_search(mx_data, query = "*", deduplicate = FALSE))
  expect_equal(nrow(all_results), nrow(mx_data))

  direct_all <- run_search(mx_data, query = "*", fields = c("title"), deduplicate = FALSE)
  expect_equal(nrow(direct_all), nrow(mx_data))
})

test_that("Search supports NOT, auto capitalization, wildcards, NEAR, and reports", {
  mx_data <- sample_preprint_data()

  expect_message(
    excluded <- mx_search(mx_data, query = "Dementia", NOT = "Vascular", deduplicate = FALSE),
    "matching your search"
  )
  expect_equal(nrow(excluded), 2L)

  auto_not <- suppressMessages(mx_search(mx_data, query = "Dementia", NOT = "vascular", auto_caps = TRUE))
  expect_false(any(grepl("Vascular", auto_not$title)))

  auto <- suppressMessages(mx_search(mx_data, query = "dementia", auto_caps = TRUE, deduplicate = FALSE))
  expect_equal(nrow(auto), 3L)

  wildcard <- suppressMessages(mx_search(mx_data, query = "biomark*", deduplicate = FALSE))
  expect_equal(nrow(wildcard), 2L)

  near <- suppressMessages(mx_search(mx_data, query = "Vascular NEAR2 dementia", deduplicate = FALSE))
  expect_equal(near$ID, 2L)

  expect_message(
    mx_search(mx_data, query = list(c("Dementia", "Alzheimer")), report = TRUE),
    "Total topic 1 records"
  )
  expect_message(
    mx_search(mx_data, query = "Dementia", NOT = "Vascular", report = TRUE),
    "records matched by NOT"
  )
})

test_that("Search returns a message and NULL when no records match", {
  expect_message(
    result <- mx_search(sample_preprint_data(), query = "nonexistent"),
    "No records found"
  )
  expect_null(result)
})

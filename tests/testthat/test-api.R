test_that("Server not recognised", {
  skip_if_offline()
  expect_error(mx_api_content(server = "medRxiv"))
  expect_error(mx_api_doi(server = "medRxiv"))
})

test_that("API content paginates, cleans records, and can include metadata", {
  raw <- sample_raw_api_data()
  fake_reader <- function(url) {
    cursor <- tail(strsplit(url, "/", fixed = TRUE)[[1]], 1)
    row <- if (identical(cursor, "0")) 1L else 2L
    list(
      messages = data.frame(
        status = "ok",
        interval = "2020-01-01:2020-01-31",
        cursor = as.integer(cursor),
        count = 1L,
        total = 2L
      ),
      collection = raw[row, , drop = FALSE]
    )
  }

  with_test_bindings(
    environment(mx_api_content),
    list(internet_check = function() TRUE, api_to_df = fake_reader),
    {
      expect_message(
        mx_data <- mx_api_content(
          from_date = "2020-01-01",
          to_date = "2020-01-31",
          include_info = TRUE
        ),
        "Number of records retrieved"
      )
    }
  )

  expect_equal(nrow(mx_data), 2L)
  expect_true(all(c("link_page", "link_pdf", "status", "count") %in% names(mx_data)))
  expect_equal(mx_data$title, c("dementia trial", "asthma cohort"))
})

test_that("API content handles unavailable metadata and raw output", {
  raw <- sample_raw_api_data()[1, , drop = FALSE]
  fake_reader <- function(url) {
    list(
      messages = data.frame(status = "ok", cursor = 0L),
      collection = raw
    )
  }

  with_test_bindings(
    environment(mx_api_content),
    list(internet_check = function() TRUE, api_to_df = fake_reader),
    {
      expect_message(mx_data <- mx_api_content(clean = FALSE), "<unavailable>", fixed = TRUE)
    }
  )

  expect_equal(nrow(mx_data), 1L)
  expect_true("server" %in% names(mx_data))
})

test_that("API DOI lookup cleans a single record", {
  raw <- sample_raw_api_data()[1, , drop = FALSE]

  with_test_bindings(
    environment(mx_api_doi),
    list(api_to_df = function(url) list(collection = raw)),
    {
      mx_data <- mx_api_doi("10.1101/2020.01.02.1")
    }
  )

  expect_equal(nrow(mx_data), 1L)
  expect_true(all(c("link_page", "link_pdf") %in% names(mx_data)))
  expect_false("server" %in% names(mx_data))
})

test_that("API pagination metadata uses total records and page count", {
  messages <- data.frame(
    status = "ok",
    category = "all",
    interval = "2013-01-01:2026-05-05",
    funder = "all",
    cursor = 0,
    count = 30,
    count_new_papers = "329541",
    total = "453478"
  )

  expect_equal(api_record_count(messages), 453478)
  expect_equal(api_page_size(messages), 30)
  expect_true(is.na(api_metadata_number(data.frame(), "total")))
  expect_equal(api_page_size(data.frame(count = 0)), 100L)
})

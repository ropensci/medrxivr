mx1 <-
  mx_search(
    data = mx_api_content(),
    query = "dementia",
    from_date = "2019-01-01",
    to_date = "2020-01-01"
  )

mx_data <-
  mx_api_content(
    from_date = "2019-01-01",
    to_date = "2020-01-01",
    include.info = TRUE
  )

mx2 <-
  mx_search(
    data = mx_data,
    query = "dementia"
  )

test_that("Check data inputs return the same no. of results", {
  skip_if_offline()
  expect_equal(nrow(mx1), nrow(mx2))
})

test_that("Check number of columns in include.info output", {
  skip_if_offline()
  expect_equal(ncol(mx_data), 20)
})


mx_data <- mx_api_doi("10.1101/2020.02.25.20021568")

test_that("Check number of columns in output", {
  skip_if_offline()
  expect_equal(ncol(mx_data), 14)
})

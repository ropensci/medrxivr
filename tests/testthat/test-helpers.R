test_that("API to Dataframe", {
  skip_if_offline()
  skip_if_api_message()
  url <- "https://api.biorxiv.org/details/medrxiv/2020-06-21/2020-08-28/45"
  df <- api_to_df(url)$collection
  expect_identical(class(df), "data.frame")
})

test_that("Link modification", {
  url <- "https://api.biorxiv.org/details/medrxiv/2018-08-21/2018-08-28"
  url2 <- api_link("medrxiv", "2018-08-21", "2018-08-28")
  expect_identical(url, url2)
})

test_that("No posts found - date range", {
  skip_if_offline()
  skip_if_api_message()
  # Check that function errors if first page is empty
  url <- "https://api.biorxiv.org/details/medrxiv/2022-06-21/2018-08-28/0"
  expect_error(api_to_df(url))
  # Check it doesn't error if on anything other than the first page This allows
  # for elegant handling of the discrepancy between the metadata total number
  # and the actual number available
  url <- "https://api.biorxiv.org/details/medrxiv/2022-06-21/2018-08-28/100"
  expect_equal(api_to_df(url)$collection, list())

})

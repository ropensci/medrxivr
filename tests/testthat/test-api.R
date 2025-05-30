# test_that("Check data inputs return the same no. of results", {
#   skip_on_cran()
#   skip_if_offline()
#   skip_if_api_message()
#   mx1 <-
#     mx_search(
#       data = mx_snapshot("576302fc697f772ddafd24c68ef9ff510994b1a1"),
#       query = "dementia",
#       from_date = "2019-01-01",
#       to_date = "2020-01-01"
#     )
#
#   mx_data <-
#     mx_api_content(
#       from_date = "2019-01-01",
#       to_date = "2020-01-01",
#       include_info = TRUE
#     )
#
#   mx2 <-
#     mx_search(
#       data = mx_data,
#       query = "dementia"
#     )
#
#   expect_equal(nrow(mx1), nrow(mx2))
# })

# test_that("Check number of columns in include_info output", {
#   skip_on_cran()
#   skip_if_offline()
#   skip_if_api_message()
#   mx_data <-
#     mx_api_content(
#       from_date = "2019-01-01",
#       to_date = "2020-01-01",
#       include_info = TRUE
#     )
#   expect_equal(ncol(mx_data), 21)
# })

# test_that("Check number of columns in output", {
#   skip_on_cran()
#   skip_if_offline()
#   skip_if_api_message()
#   expect_equal(ncol(mx_api_doi("10.1101/2020.02.25.20021568")), 15)
# })

test_that("Server not recognised", {
  skip_if_offline()
  expect_error(mx_api_content(server = "medRxiv"))
  expect_error(mx_api_doi(server = "medRxiv"))
})

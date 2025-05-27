test_that("Require file", {
  expect_error(mx_export())
})

# mx_result <- mx_search(mx_snapshot(),
#   query = c("dementia"),
#   to_date = "2020-01-01",
# )

# tmpfile <- tempfile(fileext = ".bib")

# test_that("Inital output", {
#   skip_if_offline()
#   expect_message(mx_export(mx_result,tmpfile),
#                  regexp = "References exported to")
# })

# testthat::test_that("Inital output", {
#   skip_if_offline()
#   expect_identical(file.exists(tmpfile), TRUE)
# })

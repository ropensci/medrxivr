test_that("Require file", {
  expect_error(mx_export())
})

if (file.exists("medrxiv_export.bib") == TRUE) {
  unlink("medrxiv_export.bib", recursive = TRUE)
}

mx_result <- mx_search(mx_snapshot(), query = c("dementia"), to_date = "2020-01-01")

test_that("Inital output", {
  skip_if_offline()
  expect_message(mx_export(mx_result), regexp = "References exported to")
})

testthat::test_that("Inital output", {
  skip_if_offline()
  expect_identical(file.exists("medrxiv_export.bib"), TRUE)
})

if (file.exists("medrxiv_export.bib") == TRUE) {
  unlink("medrxiv_export.bib", recursive = TRUE)
}

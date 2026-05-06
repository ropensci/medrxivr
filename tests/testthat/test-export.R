test_that("Export requires data", {
  expect_error(mx_export())
})

test_that("Export writes a BibTeX file for search results", {
  mx_result <- suppressMessages(mx_search(
    sample_preprint_data(),
    query = "Dementia",
    deduplicate = TRUE
  ))
  tmpfile <- tempfile(fileext = ".bib")

  expect_message(mx_export(mx_result, tmpfile), "References exported to")
  expect_true(file.exists(tmpfile))
  expect_match(paste(readLines(tmpfile, warn = FALSE), collapse = "\n"), "Dementia biomarker study")
})

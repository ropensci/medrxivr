test_that("Crosscheck count comparison reports new records", {
  expect_message(mx_crosscheck_counts(reference = 6L, extracted = 5L), "1 new record")
})

test_that("Crosscheck count comparison reports matching counts", {
  expect_message(mx_crosscheck_counts(reference = 5L, extracted = 5L), "No records")
})

test_that("Crosscheck count comparison errors when API metadata count is unavailable", {
  expect_error(mx_crosscheck_counts(reference = NA_real_, extracted = 5L), "Reference value")
})

test_that("Crosscheck uses API metadata and snapshot counts", {
  with_test_bindings(
    environment(mx_crosscheck),
    list(
      internet_check = function() TRUE,
      mx_info = function(...) invisible("2026-05-06"),
      api_to_df = function(url) sample_api_response(total = 6L),
      mx_snapshot = function(...) sample_preprint_data()
    ),
    {
      expect_message(mx_crosscheck(), "1 new record")
    }
  )
})

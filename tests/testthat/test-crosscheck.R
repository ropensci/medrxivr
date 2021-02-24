test_that("Check crosscheck produces message", {
  skip_if_offline()
  skip_if_api_message()
  expect_message(mx_crosscheck())
})

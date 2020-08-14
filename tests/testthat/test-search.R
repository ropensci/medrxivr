test_that("Error handling", {
  expect_error(mx_search())
  expect_error(mx_search(data = 2))
})


mx_data <- mx_snapshot()

mx0 <- mx_search(mx_data, query = "*")

test_that("Check number of columns", {
  skip_if_offline()
  expect_equal(dim(mx0)[2], 14)
})

mx1 <-
  mx_search(mx_data,
    query = "dementia",
    from_date = "2019-01-01",
    to_date = "2020-01-01"
  )
mx2 <-
  mx_search(mx_data, query = c("dementia"), to_date = "2020-01-01")
mx3 <-
  mx_search(mx_data, query = list("dementia"), to_date = "2020-01-01")


test_that("Different formats - same search", {
  skip_if_offline()
  expect_equal(length(mx1$ID), 24)
  expect_equal(length(mx1$ID), length(mx2$ID))
  expect_equal(length(mx1$ID), length(mx3$ID))
  expect_equal(length(mx2$ID), length(mx3$ID))
})

mx4 <- mx_search(mx_data, query = c("dementia", "lipid"))
mx5 <- mx_search(mx_data, query = list("dementia", "lipid"))

test_that("Different formats - different search", {
  skip_if_offline()
  expect_false(length(mx4$ID) == length(mx5$ID))
})

mx6 <- mx_search(mx_data, query = "dementia", deduplicate = TRUE)
mx7 <- mx_search(mx_data, query = "dementia", deduplicate = FALSE)

test_that("Deduplication", {
  skip_if_offline()
  expect_false(length(mx6$ID) == length(mx7$ID))
})

mx8 <- mx_search(mx_data, query = "dementia", NOT = "dementia")

test_that("NOT", {
  skip_if_offline()
  expect_message(mx_search(mx_data, query = "dementia", NOT = "dementia"),
    regexp = "No records found"
  )
})

mx9 <-
  mx_search(mx_data, query = list("dementia", "Alz", "vascular"))
mx10 <-
  mx_search(mx_data, query = list("dementia", "Alz", "vascular", "sex"))
mx11 <-
  mx_search(mx_data, query = list(
    "dementia", "Alz", "vascular", "sex",
    "asthma"
  ))

test_that("Multiple topics", {
  skip_if_offline()
  expect_true(length(mx10$ID) <= length(mx9$ID))
  expect_true(length(mx11$ID) <= length(mx10$ID))
})

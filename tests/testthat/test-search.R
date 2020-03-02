mx0 <- mx_search("*")

test_that("Check number of columns", {
  skip_if_offline()
  expect_equal(dim(mx0)[2],12)
})

mx1 <- mx_search("dementia", from.date = 20190101, to.date = 20200101)
mx2 <- mx_search(c("dementia"),to.date = 20200101)
mx3 <- mx_search(list("dementia"),to.date = 20200101)


test_that("Different formats - same search", {
  skip_if_offline()
  expect_equal(length(mx1$node), 24)
  expect_equal(length(mx1$node), length(mx2$node))
  expect_equal(length(mx1$node), length(mx3$node))
  expect_equal(length(mx2$node), length(mx3$node))
})

mx4 <- mx_search(c("dementia","lipid"))
mx5 <- mx_search(list("dementia","lipid"))

test_that("Different formats - different search", {
  skip_if_offline()
  expect_false(length(mx4$node)==length(mx5$node))
})

mx6 <- mx_search("dementia", deduplicate = TRUE)
mx7 <- mx_search("dementia", deduplicate = FALSE)

test_that("Deduplication", {
  skip_if_offline()
  expect_false(length(mx6$node)==length(mx7$node))
})

mx8 <- mx_search("dementia", NOT = "dementia")

test_that("NOT", {
  skip_if_offline()
  expect_equal(length(mx8$node), 0)
})

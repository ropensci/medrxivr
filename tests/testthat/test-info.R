test_that("Printed message", {
  expect_message(mx_info())
})

test_that("Snapshot date message reports newest record date", {
  snapshot <- data.frame(date = c("2021-01-03", "2021-02-04"))

  expect_message(
    inform_snapshot_date(snapshot),
    "Snapshot includes records through 2021-02-04",
    fixed = TRUE
  )
})

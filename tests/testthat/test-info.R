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

test_that("Snapshot manifest files are normalized", {
  manifest <- list(
    files = data.frame(
      name = "snapshot.csv.gz",
      url = "https://example.org/snapshot.csv.gz"
    )
  )

  files <- snapshot_manifest_files(manifest)

  expect_equal(files$name, "snapshot.csv.gz")
  expect_equal(files$url, "https://example.org/snapshot.csv.gz")
})

test_that("Snapshot date arguments parse consistently", {
  expect_equal(parse_snapshot_date("2021-01-02", "from_date"), as.Date("2021-01-02"))
  expect_equal(parse_snapshot_date(as.Date("2021-01-02"), "from_date"), as.Date("2021-01-02"))
  expect_null(parse_snapshot_date(NULL, "from_date"))
  expect_error(parse_snapshot_date("not-a-date", "from_date"))
})

test_that("Snapshot date filtering keeps expected rows", {
  snapshot <- data.frame(
    date = c("2021-01-01", "2021-02-01", "2021-03-01"),
    value = 1:3
  )

  filtered <- filter_snapshot_dates(
    snapshot,
    from_date = as.Date("2021-02-01"),
    to_date = as.Date("2021-02-28")
  )

  expect_equal(filtered$value, 2L)
})

test_that("Snapshot links are reconstructed from link and pdf columns", {
  snapshot <- data.frame(
    link = "/content/10.1101/123v1",
    pdf = "/content/10.1101/123v1.full.pdf"
  )

  snapshot <- reconstruct_snapshot_links(snapshot)

  expect_equal(snapshot$link_page, "https://www.medrxiv.org/content/10.1101/123v1")
  expect_equal(snapshot$link_pdf, "https://www.medrxiv.org/content/10.1101/123v1.full.pdf")
})

test_that("Snapshot links are reconstructed for empty snapshots", {
  snapshot <- data.frame(
    link = character(),
    pdf = character()
  )

  snapshot <- reconstruct_snapshot_links(snapshot)

  expect_equal(nrow(snapshot), 0L)
  expect_equal(snapshot$link_page, character())
  expect_equal(snapshot$link_pdf, character())
})

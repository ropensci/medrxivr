test_that("Snapshot date arguments parse consistently", {
  expect_equal(parse_snapshot_date("2021-01-02", "from_date"), as.Date("2021-01-02"))
  expect_equal(parse_snapshot_date(as.Date("2021-01-02"), "from_date"), as.Date("2021-01-02"))
  expect_null(parse_snapshot_date(NULL, "from_date"))
  expect_error(parse_snapshot_date("", "from_date"))
  expect_error(parse_snapshot_date("not-a-date", "from_date"))
  expect_error(parse_snapshot_date("2021-13-01", "from_date"))
  expect_error(parse_snapshot_date(20200102, "from_date"))
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

test_that("Snapshot reads manifest release assets without legacy repository fallback", {
  snapshot_file <- tempfile(fileext = ".csv")
  utils::write.csv(sample_preprint_data(), snapshot_file, row.names = FALSE)

  manifest_file <- tempfile(fileext = ".json")
  jsonlite::write_json(
    list(
      version = 1L,
      generated_at = "2026-05-06T00:00:00Z",
      snapshot_date = "2026-05-06",
      record_count = 5L,
      files = list(list(name = basename(snapshot_file), url = snapshot_file))
    ),
    manifest_file,
    auto_unbox = TRUE
  )

  expect_message(
    snapshot <- mx_snapshot(
      manifest_url = manifest_file,
      from_date = "2020-02-01",
      to_date = "2020-04-30",
      cache = FALSE
    ),
    "Snapshot includes records through 2020-04-05"
  )
  expect_equal(snapshot$node, 2:4)
  expect_true(all(grepl("^https://www.medrxiv.org/content/", snapshot$link_page)))
  expect_error(mx_snapshot(commit = "legacy-sha", manifest_url = manifest_file), "no longer supported")
  expect_error(mx_snapshot(manifest_url = NULL), "manifest_url")
})

test_that("Snapshot manifest validation catches malformed manifests", {
  expect_error(snapshot_manifest_files(list()), "files")
  expect_error(snapshot_manifest_files(list(files = data.frame(name = "snapshot.csv"))), "name.*url")
})

test_that("Snapshot file reader handles gzipped CSV assets", {
  snapshot_file <- tempfile(fileext = ".csv.gz")
  con <- gzfile(snapshot_file, open = "wt")
  utils::write.csv(sample_preprint_data()[1:2, ], con, row.names = FALSE)
  close(con)

  snapshot <- read_snapshot_files(snapshot_file)

  expect_equal(nrow(snapshot), 2L)
  expect_equal(snapshot$date, c("2020-01-02", "2020-02-03"))
})

test_that("Snapshot caching stores local copies and reuses cached files", {
  snapshot_file <- tempfile(fileext = ".csv")
  utils::write.csv(sample_preprint_data()[1:2, ], snapshot_file, row.names = FALSE)
  cache_name <- paste0("test-snapshot-cache-", as.integer(Sys.time()), "-", Sys.getpid(), ".csv")
  files <- data.frame(
    name = cache_name,
    url = paste0("file:///", normalizePath(snapshot_file, winslash = "/"))
  )

  cached <- cache_snapshot_files(files, cache = TRUE)
  expect_true(file.exists(cached))

  writeLines("changed source", snapshot_file)
  cached_again <- cache_snapshot_files(files, cache = TRUE)
  expect_identical(cached_again, cached)
  expect_equal(nrow(read_snapshot_files(cached_again)), 2L)
})

test_that("Snapshot reader handles plain CSV assets", {
  snapshot_file <- tempfile(fileext = ".csv")
  utils::write.csv(sample_preprint_data()[1, ], snapshot_file, row.names = FALSE)

  snapshot <- read_snapshot_file(snapshot_file)

  expect_equal(nrow(snapshot), 1L)
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

test_that("Snapshot information reads manifest date and rejects legacy commits", {
  manifest_file <- tempfile(fileext = ".json")
  jsonlite::write_json(
    list(snapshot_date = "2026-05-06", files = list()),
    manifest_file,
    auto_unbox = TRUE
  )

  expect_message(mx_info(manifest_url = manifest_file), "2026-05-06")
  expect_error(mx_info(commit = "legacy-sha", manifest_url = manifest_file), "no longer supported")

  missing_date <- tempfile(fileext = ".json")
  jsonlite::write_json(list(files = list()), missing_date, auto_unbox = TRUE)
  expect_error(mx_info(manifest_url = missing_date), "snapshot_date")

  expect_true(is.na(inform_snapshot_date(data.frame(title = "no date"))))
})

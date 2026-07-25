test_that("Download requires results and a directory", {
  expect_error(mx_download())
})

test_that("Download writes files, handles existing files, and supports names", {
  source_pdf <- tempfile(fileext = ".pdf")
  writeLines("not really a pdf", source_pdf)
  source_url <- paste0("file:///", normalizePath(source_pdf, winslash = "/"))
  tmpdir <- tempfile()

  mx_result <- data.frame(
    link_pdf = source_url,
    ID = "271",
    doi = "10.1101/19003301",
    stringsAsFactors = FALSE
  )

  expect_message(mx_download(mx_result, tmpdir, print_update = 1), "Downloading")
  expect_true(file.exists(file.path(tmpdir, "271_10.1101_19003301.pdf")))

  expect_message(mx_download(mx_result, tmpdir), "already downloaded")

  id_dir <- tempfile()
  expect_message(mx_download(mx_result, id_dir, name = "ID"), "Downloading")
  expect_true(file.exists(file.path(id_dir, "271.pdf")))

  doi_dir <- tempfile()
  expect_message(mx_download(mx_result, doi_dir, name = "DOI"), "Downloading")
  expect_true(file.exists(file.path(doi_dir, "10.1101_19003301.pdf")))
})

test_that("Download retries are bounded and invalid inputs fail clearly", {
  bad_result <- data.frame(
    link_pdf = "file:///this/path/does/not/exist.pdf",
    ID = "1",
    doi = "10.1101/missing",
    stringsAsFactors = FALSE
  )
  old_options <- options(medrxivr.download_retries = 1L)
  on.exit(options(old_options), add = TRUE)

  expect_error(mx_download(bad_result, tempfile()), "after 1 attempts")
  expect_error(mx_download(data.frame(), tempfile()), "link_pdf")
  expect_error(mx_download(bad_result, tempfile(), print_update = 0), "positive whole")
})

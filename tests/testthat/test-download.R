test_that("Require file", {
  skip_if_offline()
  expect_error(mx_download())
})

mx_result <-
  data.frame(
    link_pdf = "https://www.medrxiv.org/content/10.1101/19003301v4.full.pdf",
    ID = "271",
    doi = "10.1101/19003301"
  )

test_that("Inital output", {
  skip_if_offline()
  expect_message(mx_download(mx_result, "pdf"), regexp = "Downloading")
})

test_that("Already downloaded", {
  skip_if_offline()
  expect_message(mx_download(mx_result, "pdf"), regexp = "downloaded")
})

test_that("Naming of downloaded PDFs", {
  skip_if_offline()
  mx_download(mx_result, "pdf", name = "ID")
  expect_equal(file.exists("pdf/271.pdf"), TRUE)
  mx_download(mx_result, "pdf", name = "DOI")
  expect_equal(file.exists("pdf/10.1101_19003301.pdf"), TRUE)
})

if (dir.exists("pdf") == TRUE) {
  unlink("pdf", recursive = TRUE)
}

test_that("Status update", {
  skip_if_offline()
  expect_message(mx_download(mx_result, "pdf", print_update = 1), regexp = "%")
})

if (dir.exists("pdf") == TRUE) {
  unlink("pdf", recursive = TRUE)
}

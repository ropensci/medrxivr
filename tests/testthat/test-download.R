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

tmpdir <- tempdir()

test_that("Inital output", {
  skip_on_cran()
  skip_if_offline()
  expect_message(mx_download(mx_result, tmpdir), regexp = "Downloading")
})

test_that("Already downloaded", {
  skip_on_cran()
  skip_if_offline()
  expect_message(mx_download(mx_result, tmpdir), regexp = "downloaded")
})

test_that("Naming of downloaded PDFs", {
  skip_on_cran()
  skip_if_offline()
  mx_download(mx_result, tmpdir, name = "ID")
  expect_equal(file.exists(paste0(tmpdir,"/271.pdf")), TRUE)
  mx_download(mx_result, tmpdir, name = "DOI")
  expect_equal(file.exists(paste0(tmpdir,"/271_10.1101_19003301.pdf")), TRUE)
})

mx_result <-
  data.frame(
    link_pdf = paste0("https://www.medrxiv.org/content/",
                      "10.1101/2020.09.23.20197558v1.full.pdf"),
             ID = "272",
             doi = "10.1101/2020.09.23.20197558")

test_that("Status update", {
  skip_on_cran()
  skip_if_offline()
  expect_message(mx_download(mx_result,
                             tmpdir,
                             print_update = 1),
                 regexp = "%")
})

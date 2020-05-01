test_that("Require file", {
  skip_if_offline()
  expect_error(mx_download())
})


mx_result <- data.frame(link_pdf = "https://medrxiv.org/content/10.1101/19007328v2.full.pdf",
                        ID = "69465")

test_that("Inital output", {
  skip_on_cran()
  skip_on_travis()
  skip_if_offline()
  expect_message(mx_download(mx_result, "pdf"), regexp = "Downloading")
})

test_that("Already downloaded", {
  skip_on_cran()
  skip_on_travis()
  skip_if_offline()
  expect_message(mx_download(mx_result, "pdf"), regexp = "downloaded")
})

if (dir.exists("pdf")==TRUE){
unlink("pdf", recursive = TRUE)
}

test_that("Status update", {
  skip_on_cran()
  skip_on_travis()
  skip_if_offline()
  expect_message(mx_download(mx_result, "pdf", print_update = 1), regexp = "%")
})

if (dir.exists("pdf")==TRUE){
  unlink("pdf", recursive = TRUE)
}





test_that("Require file", {
  skip_if_offline()
  expect_error(mx_download())
})


mx_result <- data.frame(pdf = "/content/10.1101/19007328v2.full.pdf",
                        node = "69465")

test_that("Inital output", {
  skip_on_cran()
  skip_if_offline()
  expect_output(mx_download(mx_result, "pdf"), regexp = "Downloading")
})

test_that("Already downloaded", {
  skip_if_offline()
  expect_output(mx_download(mx_result, "pdf"), regexp = "downloaded")
})

if (dir.exists("pdf")==TRUE){
unlink("pdf", recursive = TRUE)
}

test_that("Status update", {
  skip_on_cran()
  skip_if_offline()
  expect_output(mx_download(mx_result, "pdf", print_update = 1), regexp = "%")
})

if (dir.exists("pdf")==TRUE){
  unlink("pdf", recursive = TRUE)
}




<!-- README.md is generated from README.Rmd. Please edit that file -->

# medrxivr

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<br> [![Travis build
status](https://travis-ci.com/mcguinlu/medrxivr.svg?branch=master)](https://travis-ci.com/mcguinlu/medrxivr)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/mcguinlu/medrxivr?branch=master&svg=true)](https://ci.appveyor.com/project/mcguinlu/medrxivr)
[![Codecov test
coverage](https://codecov.io/gh/mcguinlu/medrxivr/branch/master/graph/badge.svg)](https://codecov.io/gh/mcguinlu/medrxivr?branch=master)
<!-- badges: end -->

The goal of medrxivr is to provide programmatic access to the medRxiv
preprint repository.

## Installation

You can install the development version of this package using:

``` r
devtools::install_github("mcguinlu/medrxivr")
```

## Example

To get the entire meddataset to play around with, use the following
command:

``` r

mx_results <- mx_search("*")
```

For a simple search strategy:

``` r

mx_results <- mx_search("dementia")
```

To find records that contain one of many keywords:

``` r

myquery <- c("dementia","vascular","alzheimer's") # Combined with OR

mx_results <- mx_search(myquery)
```

To combine different topic domains:

``` r

topic1  <- c("dementia","vascular","alzheimer's")  # Combined with OR
topic2  <- c("lipids","statins","cholesterol")     # Combined with OR
myquery <- list(topic1, topic2)                    # Combined with AND

mx_results <- mx_search(myquery)
```

# Download PDFs

Pass the results of your search above to the `mx_download()` function to
download a copy of the PDF for each record. Note: PDFs are saved using
the value of the `node` column in the dataset, which serves as a unique
identifier for each record.

``` r

mx_download(mx_results,     # Object returned by mx_search
            "pdf/",         # Directory to save PDFs to 
            create = TRUE)  # Create the directory if it doesn't exist
```

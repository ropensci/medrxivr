
<!-- README.md is generated from README.Rmd. Please edit that file -->

# medrxivr <img src="man/figures/hex-medrxivr.png" align="right" width="20%" height="20%" />

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

`medrxivr` provides programmatic access to the [medRxiv
API](https://api.biorxiv.org/), in addition to a static snapshot of the
*medRxiv* preprint repository which is automatically updated each
morning. `medrxivr` also provides functions to search medRxiv records
using regular expressions and Boolean logic, and provides a helper
function to download the full-text PDFs of relevant preprints.

**Note:** `medrxivr` is now available as a web-app, which lets you build
complex searches via a user-friendly interface, explore the results and
export them for screening. In an effort to improve reproducibility, it
also creates the code needed to run the search straight from R. The app
is available [here.](https://mcguinlu.shinyapps.io/medrxivr/)

## Installation

You can install the development version of this package using:

``` r
devtools::install_github("mcguinlu/medrxivr")
library(medrxivr)
```

## Usage

### Perform a simple search using a copy of the database from the API

`mx_api_content()` provides programmatic access to the medRxiv API.
However, the API does not allow you to search the database. Instead, you
can download a copy of the database yourself via the medRxiv API, and
then pass the resulting object to the `mx_search()` function for
searching. This can be useful if you wish to document the exact time and
data of your extraction.

``` r

medrxiv_data <- mx_api_content()

results <- mx_search(data = medrxiv_data,
                     query ="dementia")
```

Alternatively, this can be done all in one step using a piped workflow:

``` r
library(dplyr)

results <- mx_api() %>%
           mx_search(query = "dementia")
```

### Perform a simple search using the daily snapshot of the database

An alternative to the approach detailed above is to search a daily
snapshot of the database, taken each morning using the
`mx_api_content()` function. Searches performed using this method do not
rely on the API (which can become unavilable during peak times) and are
usually faster (as it reads data from a CSV rather than having to
re-extract it from the API). Information on the snapshot you are using
is reported.

``` r
library(medrxivr)

results <- mx_search(query = "dementia")
#> Using medRxiv snapshot - 2020-05-26 14:16
#> Found 70 record(s) matching your search.
```

### Download PDFs for returned records

Pass the results of your search above to the `mx_download()` function to
download a copy of the PDF for each record.

``` r

mx_download(mx_results,     # Object returned by mx_search
            "pdf/",         # Directory to save PDFs to 
            create = TRUE)  # Create the directory if it doesn't exist
```

## Code of conduct

Please note that the `medrxivr` project is released with a [Contributor
Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project,
you agree to abide by its terms.

## Disclaimer

This package and the data it accesses/returns are provided “as is”, with
no guarantee of accuracy. Please be sure to check the accuracy of the
data yourself (and do let me know if you find an issue so I can fix it
for everyone\!)

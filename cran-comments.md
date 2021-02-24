## Required submission to retain package on CRAN
This submission was prompted by an email from CRAN, requiring that tests fail 
gracefully when the internet resource the package is based on is unavailable.

## Test environments

* local windows R installation, R 4.0.2
* windows-latest (via GitHub actions), (release)
* macOS-latest (via GitHub actions), (release)
* ubuntu-20.04 (via GitHub actions), (release, devel)
* win-builder (devel)

## R CMD check results

0 errors | 0 warnings | 0 notes

## CRAN Checks 

CRAN checks are currently failing on a single platform 
(r-devel-windows-ix86+x86_64), but the changes contained in this release will 
address this.

## Downstream dependencies

There are currently no downstream dependencies for this package.

## Test environments

* local windows R installation, R 3.6.1
* windows-latest (via GitHub actions), (release)
* macOS-latest (via GitHub actions), (release)
* ubuntu-20.04 (via GitHub actions), (release, devel)
* win-builder (devel)

## R CMD check results

0 errors | 0 warnings | 0 notes

## CRAN Checks 

CRAN checks (https://cran.rstudio.com//web/checks/check_results_medrxivr.html) 
show that the build is failing on two platforms:

* r-patched-linux-x86_64
* r-devel-linux-x86_64-debian-gcc

I am not sure why and haven't been able to reproduce it locally, so any advice 
you could give me to fix this if it is a persistent issue would be much 
appreciated. I've copied the error message below for reference:

> terminate called after throwing an instance of 'std::system_error'
> what(): Resource temporarily unavailable
> Aborted

## Downstream dependencies

There are currently no downstream dependencies for this package.

## Resubmission
This is a resubmission. In this version I have:

* Wrapped package names, software names and API names in single quotes in title
and description (Sorry that I missed one last time!)

* Replaced \dontrun with \donttest in all examples, as requested.

* Replaced the long-running example for mx_download() so that only a single PDF
is downloaded.

* Ensured that examples/vignettes do not modify the user's home filespace in
the examples, vignettes, and tests. All previous hardcoded file and directory
locations have been replaced using tempfile() and tempdir(), respectively.

## Test environments

* local windows R installation, R 3.6.1
* windows-latest (via GitHub actions), (release)
* macOS-latest (via GitHub actions), (release)
* ubuntu-20.04 (via GitHub actions), (release, devel)
* win-builder (devel)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

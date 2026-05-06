## Resubmission

This package was archived on 2025-05-27 for a policy violation related to
Internet access during checks. This resubmission addresses that by:

* Guarding live API examples and package checks so transient external service
  failures or rate limits do not produce check failures.
* Moving the maintained medRxiv snapshot to repository release assets, with a
  manifest-driven reader.
* Updating GitHub Actions dependencies and release-platform CI.
* Declaring `Depends: R (>= 4.1.0)` for native pipe syntax.
* Updating package documentation to use the canonical CRAN package page:
  <https://CRAN.R-project.org/package=medrxivr>.

## Test environments

* Local Windows 11, R 4.4.2
* GitHub Actions:
  * Windows latest, R release
  * Ubuntu 24.04, R release
  * macOS latest, R release

## R CMD check results

Local checks produce no ERRORs or WARNINGs.

Known local NOTEs:

* New submission / package archived on CRAN. This is expected for a package
  returning from the archive.
* README.md and NEWS.md cannot be checked locally without pandoc installed.
  GitHub Actions checks install pandoc.
* Unable to verify current time. This is local-environment specific.

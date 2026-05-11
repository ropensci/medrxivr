## Resubmission

This resubmission fixes the CRAN Additional issue reported under `donttest`,
where the snapshot-cache unit test left a temporary file in the user cache
directory during checks.

This update is submitted shortly after version 0.1.3 in response to the CRAN
Team request to correct the Additional issue before 2026-05-24.

The previous resubmission addressed the earlier Internet-access archive issue
by:

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

Unit tests pass locally with 100% measured coverage by `covr`.

`R CMD check --run-donttest --no-manual --as-cran` returns OK locally.

Known local NOTEs:

* Days since last update. This is expected because this is a prompt
  maintenance release requested by the CRAN Team.
* Unable to verify current time. This is local-environment specific.

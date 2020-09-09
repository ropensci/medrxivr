# medrxivr 0.0.3

Version created for submission to JOSS and CRAN, and onboarded to rOpenSci following peer-review.

Major changes:

* `mx_snapshot()` now takes a `commit` argument, allowing you to specify exactly which snapshot of the database you would like to use. Details on the commit keys needed are [here](https://github.com/mcguinlu/medrxivr-data/commits/master/snapshot.csv). In addition, the process of taking the snapshot is now managed by GitHub actions, meaning it should be a lot more robust/regular/
* Importing the snapshot to R is now significantly faster, as `vroom::vroom()` is used in place of `read.csv()`
* All functions that return a data frame now return ungrouped tibbles.
* The  to/from date arguments for both `mx_search()` and `mx_api_content()` have been standardized to snake case and now expect the same "YYYY-MM-DD" character format.
* A progress indicator has been added to `mx_api_content()` provide useful information when downloading from the API.
* Some refactoring of code has taken place to reduce duplication of code chunks and to make future maintenance easier.

Minor changes:

* `mx_crosscheck()` no longer uses web-scraping when providing the number of 
* Documentation has been updated to reflect the changes, and some additional sections added to the vignettes. This includes removing references to older versions of the functions names (e.g. `mx_raw()`).
* Additional test have been written, and the overall test coverage has been increased. Some lines (handling exceptional rare errors that can't be mocked) have been marked as `#nocov`.




# medrxivr 0.0.2

Major changes: 

* Following the release of the [medRxiv API](https://api.biorxiv.org/), the way the snapshot of the medRxiv site is taken has changed, resulting in a more accurate snapshot of the entire repository being taken daily (as opposed to just new articles being captured, as was previously the case). This has introduced some breaking changes (e.g. in the `fields` argument, "subject" has become "category", and "link" has become "doi"), but will result in better long-term stability of the package.
* Two new functions, `mx_api_content()` and `mx_api_doi()`, have been added to allow users to interact with the medRxiv API endpoints directly. A new vignette documenting these functions has been added. 
* The API has also allowed for improved data collection. The "authors" variable searched/returned now contains all authors of the paper as opposed to just the first one. Several additional fields are now returned, including corresponding author's institution, preprint license, and the DOI of the published, peer-reviewed version of preprint (if available).
* A companion app was launched, which allows you to build the search strategy using a user-friendly interface and then export the code needed to run it directly from R. 
* You can now define the field(s) you wish to search. By default, the Title, Abstract, First Author, Subject, and Link (which includes the DOI) fields are searched. 
* There is no longer a limit on the number of distinct topics you can search for (previously it was 5).
* The output of `mx_search()` has been cleaned to make it more useful to future end-users. Of note, some of the columns names have changed, and the "pdf_name" and "extraction_date" variables are no longer returned.


# medrxivr 0.0.1

* Added a `NEWS.md` file to track changes to the package.

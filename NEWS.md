# medrxivr 0.0.5

Major changes:

* Improved error handling to address a common bug that causes extraction from the API to fail. The "total number" of records element of the API metadata is frequently artificially inflated. This leads to an overestimation of the number of pages of records, which in turn caused the extraction function to fail at the very end when `mx_api_content()` encounters an empty page. This error has been changed to informative messaging about the expected (as per the metadata) and actual (`nrows()` of returned dataset) number of retrievable records.
* New functionality added to `mx_search()` allows users to view the number of "hits" (records returned) for each individual element of the search. An extra parameter called `report` has been added, which gives the user the option to switch this functionality on or off. The default value for this parameter is set to FALSE. This functionality was added by [James O'Hare](https://github.com/jamesohare1) in response to [Issue #13.](https://github.com/ropensci/medrxivr/issues/13)
* Users can now pass a vector of terms to the `NOT` parameter rather than a single exclusion term.
* New functionality to allow for user-friendly search operators, including wildcards ("randomi*ation" will now find "randomisation" and "randomization") and the NEAR operator ("systematic NEAR1 review" will find "systematic review" and "systematic _<any-other-word>_ review")
* A new argument, `auto_caps`, in the `mx_search()` function to allow for automatic capitalisation of the first character in each search term (e.g. with `auto_caps = TRUE`, "dementia" will be automatically converted to "[Dd]ementia" which will find "**d**ementia" and also "**D**ementia"). This replaces the recommendation that users capitalise the first character themselves using square brackets. However, if user defined alternative are already in place for the first character of the search term, then these are left untouched.
* A helper function, `mx_caps()`, allows users to wrap search terms to find all possible combinations of upper- and lower-case letters in that term. For example, `mx_caps("ncov")` converts the term to "[Nn][Cc][Oo][Vv]" which will find "NCOV", "Ncov", "nCOV", "nCoV", etc.

# medrxivr 0.0.4

Major changes:

* Fixed error which occurred when downloading the whole bioRxiv database. This was caused by any record above 100000 being presented in scientific notation (e.g. 1e+05), which meant the API returned an invalid response.
* Change tests to fix runtime regardless of future growth of the repositories

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
* \dontrun had been replaced with \donttest in all examples across the package. 
* All examples for mx_download() and mx_export() now use tempfile() and tempdir(), so as not to modify the users home filespace when running the examples.




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

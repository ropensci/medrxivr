# medrxivr 0.0.2

Major changes:

* Following the release of the [medRxiv API](https://api.biorxiv.org/), the way the snapshot of the medRxiv site is taken has changed, resulting in a more accurate snapshot of the entire repository being taken daily (as opposed to just new articles being captured, as was previously the case). This change introduces some breaking changes (e.g. )
* The API has also allowed for improved data collection. The "authors" variable searched/returned now contains all authors of the paper as opposed to just the first one. Several additional fields are now returned, including corresponding author's institution, preprint license, and the DOI of the published, peer-reviewed version of preprint (if available).
* A companion app was launched, which allows you to build the search strategy using a user-friendly interface and then export the code needed to run it directly from R. The app can be found [here](https://mcguinlu.shinyapps.io/medrxivr/).
* You can now define the field(s) you wish to search. By default, the Title, Abstract, First Author, Subject, and Link (which includes the DOI) fields are searched. 
* There is no longer a limit on the number of distinct topics you can search for (previously it was 5).
* The output of `mx_search()` has been cleaned to make it more useful to future end-users. Of note, some of the columns names have changed, and the "pdf_name" and "extraction_date" variables are no longer returned.


# medrxivr 0.0.1

* Added a `NEWS.md` file to track changes to the package.

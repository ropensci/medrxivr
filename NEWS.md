# medrxivr 0.0.2

Major changes:

* A companion app was launched, which allows you to build the search strategy using a user-friendly interface and then export the code needed to run it directly from R. The app can be found [here](https://mcguinlu.shinyapps.io/medrxivr/)
* You can now define the field(s) you wish to search. By default, the Title, Abstract, First Author, Subject, and Link (which includes the DOI) fields are searched. 
* There is no longer a limit on the number of distinct topics you can search for (previously it was 5).
* The output of `mx_search()` has been cleaned to make it more useful to future end-users. Of note, some of the columns names have changed, and the "pdf_name" and "extraction_date" variables are no longer returned.


# medrxivr 0.0.1

* Added a `NEWS.md` file to track changes to the package.


__I wonder if the returned data frames from the mx_api_* family could be also represented as tibbles?__
  * The package now returns tibbles across the board. I had never really understood the difference, but after a bit of research, I do prefer the printing defaults for `tibble` objects.

__The package does a good job in parsing and cleaning preprint metadata. Unfortunately, I cannot find documentation or an example showcasing what is actually returned. Can you provide one reproducible example in the README and/or extend the documentation in the function docs?__
  * Hoping I understood this ask correctly, there is now a section in the README that desribes how to access the raw, uncleaned API data using the `mx_api_*()` functions, which also points to a section in the [API article](https://mcguinlu.github.io/medrxivr/articles/medrxiv-api.html#accesing-the-raw-api-data) on the `pkgdown` website that provides more detail and an example of the uncleaned output. In addition, a clearer description of what the cleaning process entails has been included in the documention of the `mx_api_*()` functions (e.g. [here](https://mcguinlu.github.io/medrxivr/reference/mx_api_content.html))

__In the function docs of mx_export(), it says Dataframe returned by mx_search(), but I realised that also data obtained from the mx_api_ family can be exported as bib file using mx_export().__
  Thanks for this - I have updated the docs for the `mx_export()` function to read `@param data Dataframe returned by mx_search() or mx_api_*() functions`
  
@maurolepore, I have checked that my changes doen't throw any new errors, re-run `styler`/`spelling`
and commited any changes, and checked `goodpractice` doesn't recommend any changes. 

Hoping we are nearly there! 

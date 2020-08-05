# Overview

To start, thanks once again to everyone for your constructive comments! I've gone through all the posts above and have tried to extract all feedback here so that I can address it systematically. - please let me know if I have missed anything. Comments are divided by commenter and topic for ease of reference, and are presented in bold text, with the response immediately below.

I have also acknowledged both @tss and @njahn82 as reviewers in the `Description`, as I feel like your comments have added a great deal to the functionality/user-friendliness of the package. Please check your details just to make sure I have them correct!

<hr>

# Some key points about new functionality:

- [x] Function to save as a .bib file for import to reference management software (this functionality already existed for the app but hadn't been copied across to the package).

- [x] I have seperated out importing the snapshot into a seperate function (`mx_snapshot()`), rather than just using `mx_search(data= NULL)` to indicate that you want to use the snapshot. I think this will help users be very clear about which data source they are using, and was influenced by feedback from both reviewers about being confused re the data sources. 

- [x] Due to the fact that the API endpoints are identical for both medRxiv and bioRxiv and the fact that all interactions with the API have been centralised into a single function (thanks to reviewers feedback), coupled with demand from others in my group/people emailing me about it, the `mx_api_*()` functions now contain a `server` argument, allowing users to specify which server (medRxiv or bioRxiv) they want to interact with. Downloading the whole bioRxiv database does take a while, but users seem happy to do so rather than having to perform the searches and download the results manually via the website ([see here for an example](https://github.com/abannachbrown/MedrxivBiorxivSearches)). One thing I am worried about is whether to keep this as a happy bonus of the packages restructure following the reviews above, or whether to publicise it further/make it a key element of the package? Any advice/comments from reviewers/editors would be apprecited here!

# Editor (@maurolepore)

## Tasks 

- [x] Add rOpenSci badge to README
- [x] Fix spelling (ml3)
- [ ] Fix style (ml6)

## Discussion points

- [x] How big is the database? How fast does it grow? And how long does it take to download it in a range of reasonable conditions? What happens in a range of extreme conditions?  
As mentioned by @tss, there has been a substantial surge in the size of the database thanks to the COVID-19 pandemic. @tss reported times of 1.4 and 3.1 mins to download the database. I am not sure what is meant by extreme circumstances, but happy to do more testing if needed!

- [x] Is the process transparent and "polite" to the user?  
I'm not 100% sure what was meant by this comment. Re: interaction with medRxiv, all information is now taken from the API (previously `mx_info()` used web-scraping, but this is no longer the case) - is this what was meant?

<hr>

# Reviewer 1 (@tts)

## General comments

- [x] **Although the target group and the goal of the package are clearly defined, it took me some time to understand the core functionality. I suppose the main reason for this is the varying terminology of data sources used in vignettes and help pages.**  
In addition to adding your suggested diagram, I have tried to make the language used across the documentation more consistent, but please do point out anything that could be clearer!


## API
- [x] **Is there any way to gracefully stop the process if started by accident? . . . httr::RETRY is a new function to me. Thanks for this, I will definitely try to use it myself at some point. I wonder though if it allows a clean, user-friendly, forced exit and if yes, how should it be defined?**
  This is a great question, and to be honest, I am not sure how to implement this. Just so I'm sure we're on the same page, the issue is that because the httr::RETRY is nested within the larger function, hitting "Esc" or clicking "Stop" stops that iteration of httr:RETRY, which treats it like a failure and the retries the URL. This results in having to hit "Esc"/click "Stop" multiple times in order to actually get `mx_api_content()` to stop. Is this right? And maybe @njahn82 might have some clever ideas about this?

## Snapshot

- [x] **As of writing this, how long does it take to query the repo [via the snapshot]?**  
The rate limiting set of searching via the snapshot is how long it takes to read in the CSV file from the [medrxivr-data respository](https://github.com/mcguinlu/medrxivr-data). Thanks to the new set-up, which uses `vroom::vroom()` rather than `read.csv()`, this step is now subtantially faster. Trying `mx_search(query="molecular")`, I got an average search time of ~1 second (vs ~20 seconds previously, as per your review).
  
```{r}  
start_time <- Sys.time()
mx_results <- mx_search(query = "molecular")
end_time <- Sys.time()
(end_time - start_time)
```

```
Using medRxiv snapshot - 2020-07-22 06:02
Found 266 record(s) matching your search. 
Time difference of 1.014 secs
```


## Vignette/README

- [x] **The examples are a little confusing though because the functions shown are not the same; the first example uses mx_api_content, the second one mx_api which does not exists. I suppose mx_api is a typo, maybe the name of a former version? // In mx_search , the data argument is important because it defines the target. Again, the example in the help file is slightly misleading because there is no mx_raw function. A former version this one too I presume?**  
This is completely my bad. I thought I caught all references to this old function name, but obviously didn't. All references to `mx_api()` and `mx_raw()` have been removed/replaced as necessary.

- [x] **One minor thing about this example . . . The NOT argument does not match to Mild cognitive impairment which is found in one abstract, so perhaps better to use the form of [mM]ild cognitive impairment instead.**  
Thanks for catching this - I've changed the example to reflect this.

## Download

-[x] **Note: the mx_download help file example of mx_search uses a limit argument which is not defined.**  
Thanks for catching this - removed now!

## Shiny app

- [ ] **However, there are some issues with the code [produced by the app]. Both the basic and advanced search codes throw an error when run in R.**  
This was due to the fact that the `data` argument now comes first in order to make it compatible with piping, meaning that the example code from the app was trying to pass the search terms to the `data` argument. This has been corrected, and the reproducible code should now work! 

- [x] **When I ran mx_search with zero arguments, my first thought was that there are some issues with error handling. The query starts but clearly you need to include the search string too! However, after some time the error handling kicks in and correctly reminds me of the missing query argument. If I am not mistaken, the delay was caused by the latency of the default data source in the GitHub repository.**  
I've added a check to make sure that the `data`/`query` arguments are not empty very early on (prior to the rate limiting step of reading data from the GitHub repo), meaning that it fails fast and gracefully if no data source/search terms are provided.

```{r}
mx_search()
```

```
Error in mx_search() : 
  Please provide medRxiv data to search, accessed from either from either the mx_api_content(), or mx_snapshot() functions.
```

<hr>

# Reviewer 2 (@njahn82)

## General comments

- [x] **My main concern with this approach is that dependencies, which are not part of the package, are loaded, and in one case installed. The code outside of the R folder also lacks documentation using roxygen tags and tests, and there's some redundancy. I feel that R code not part of the {medrxivr} package build either needs to be factored out should be moved into the R/ directory.**  
In response to this comments, the elements of this package that are beyond the core functionality (namely the snapshot creation and the code for web-app) have been moved into their own individual repositories, and cross-linked within the README. See here for the [snapshot](https://github.com/mcguinlu/medrxivr-data) and [app](https://github.com/mcguinlu/medrxivr-app) .

## README
- [ ] **The README is very helpful to get started with the package. A brief description of what medRxiv is and a link to the preprint server would make the README more informative.**

- [x] **Maybe the distinction between downloading a snapshot and searching the remote snapshot could be made a bit clearer. I first started to download the whole corpus, and then realised that there's already a snapshot that I can use instead. /// I love @tts sketch of the overall design. Maybe it can be adapted and re-used?**  
Hopefully by including the graphic @tss suggested and by cleaning the README a bit, this is addressed!

## Vignette
- [ ] **There are three vignettes, which is great. Again, the general overview misses a sentence about what the preprint server medRxiv is about.**

- [x] **Not all code chunks are rendered. Some are introduced with a blank between the ticks and `{r}` Is this intentional?**  
  To quote Olivander<sup>1</sup>: 
  
  > No, no, definitely not. 
  
Not exactly sure what happened here, but I think it is fixed now. Please let me know if this is not the case! 

## Functionality

- [x] **There is a considerable duplication of code regarding the API call, which can make it hard to update the package in case of API changes. It would be good to have a single function for the API call. // URL paths are constructed using paste. httr::modify_url() and the query of httr::GET() allow passing arguments to a API. Furthermore, `{httr}` provides helpful functionality to capture API errors more systematically than in the current implementation.**  
  All interactions with the API has now been centralised in a collection of helper functions in R/helpers.R, which make use of `httr::modify_url()` and httr::GET(). Additionally, better/informative handling of API errors, using `httr::stop_for_status()`, has also been implemented.

- [x] **`mx_crosscheck()` does web scraping, which is fine according to the robots.txt. However, the requested crawl delay of 7 sec has been not implemented, yet.**  
  The `mx_crosscheck()` function has been updated to make use of the API inteface rather than webscraping. This change was made as there is often a discrepancy between the API total number and the total number on the website (which is what was originally used to compare against the snapshot). It also means that cross-checking between the snapshot and the live database is much faster, and can be used as an indicator of whether or not it is worth downloading your own copy via the API.

- [x] **mx_search() returns a grouped tibble. Personally, I prefer to have an ungrouped tibble. The column date is of type double, not date.**  
  `mx_search()` now returns an ungrouped tibble. The date column is now of type Date.

- [x] **Because of the downloading time, it is good to have feedback about the progress. Maybe re-using a progress bar functionality like from {progress} can lead to less code, while expanding the current feedback mechanism.**  
  This has been implemented for `mx_api_content()`, both to give users better feedback in terms of progress and to better estimate the remaining time needed to download a local copy of the database.

- [x] **mx_search(): rOpenSci style guide recommends snake case for params (from.date and to.date)**  
  The argument names in both `mx_search()` and `mx_api_content()` have been updated to reflect this. In addition, I have made the format for specifying a date consistent between the two function: "2020-06-01" (previously, `mx_search()` used a numeric format: 20200601)

- [x] **Finally, I wonder, if Europe PMC could be of use for searching medRxiv. Europe PMC search syntax is quite extensive and supports Boolean operator, wildcards and controlled vocabularies. What are the reasons not using it for searching medRxiv? Is it an indexing lag, or lacking metadata?**  
Full disclosure : I was not aware that medRxiv preprints were captured by Europe PMC. However, on investigation, there seems to be two differences between searching medRxiv directly vs via `europeomc`, using your example search. 
  - The first difference is expected: it takes a while for things to be indexed in PMC, and so searching the medRxiv repo directly means you are as up-to-date as possible. This can be seen in the example below, where `europepmc` gives 8994 records total, while medrxivr gives 9146. 
  - The second is not expected: comparing the output of your example search between the two packages shows that there are three records retrieved from medRxiv that are not present in PMC (110 `medrxivr`, 107 `europepmc`). Of these, one was published on the 01/06/2020, so it is maybe not surprising that it is not indexed yet (though preprints published on medRxiv after this date are), but one of the other records was registered on medRxiv in February (04/02/2020). I'm not sure why this has not been captured by PMC, but if you have any ideas, be great to hear them!
  - Finally, the last reason (and one of the inital motivating factors fordeveloping the package) was that `medrxivr` allows you to search for/download multiple versions of the same preprint (`mx_search(data, query, deduplicate = FALSE)`), allowing for comparison between them. As far as I can see, this functionality is not implemented in `europepmc` (but please correct me if I am wrong!).

<details><summary>Code for comparison</summary>
<p>

```{r}

# Load packages -----------------------------------------------------------

library(tidyverse)
library(europepmc)
library(medrxivr)

# Compare total records returned ------------------------------------------

# Using europepmc gives 8994
ep_q <- c('PUBLISHER:"medRxiv"')

epmc_l <- europepmc::epmc_search(ep_q, "raw", limit = 10000)

pmc_all <-purrr::map_dfr(epmc_l, `[`, c("doi", "title", "abstractText"))

# Using medrxivr gives 9146
mx_all <- mx_snapshot() %>%
  mx_search(query = "*")


# Compare searches --------------------------------------------------------

pattern <- "[Mm]endelian(\\s)([[:graph:]]+\\s){0,4}[Rr]andomi([[:alpha:]])ation"

# Using europepmc gives 107 records
pmc_results <- pmc_all %>%
  filter_at(vars(abstractText, title), any_vars(
    grepl(
      pattern,
      .
    )))

# Using medrxivr gives 110 records
mx_results <- mx_snapshot() %>%
  mx_search(query = pattern,
                        fields = c("title","abstract","doi"))


# Find records found by medrxivr but not europepmc ----------------------- 
'%notin%' <- Negate('%in%')

# Gives 3 records
discrepancy_df <- mx_results %>%
  filter(doi %notin% pmc_results$doi)
```
</p>
</details>

## Testing
- [x] **All tests passed, but it took a while. My duration was 1221.5 sec. However, I was connected to the internet via a cell phone connection during the review of the package.**
  This is likely due to the old way of reading in the data (i.e. via `read.csv()`). Now that the package is using `vroom`, testing should be a lot faster. I ran the testing a few times, and the average was ~ 140 s. From now on, the rate limiting step will be how fast it can download the copy from the database.

- [x] **I realised that a lot of skipping for CI platforms happens and I wonder why? Is it the run-time?**

----
<sup>1</sup> Harry Potter and the Sorcerer's Stone (movie), 00:28:35.

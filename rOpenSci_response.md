
* **ml3: `spelling::spell_check_package()` still shows some unknown     words. Please update your words list and consider automating the process with `usethis::use_spell_check()`.**
  I have automated the spellcheck now as recommended.


* ml4: `goodpractice::gp()` still suggests some improvements:


* ml5: `covr::package_coverage()` shows greater coverage than before; thanks. The only file that's still
  a little low is R/mx_crosscheck.R. Please consider adding more tests or excluding code as
  necessary (https://github.com/r-lib/covr#exclusions).

```r
# covr::package_coverage()
# medrxivr Coverage: 91.04%
# R/mx_crosscheck.R: 69.23%
# R/helpers.R: 83.33%
# R/mx_search.R: 90.27%
# R/mx_download.R: 93.85%
# R/mx_api.R: 100.00%
# R/mx_export.R: 100.00%
# R/mx_info.R: 100.00%
# R/mx_snapshot.R: 100.00%
```

* **ml6: `usethis::use_tidy_style()` suggests some files could improve. Please run `usethis::use_tidy_style()` and consider committing the changes.**
  I have run this and commited the changes.

* **ml7: On the website, the Reference tab shows "All functions". Maybe you can help users navigate this reference by grouping functions in some meaningful way? (see https://pkgdown.r-lib.org/reference/build_reference.html).**
  I had added keywords to the functions already, but hadn't realised that you needed to alter the `.pkgdown` file in order to group the functions. 
  
* **ml8: You may want to consider setting up a CI services for a wider range of environments. Here are two workflows you may use -- [standard](https://usethis.r-lib.org/reference/use_github_action.html#use-github-action-check-standard-), and [full](https://usethis.r-lib.org/reference/use_github_action.html#use-github-action-check-full-).**
  Thanks for the recommendation, I have gone with the Standard workflow.

* **ml9: I see three .Rmd files inside vignettes/ but only two in the Articles section of the website. Is this intentional?  Also, vignettes are great, but they can make the installation heavier.  Consider the [difference between `use_vignette()` and `use_article()`](https://usethis.r-lib.org/reference/use_vignette.html).**
  Yes, this is intentional. When you include a .Rmd file with the same name as the package in the vignette/ folder, `pkgdown` treats this as a special type of vignette ("Get Started"). From the `pkgdown` website:
  
  > A vignette with the same name as the package (e.g., vignettes/pkgdown.Rmd or vignettes/articles/pkgdown.Rmd) automatically becomes a top-level "Get started" link, and will not appear in the articles drop-down. (If your package name include a ., e.g. pack.down, use a - in the vignette name, e.g. pack.down.Rmd.)
  
  I have also taken your advice and converted the two vignettes covering advanced topics to articles, and signposted to them in the final introductory vignette.

* **ml10: I recommend walking through the steps listed by   [`use_release_issue()`](https://usethis.r-lib.org/reference/use_release_issue.html) or [`devtools::release()`](https://devtools.r-lib.org/reference/release.html). Even if you don't submit to CRAN, walking through the process can help you find details to improve.**
  As a result of this, the following changes were made:
  - `xml2` was removed from the `DESCRIPTION` as it is now longer needed now that the package does not perform any web-scraping.
  - Titles of some of the functions were edited to be more comprehensive, so that the `pkgdown` function list is more useful.
  - README.html was removed from the top level directory.

* *ml11: The vignettes show code but not output. Reproducible examples are most useful when they include the output because readers can understand what the code does even if they choose not to run the code themselves. This is why `reprex::reprex()` prints output (https://reprex.tidyverse.org/).**
  Thanks for this feedback. I have decided not to produce output for the one remaining vignette, as the example code in this vignette calls the API via `mx_api_content()`. I am worried that enabling evalutation of the code in this vignette would mean that it would take a long time to render and make installing the package slow. However, for the two new articles (converted from vignettes as per **ml9**, and included only in the pkgdown website), the output is now shown.

# Reviewer 1 (@tts) 

Glad to hear things are a bit clearer now!
 
The reason `mx_info()` is not found is that it is an internal function (`medrxivr:::mx_info()`) and should not have been available in the function list on the `pkgdown` website. I had marked several internal function with the "Internal" keyword, which should have hidden them, but it seems that `pkgdown` is case sensitive, and the correct keyword is "internal". This has been corrected now and the internal functions now longer appear in the website's function list.

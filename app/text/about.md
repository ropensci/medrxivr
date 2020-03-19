# Additional information
## Development

This app was designed using `Shiny` to provide a user friendly interface to the `medrxivr` package, which allows access to a daily static snapshot of the [medRxiv](https://www.medrxiv.org/) preprint repository, and allows users to perform more complicated search queries that what is currently feasible using the native medRxiv search. The package can be found [here](https://github.com/mcguinlu/medrxivr) - a copy of the webscraping scripts used to create the daily snapshot are stored in the `data-extraction/` folder. 

This app has two key features:
* Build complex search queries using regular expression syntax and Boolean logic (AND, OR, NOT) via a user-friendly interface and export the code needed to run the same search from R.
* Easily explore, visualise and download your search results.

Some technical aspects of the app:
* Intuitive navigation implemented via `updateTabsetPanel`
* Load example searches implemented via `updateTextInput`
* Nice loading screens implemented via `waiter`
* Prevent loss of work by checking with user when browser back button clicked (JS script )
* Capture enter key as button click in the Basic search `textAreaInput` (JS script)
* Consistent theming built around the "Yeti" `Shiny` theme

## About me
[Luke McGuinness](https://lukemcguinness.com) is a National Insitute of Health Research Doctoral Research Fellow in Evidence Synthesis at Bristol Medical School, where he is examining the relationship between blood lipid levels and dementia risk.
When procrastinating from real work, he is an R (pronounced "oar") and open science enthusiast.

Luke is part of the Bristol Appraisal and Review of Research (BARR) Group at the University of Bristol, led by Prof. Julian Higgins, which brings together researchers interested in the methodology and application of research synthesis methods such as systematic reviews, meta-analysis and critical assessment of research evidence.

If you have questions about the tool or would like to provide feedback, please email [luke.mcguinness@bristol.ac.uk](mailto:luke.mcguinness@bristol.ac.uk) 
  
## Acknowledgements
This project would not have been possible without:

* Prof. Julian Higgins, who as my main supervisor has been supportive of this project;,
* The Baby Driver [soundtrack](https://open.spotify.com/album/1XaJOcLe3xMQ611SMHtOja) which kept me sane while fixing coding bugs.

Additionally, the following people contributed valuable feedback that contributed to the development of this tool:

* [Liam Brierly](https://twitter.com/L_Brierley), who gave me the idea to [map publication trends](https://github.com/lbrierley/epi_preprint) over time. 

  
## Funding Statement,
Luke is funded by the National Institute for Health Research NIHR Doctoral Research Fellowship (DRF-2018-11-ST2-048).The views expressed are those of the authors and not necessarily those of the NIHR or the Department of Health and Social Care.

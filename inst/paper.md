---
title: 'medrxivr: Accessing and searching medRxiv preprint data in R'
tags:
  - R
  - systematic review
  - evidence synthesis
  - bibliographic database
authors:
  - name: Luke A McGuinness
    orcid: 0000-0003-0872-7098
    affiliation: "1, 2" 
  - name: Lena Schmidt
    orcid: 0000-0003-0709-8226
    affiliation: 1
affiliations:
  - name: Department of Population Health Science, University of Bristol
    index: 1
  - name: MRC Intergrative Epidemiology Unit, University of Bristol
    index: 2
date: 29 February 2020
bibliography: paper.bib
---

# Summary

An increasingly imporant source of health-related bibliographic content is the medRxiv repository, a free online archive and distribution server for preprints (preliminary versions of research articles that have yet to undergo peer review) in the medical, clinical, and health-related sciences [@rawlinson2019]. Founded in June 2019, the repository has now grown to over 5500 preprints, helped in part by the expotential growth in preprints related to the COVID-19 pandemic. 

The goal of the `medrxivr` R package is two-fold. In the first instance, it provides programmatic access to medRxiv preprint metadata (e.g. title, abstract, authors) from R. Users can either query the [medRxiv API](https://api.biorxiv.org/) directly, or can choose to use a daily static snapshot of the database, created and maintained in an effort to limit the package's burden on the API. This functionality will be of interest to anyone who wishes to import medRxiv preprint metadata into R, for example to explore the distribution of preprints by subject area or by publication year. Examples of this type of usage have already been reported [e.g. @Brierley].

In the second instance, the package provides functions that allow users to search the medRxiv database for relevant preprints using complex search strings, incorporating the functionality of search term truncation, Boolean operators (AND, OR, NOT), and term proximity. A helper function is also provided that allows users to easily download the full-text PDFs of preprints matching their search. This aspect of the package will be more relevant to systematic reviewers, health librarians and others performing literature searches, allowing them to perform and document transparent and reproducible searches in this important evidence source.


# Acknowledgements

We acknowledge funding  from NIHR (LAM through NIHR Doctoral Research Fellowship (DRF-2018-11-ST2-048), and LS through NIHR Systematic Reviews Fellowship (RM-SR-2017-09-028)). LAM is a member of the MRC Integrative Epidemiology Unit at the University of Bristol. The views expressed in this article are those of the authors and do not necessarily represent those of the NHS, the NIHR, MRC, or the Department of Health and Social Care.

# References

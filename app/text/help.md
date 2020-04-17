## Useful regular expression (_regex_) syntaxes for the systematic reviewer

### CAPTIALISATION

__Example regex:__ `[Dd]ementia`  
__Description:__ The search is case sensitive, so this syntax allows you to find both <b>D</b>ementia and <b>d</b>ementia using a single term, rather than having to enter them as seperate terms.

### WILDCARD

__Example regex:__ `randomi([[:alpha:]])ation`  
__Description:__ The `([[:alpha:]])` element defines any single alphanumeric character - in this case, the regex will find both randomi<b>s</b>ation and randomi<b>z</b>ation. 

### NEAR

__Example regex:__ `systematic(\\s)([[:graph:]]+\\s){0,4}review`  
__Description:__ The `(\\s)([[:graph:]]+\\s){0,4}` element defines that up to four words can be between <b>systematic</b> and <b>review</b> and the search will still find it. To change how far apart the terms are allowed to be, simply change the second number in the curly brackets (e.g. to find terms that are only one word apart, the syntax would be `systematic(\\s)([[:graph:]]+\\s){0,1}review`). **Please note that the search is directional, in that the example regex here will find "systematic methods for the review", but will not find "the review was systematic".**

### WORD LIMITS

__Example regex:__ `\\bNCOV\\b`  
__Description:__ Sometimes it is useful to be able to define the start and end of words. For example, if you were searching for NCOV-19, simply using `ncov` as your search term would also return records containing u<b>ncov</b>ered. Using `\\b` allows you to define where the word beings and ends, thus excluding false positive matches.

### REGEX TESTER

To check whether your search term will find what you expect it to, there is a useful [regex tester](https://spannbaueradam.shinyapps.io/r_regex_tester/), designed by [Adam Spannbauer](https://adamspannbauer.github.io/2018/01/16/r-regex-tester-shiny-app/).

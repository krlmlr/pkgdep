<!-- README.md is generated from README.Rmd. Please edit that file -->
pkgdep
======

The goal of pkgdep is to provide a nice API for analyzing the dependency structure from the return value of `available.packages()` and other functions.

Example
-------

``` r
library(pkgdep)
```

``` r
library(tibble)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(tidyr)
```

``` r
pkgdep <- as_pkgdep(available.packages())

tibble_revdeps <- get_revdeps("tibble", pkgdep)
tibble_revdeps
#>   [1] "fileplyr"          "manifestoR"        "pdfsearch"        
#>   [4] "pinnacle.data"     "simglm"            "abjutils"         
#>   [7] "afmToolkit"        "alfred"            "alphavantager"    
#>  [10] "anomalyDetection"  "antaresViz"        "atlantistools"    
#>  [13] "babynames"         "banR"              "bikedata"         
#>  [16] "billboard"         "biomartr"          "bioset"           
#>  [19] "blkbox"            "blob"              "blockTools"       
#>  [22] "blscrapeR"         "bold"              "breathtestcore"   
#>  [25] "breathteststan"    "bsam"              "caffsim"          
#>  [28] "ccafs"             "cellranger"        "cepR"             
#>  [31] "charlatan"         "childsds"          "ciTools"          
#>  [34] "condformat"        "congressbr"        "corrr"            
#>  [37] "countyweather"     "cpr"               "crosswalkr"       
#>  [40] "crplyr"            "cytominer"         "dat"              
#>  [43] "datadogr"          "dataonderivatives" "datastepr"        
#>  [46] "dbplyr"            "descriptr"         "DiagrammeR"       
#>  [49] "docxtractr"        "dplyr"             "dynfrail"         
#>  [52] "easyformatr"       "ecoseries"         "edeaR"            
#>  [55] "editData"          "electoral"         "enigma"           
#>  [58] "esc"               "etl"               "eurostat"         
#>  [61] "evaluator"         "exifr"             "fastqcr"          
#>  [64] "fbar"              "fcuk"              "feather"          
#>  [67] "filesstrings"      "flextable"         "fmbasics"         
#>  [70] "foghorn"           "forcats"           "frailtyEM"        
#>  [73] "ftDK"              "gapminder"         "gastempt"         
#>  [76] "gdns"              "GerminaR"          "getCRUCLdata"     
#>  [79] "GetITRData"        "getlandsat"        "ggalt"            
#>  [82] "ggconf"            "ggeffects"         "ggenealogy"       
#>  [85] "ggformula"         "ggfortify"         "ggguitar"         
#>  [88] "ggimage"           "ggplot2"           "ggplotAssist"     
#>  [91] "ggpmisc"           "ggraptR"           "gibble"           
#>  [94] "giphyr"            "gitlabr"           "googledrive"      
#>  [97] "googleLanguageR"   "GSODR"             "hansard"          
#> [100] "haploR"           
#>  [ reached getOption("max.print") -- omitted 162 entries ]

# All dependencies of tibble
all_tibble_deps <- get_all_deps("tibble", pkgdep, c("Depends", "Imports"))
as_tibble(all_tibble_deps)
#> # A tibble: 6 x 4
#>   Package DepType Dep     Version  
#> * <chr>   <chr>   <chr>   <chr>    
#> 1 tibble  Imports methods <NA>     
#> 2 tibble  Imports rlang   <NA>     
#> 3 tibble  Imports Rcpp    >= 0.12.3
#> 4 tibble  Imports utils   <NA>     
#> 5 Rcpp    Imports methods <NA>     
#> 6 Rcpp    Imports utils   <NA>

# Some packages are listed more than once:
as_tibble(all_tibble_deps) %>% 
  count(Dep) %>% 
  arrange(-n)
#> # A tibble: 4 x 2
#>   Dep         n
#>   <chr>   <int>
#> 1 methods     2
#> 2 utils       2
#> 3 Rcpp        1
#> 4 rlang       1

# All packages used for revdep-checking tibble
all_tibble_revdep_deps <- get_all_deps(tibble_revdeps, pkgdep)
as_tibble(all_tibble_revdep_deps)
#> # A tibble: 6,469 x 4
#>    Package    DepType Dep               Version  
#>  * <chr>      <chr>   <chr>             <chr>    
#>  1 afmToolkit Depends ggplot2           <NA>     
#>  2 antaresViz Depends antaresRead       >= 0.14.0
#>  3 antaresViz Depends antaresProcessing >= 0.11.0
#>  4 batchtools Depends data.table        >= 1.9.8 
#>  5 blkbox     Depends methods           <NA>     
#>  6 bsam       Depends rjags             >= 4-6   
#>  7 corrr      Depends dplyr             >= 0.5.0 
#>  8 crplyr     Depends crunch            >= 1.15.3
#>  9 crplyr     Depends dplyr             <NA>     
#> 10 dat        Depends methods           <NA>     
#> # ... with 6,459 more rows

# Separate dependency graphs for each revdep of tibble
individual_tibble_revdep_deps <-
  tibble(revdep = tibble_revdeps) %>%
  rowwise() %>% 
  mutate(all_deps = list(get_all_deps(revdep, pkgdep))) %>%
  ungroup()

# How many times is each package used during the revdepcheck process, excluding direct dependencies of tibble?
individual_tibble_revdep_deps %>%
  rowwise() %>%
  mutate(all_pkgs = list(unique(all_deps$Dep))) %>%
  select(-all_deps) %>%
  unnest() %>%
  count(all_pkgs) %>%
  filter(!(all_pkgs %in% all_tibble_deps$Dep)) %>%
  arrange(-n) %>%
  print(n = 20)
#> # A tibble: 798 x 2
#>    all_pkgs       n
#>    <chr>      <int>
#>  1 tibble       262
#>  2 R6           261
#>  3 magrittr     260
#>  4 tools        260
#>  5 grDevices    252
#>  6 digest       251
#>  7 stats        248
#>  8 mime         237
#>  9 jsonlite     235
#> 10 stringi      234
#> 11 BH           233
#> 12 stringr      227
#> 13 assertthat   225
#> 14 crayon       218
#> 15 praise       208
#> 16 testthat     208
#> 17 graphics     206
#> 18 grid         201
#> 19 pkgconfig    200
#> 20 yaml         200
#> # ... with 778 more rows
```

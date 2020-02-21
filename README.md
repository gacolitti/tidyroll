
# tidyroll

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/tidyroll)](https://CRAN.R-project.org/package=tidyroll)
[![Travis build
status](https://travis-ci.org/gacolitti/tidyroll.svg?branch=master)](https://travis-ci.org/gacolitti/tidyroll)
[![Codecov test
coverage](https://codecov.io/gh/gacolitti/tidyroll/branch/master/graph/badge.svg)](https://codecov.io/gh/gacolitti/tidyroll?branch=master)
<!-- badges: end -->

`tidyroll` makes it easy to work with irregular time slices for modeling
and prediciton with `tidymodels`.

The main function `rolling_origin_nested()` is a wrapper around
`rsample::rolling_origin` and facilitates rolling over different time
units instead of a fixed window. The motivation for this function comes
from this
[vignette](https://tidymodels.github.io/rsample/articles/Applications/Time_Series.html).

## Installation

``` r
# install.packages("devtools")
devtools::install_github("gacolitti/tidyroll")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(tidyroll)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(rsample)
#> Loading required package: tidyr
data("airquality")

airquality$date <- as.Date(paste("2019", airquality$Month, airquality$Day, sep = "-"))

roll <- rolling_origin_nested(data = airquality, time_var = "date", unit = "month")
roll
#> # Rolling origin forecast resampling 
#> # A tibble: 5 x 2
#>   splits        id    
#>   <list>        <chr> 
#> 1 <split [1/1]> Slice1
#> 2 <split [2/1]> Slice2
#> 3 <split [3/1]> Slice3
#> 4 <split [4/1]> Slice4
#> 5 <split [5/1]> Slice5

analysis(roll$splits[[1]])
#> # A tibble: 1 x 2
#>   .date                         data
#>   <dttm>              <list<df[,7]>>
#> 1 2019-05-01 00:00:00       [17 x 7]
assessment(roll$splits[[1]])
#> # A tibble: 1 x 2
#>   .date                         data
#>   <dttm>              <list<df[,7]>>
#> 1 2019-06-01 00:00:00       [32 x 7]
```

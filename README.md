
# tidyroll

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
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

``` r
suppressPackageStartupMessages(library(tidyroll))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(rsample))

data("airquality2")

roll <- rolling_origin_nested(
  data = airquality2, 
  time_var = "date", 
  unit = "month", 
  start = "2017-08-01",
  end = "2017-11-01",
  assess = 1
)
roll
#> # Rolling origin forecast resampling 
#> # A tibble: 3 x 2
#>   splits        id    
#>   <list>        <chr> 
#> 1 <split [4/1]> Slice1
#> 2 <split [5/1]> Slice2
#> 3 <split [6/1]> Slice3

analysis(roll$splits[[1]]) %>% tail()
#> # A tibble: 4 x 2
#>   .date                         data
#>   <dttm>              <list<df[,7]>>
#> 1 2017-05-01 00:00:00       [31 x 7]
#> 2 2017-06-01 00:00:00       [30 x 7]
#> 3 2017-07-01 00:00:00       [31 x 7]
#> 4 2017-08-01 00:00:00       [31 x 7]
assessment(roll$splits[[1]]) %>% head()
#> # A tibble: 1 x 2
#>   .date                         data
#>   <dttm>              <list<df[,7]>>
#> 1 2017-09-01 00:00:00       [30 x 7]

analysis(roll$splits[[1]])$data %>% last() %>% tail()
#> # A tibble: 6 x 7
#>   date                ozone solar_rad  wind  temp ozone_sample
#>   <dttm>              <int>     <int> <dbl> <int>        <dbl>
#> 1 2017-08-26 00:00:00    73       215   8      86         70.1
#> 2 2017-08-27 00:00:00    NA       153   5.7    88         NA  
#> 3 2017-08-28 00:00:00    76       203   9.7    97         74.6
#> 4 2017-08-29 00:00:00   118       225   2.3    94         91.2
#> 5 2017-08-30 00:00:00    84       237   6.3    96        120. 
#> 6 2017-08-31 00:00:00    85       188   6.3    94         79.0
#> # ... with 1 more variable: ozone_sample_date <date>
assessment(roll$splits[[1]])$data %>% first() %>% head()
#> # A tibble: 6 x 7
#>   date                ozone solar_rad  wind  temp ozone_sample
#>   <dttm>              <int>     <int> <dbl> <int>        <dbl>
#> 1 2017-09-01 00:00:00    96       167   6.9    91         86.6
#> 2 2017-09-02 00:00:00    78       197   5.1    92         77.9
#> 3 2017-09-03 00:00:00    73       183   2.8    93         96.3
#> 4 2017-09-04 00:00:00    91       189   4.6    93         86.4
#> 5 2017-09-05 00:00:00    47        95   7.4    87         60.9
#> 6 2017-09-06 00:00:00    32        92  15.5    84         34.9
#> # ... with 1 more variable: ozone_sample_date <date>
```

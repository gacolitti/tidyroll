
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
  unit = "week", 
  assess = 3,
  start = mean(airquality2$date, na.rm = TRUE),
  end = NULL
)
roll
#> # Rolling origin forecast resampling 
#> # A tibble: 9 x 2
#>   splits         id    
#>   <list>         <chr> 
#> 1 <split [12/3]> Slice1
#> 2 <split [13/3]> Slice2
#> 3 <split [14/3]> Slice3
#> 4 <split [15/3]> Slice4
#> 5 <split [16/3]> Slice5
#> 6 <split [17/3]> Slice6
#> 7 <split [18/3]> Slice7
#> 8 <split [19/3]> Slice8
#> 9 <split [20/3]> Slice9

analysis(roll$splits[[1]]) %>% tail()
#> # A tibble: 6 x 2
#>   .date                         data
#>   <dttm>              <list<df[,7]>>
#> 1 2017-06-11 00:00:00        [7 x 7]
#> 2 2017-06-18 00:00:00        [7 x 7]
#> 3 2017-06-25 00:00:00        [7 x 7]
#> 4 2017-07-02 00:00:00        [7 x 7]
#> 5 2017-07-09 00:00:00        [7 x 7]
#> 6 2017-07-16 00:00:00        [7 x 7]
assessment(roll$splits[[1]]) %>% head()
#> # A tibble: 3 x 2
#>   .date                         data
#>   <dttm>              <list<df[,7]>>
#> 1 2017-07-23 00:00:00        [7 x 7]
#> 2 2017-07-30 00:00:00        [7 x 7]
#> 3 2017-08-06 00:00:00        [7 x 7]

analysis(roll$splits[[1]])$data %>% last() %>% tail()
#> # A tibble: 6 x 7
#>   date                ozone solar_rad  wind  temp ozone_sample
#>   <dttm>              <int>     <int> <dbl> <int>        <dbl>
#> 1 2017-07-13 17:00:00    NA       291  14.9    91         NA  
#> 2 2017-07-14 17:00:00     7        48  14.3    80         45.6
#> 3 2017-07-15 17:00:00    48       260   6.9    81         50.8
#> 4 2017-07-16 17:00:00    35       274  10.3    82         54.7
#> 5 2017-07-17 17:00:00    61       285   6.3    84         72.3
#> 6 2017-07-18 17:00:00    79       187   5.1    87         65.5
#> # ... with 1 more variable: ozone_sample_date <date>
assessment(roll$splits[[1]])$data %>% first() %>% head()
#> # A tibble: 6 x 7
#>   date                ozone solar_rad  wind  temp ozone_sample
#>   <dttm>              <int>     <int> <dbl> <int>        <dbl>
#> 1 2017-07-19 17:00:00    63       220  11.5    85         56.5
#> 2 2017-07-20 17:00:00    16         7   6.9    74         39.7
#> 3 2017-07-21 17:00:00    NA       258   9.7    81         NA  
#> 4 2017-07-22 17:00:00    NA       295  11.5    82         NA  
#> 5 2017-07-23 17:00:00    80       294   8.6    86         97.4
#> 6 2017-07-24 17:00:00   108       223   8      85        107. 
#> # ... with 1 more variable: ozone_sample_date <date>
```

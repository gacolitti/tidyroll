
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

analysis(roll$splits[[1]])$data %>% tail()
#> <list_of<
#>   tbl_df<
#>     date             : datetime<local>
#>     ozone            : integer
#>     solar_rad        : integer
#>     wind             : double
#>     temp             : integer
#>     ozone_sample     : double
#>     ozone_sample_date: date
#>   >
#> >[6]>
#> [[1]]
#> # A tibble: 7 x 7
#>   date                ozone solar_rad  wind  temp ozone_sample
#>   <dttm>              <int>     <int> <dbl> <int>        <dbl>
#> 1 2017-06-07 17:00:00    NA       273   6.9    87         NA  
#> 2 2017-06-08 17:00:00    71       291  13.8    90         96.4
#> 3 2017-06-09 17:00:00    39       323  11.5    87         52.8
#> 4 2017-06-10 17:00:00    NA       259  10.9    93         NA  
#> 5 2017-06-11 17:00:00    NA       250   9.2    92         NA  
#> 6 2017-06-12 17:00:00    23       148   8      82         62.2
#> 7 2017-06-13 17:00:00    NA       332  13.8    80         NA  
#> # ... with 1 more variable: ozone_sample_date <date>
#> 
#> [[2]]
#> # A tibble: 7 x 7
#>   date                ozone solar_rad  wind  temp ozone_sample
#>   <dttm>              <int>     <int> <dbl> <int>        <dbl>
#> 1 2017-06-14 17:00:00    NA       322  11.5    79         NA  
#> 2 2017-06-15 17:00:00    21       191  14.9    77         55.9
#> 3 2017-06-16 17:00:00    37       284  20.7    72         76.2
#> 4 2017-06-17 17:00:00    20        37   9.2    65         42.7
#> 5 2017-06-18 17:00:00    12       120  11.5    73         64.2
#> 6 2017-06-19 17:00:00    13       137  10.3    76         52.0
#> 7 2017-06-20 17:00:00    NA       150   6.3    77         NA  
#> # ... with 1 more variable: ozone_sample_date <date>
#> 
#> [[3]]
#> # A tibble: 7 x 7
#>   date                ozone solar_rad  wind  temp ozone_sample
#>   <dttm>              <int>     <int> <dbl> <int>        <dbl>
#> 1 2017-06-21 17:00:00    NA        59   1.7    76           NA
#> 2 2017-06-22 17:00:00    NA        91   4.6    76           NA
#> 3 2017-06-23 17:00:00    NA       250   6.3    76           NA
#> 4 2017-06-24 17:00:00    NA       135   8      75           NA
#> 5 2017-06-25 17:00:00    NA       127   8      78           NA
#> 6 2017-06-26 17:00:00    NA        47  10.3    73           NA
#> 7 2017-06-27 17:00:00    NA        98  11.5    80           NA
#> # ... with 1 more variable: ozone_sample_date <date>
#> 
#> [[4]]
#> # A tibble: 7 x 7
#>   date                ozone solar_rad  wind  temp ozone_sample
#>   <dttm>              <int>     <int> <dbl> <int>        <dbl>
#> 1 2017-06-28 17:00:00    NA        31  14.9    77         NA  
#> 2 2017-06-29 17:00:00    NA       138   8      83         NA  
#> 3 2017-06-30 17:00:00   135       269   4.1    84        114. 
#> 4 2017-07-01 17:00:00    49       248   9.2    85         81.3
#> 5 2017-07-02 17:00:00    32       236   9.2    81         53.6
#> 6 2017-07-03 17:00:00    NA       101  10.9    84         NA  
#> 7 2017-07-04 17:00:00    64       175   4.6    83         77.1
#> # ... with 1 more variable: ozone_sample_date <date>
#> 
#> [[5]]
#> # A tibble: 7 x 7
#>   date                ozone solar_rad  wind  temp ozone_sample
#>   <dttm>              <int>     <int> <dbl> <int>        <dbl>
#> 1 2017-07-05 17:00:00    40       314  10.9    83         10.1
#> 2 2017-07-06 17:00:00    77       276   5.1    88        119. 
#> 3 2017-07-07 17:00:00    97       267   6.3    92         95.9
#> 4 2017-07-08 17:00:00    97       272   5.7    92        149. 
#> 5 2017-07-09 17:00:00    85       175   7.4    89         97.3
#> 6 2017-07-10 17:00:00    NA       139   8.6    82         NA  
#> 7 2017-07-11 17:00:00    10       264  14.3    73         55.8
#> # ... with 1 more variable: ozone_sample_date <date>
#> 
#> [[6]]
#> # A tibble: 7 x 7
#>   date                ozone solar_rad  wind  temp ozone_sample
#>   <dttm>              <int>     <int> <dbl> <int>        <dbl>
#> 1 2017-07-12 17:00:00    27       175  14.9    81         25.3
#> 2 2017-07-13 17:00:00    NA       291  14.9    91         NA  
#> 3 2017-07-14 17:00:00     7        48  14.3    80         45.6
#> 4 2017-07-15 17:00:00    48       260   6.9    81         50.8
#> 5 2017-07-16 17:00:00    35       274  10.3    82         54.7
#> 6 2017-07-17 17:00:00    61       285   6.3    84         72.3
#> 7 2017-07-18 17:00:00    79       187   5.1    87         65.5
#> # ... with 1 more variable: ozone_sample_date <date>
assessment(roll$splits[[1]])$data %>% head()
#> <list_of<
#>   tbl_df<
#>     date             : datetime<local>
#>     ozone            : integer
#>     solar_rad        : integer
#>     wind             : double
#>     temp             : integer
#>     ozone_sample     : double
#>     ozone_sample_date: date
#>   >
#> >[3]>
#> [[1]]
#> # A tibble: 7 x 7
#>   date                ozone solar_rad  wind  temp ozone_sample
#>   <dttm>              <int>     <int> <dbl> <int>        <dbl>
#> 1 2017-07-19 17:00:00    63       220  11.5    85         56.5
#> 2 2017-07-20 17:00:00    16         7   6.9    74         39.7
#> 3 2017-07-21 17:00:00    NA       258   9.7    81         NA  
#> 4 2017-07-22 17:00:00    NA       295  11.5    82         NA  
#> 5 2017-07-23 17:00:00    80       294   8.6    86         97.4
#> 6 2017-07-24 17:00:00   108       223   8      85        107. 
#> 7 2017-07-25 17:00:00    20        81   8.6    82         73.8
#> # ... with 1 more variable: ozone_sample_date <date>
#> 
#> [[2]]
#> # A tibble: 7 x 7
#>   date                ozone solar_rad  wind  temp ozone_sample
#>   <dttm>              <int>     <int> <dbl> <int>        <dbl>
#> 1 2017-07-26 17:00:00    52        82  12      86         56.9
#> 2 2017-07-27 17:00:00    82       213   7.4    88         92.7
#> 3 2017-07-28 17:00:00    50       275   7.4    86         70.8
#> 4 2017-07-29 17:00:00    64       253   7.4    83         57.8
#> 5 2017-07-30 17:00:00    59       254   9.2    81        101. 
#> 6 2017-07-31 17:00:00    39        83   6.9    81         87.7
#> 7 2017-08-01 17:00:00     9        24  13.8    81         57.6
#> # ... with 1 more variable: ozone_sample_date <date>
#> 
#> [[3]]
#> # A tibble: 7 x 7
#>   date                ozone solar_rad  wind  temp ozone_sample
#>   <dttm>              <int>     <int> <dbl> <int>        <dbl>
#> 1 2017-08-02 17:00:00    16        77   7.4    82         85.2
#> 2 2017-08-03 17:00:00    78        NA   6.9    86         95.2
#> 3 2017-08-04 17:00:00    35        NA   7.4    85         21.0
#> 4 2017-08-05 17:00:00    66        NA   4.6    87         58.2
#> 5 2017-08-06 17:00:00   122       255   4      89         74.6
#> 6 2017-08-07 17:00:00    89       229  10.3    90         74.6
#> 7 2017-08-08 17:00:00   110       207   8      90         83.3
#> # ... with 1 more variable: ozone_sample_date <date>
```

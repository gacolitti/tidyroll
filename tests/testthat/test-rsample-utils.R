library(recipes)
library(dplyr)
library(purrr)

# data("airquality2")

airquality2 <- structure(
  list(
    ozone = c(
      41L,
      36L,
      12L,
      18L,
      NA,
      28L,
      23L,
      19L,
      8L,
      NA,
      7L,
      16L,
      11L,
      14L,
      18L,
      14L,
      34L,
      6L,
      30L,
      11L
    ),
    solar_rad = c(
      190L,
      118L,
      149L,
      313L,
      NA,
      NA,
      299L,
      99L,
      19L,
      194L,
      NA,
      256L,
      290L,
      274L,
      65L,
      334L,
      307L,
      78L,
      322L,
      44L
    ),
    wind = c(
      7.4,
      8,
      12.6,
      11.5,
      14.3,
      14.9,
      8.6,
      13.8,
      20.1,
      8.6,
      6.9,
      9.7,
      9.2,
      10.9,
      13.2,
      11.5,
      12,
      18.4,
      11.5,
      9.7
    ),
    temp = c(
      67L,
      72L,
      74L,
      62L,
      56L,
      66L,
      65L,
      59L,
      61L,
      69L,
      74L,
      69L,
      66L,
      68L,
      58L,
      64L,
      66L,
      57L,
      68L,
      62L
    ),
    date = structure(
      c(
        1216,
        1217,
        1218,
        1219,
        1220,
        1221,
        1222,
        1223,
        1224,
        1225,
        1226,
        1227,
        1228,
        1229,
        1230,
        1231,
        1232,
        1233,
        1234,
        1235
      ),
      class = "Date"
    )
  ),
  row.names = c(NA,-20L),
  class = "data.frame"
)

roll <- rolling_origin_nested(data = airquality2, time_var = "date", unit = "week")
rec <- recipe(data = airquality2 %>% slice(0), ozone ~ temp)
roll2 <- roll %>% mutate(recipe = list(rec))
roll2$fits <- map2(roll2$splits, roll2$recipe, fit_rsample_nested, model_func = lm)
roll2$predictions <- pmap(lst(split = roll2$splits, recipe = roll2$recipe, fit = roll2$fits), predict_rsample_nested)

test_that("rolling_origin_nested returns rolling origin object", {
  expect_match(class(roll)[1], "rolling_origin")
})

test_that("fit_rsample_nested returns fits", {
  expect_match(class(roll2$fits[[1]]), "lm")
})

test_that("predict_rsample_nested returns predictions", {
  expect_equal(nrow(roll2$predictions[[1]]), 8)
  expect_equal(nrow(roll2$predictions[[2]]), 8)
  expect_equal(ncol(roll2$predictions[[1]]), 4)
  expect_equal(ncol(roll2$predictions[[2]]), 4)
})

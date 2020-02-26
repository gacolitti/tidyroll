library(testthat)
library(tidyroll)
library(recipes)
library(dplyr)
library(purrr)

data("airquality")
airquality$date <- as.Date(paste("2019", airquality$Month, airquality$Day, sep = "-"))
roll <- rolling_origin_nested(data = airquality, time_var = "date", unit = "month")
rec <- recipe(data = airquality %>% slice(0), Ozone ~ Wind + Temp)
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
  expect_equal(nrow(roll2$predictions[[1]]), 32)
  expect_equal(nrow(roll2$predictions[[5]]), 14)
  expect_equal(ncol(roll2$predictions[[1]]), 5)
  expect_equal(ncol(roll2$predictions[[5]]), 5)
})

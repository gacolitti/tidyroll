
library(recipes)
library(dplyr)
library(rlang)

data("airquality2")

set.seed(1)

rec <- recipe(data = airquality2, ozone ~ temp + ozone_sample + ozone_sample_date) %>%
  update_role(ozone_sample_date, new_role = "id") %>%
  step_naomit(all_predictors()) %>%
  step_normalize(all_predictors())

new_steps <- exprs(step_poly(ozone_sample), step_log(ozone))

test_that("add_steps returns recipe", {
  expect_error(add_steps(rec, new_steps), NA)
  expect_error(add_steps(rec, new_steps) %>% prep(), NA)
  expect_s3_class(add_steps(rec, new_steps), "recipe")
})

test_that("normalize and unnormalize function properly", {
  expect_equal(normalize(x = airquality2$temp, recipe = prep(rec), var = "temp")[1] %>% round(2), -1.15)
  expect_equal(unnormalize(x = -1.15, recipe = prep(rec), var = "temp") %>% round(1), airquality2$temp[1])
})

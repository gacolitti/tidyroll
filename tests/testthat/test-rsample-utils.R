
library(recipes)
library(dplyr)
library(purrr)
library(rlang)

data("airquality2")

set.seed(1)

roll <- rolling_origin_nested(data = airquality2,
                              time_var = "date",
                              unit = "week",
                              round_fun = lubridate::round_date)
rec <- recipe(data = airquality2 %>% slice(0), ozone ~ temp + ozone_sample + ozone_sample_date) %>%
  update_role(ozone_sample_date, new_role = "id")

roll2 <- roll %>% mutate(recipe = list(rec))

roll2$fits <- map2(roll2$splits, roll2$recipe, fit_rsample_nested, model_func = lm)


test_that("rolling_origin_nested returns rolling origin object", {
  expect_s3_class(roll, "rolling_origin")
})

test_that("fit_rsample_nested returns fits", {
  expect_s3_class(roll2$fits[[1]], "lm")
})

test_that("predict_rsample_nested returns predictions", {

  roll2$predictions <-
    pmap(
      lst(
        split = roll2$splits,
        recipe = roll2$recipe,
        fit = roll2$fits
      ),
      predict_rsample_nested
    )

  expect_equal(nrow(roll2$predictions[[1]]), 7)
  expect_equal(nrow(roll2$predictions[[2]]), 7)

  expect_equal(ncol(roll2$predictions[[1]]), 6)
  expect_equal(ncol(roll2$predictions[[2]]), 6)

  expect_equal(roll2$predictions[[1]]$.pred[1] %>% round(1), 34.2)
  expect_equal(roll2$predictions[[1]]$.pred[2] %>% round(1), 26.5)
  expect_equal(roll2$predictions[[1]]$.pred[3] %>% round(1), 20.1)
})

test_that("predict_rsample_nested can add steps to recipe", {

  roll2$predictions2 <-
    pmap(
      lst(
        split = roll2$splits,
        recipe = roll2$recipe,
        fit = roll2$fits
      ),
      predict_rsample_nested,
      new_steps = exprs(
        step_mutate_at(
          ozone_sample,
          fn = ~ if_else(ozone_sample_date < pred_date, ozone_sample, as.numeric(NA))),
        step_meanimpute(ozone_sample))
    )

  expect_equal(nrow(roll2$predictions2[[1]]), 7)
  expect_equal(nrow(roll2$predictions2[[2]]), 7)

  expect_equal(ncol(roll2$predictions2[[1]]), 6)
  expect_equal(ncol(roll2$predictions2[[2]]), 6)

  expect_equal(roll2$predictions2[[1]]$.pred[1] %>% round(1), 34.2)
  expect_equal(roll2$predictions2[[4]]$.pred[1] %>% round(1), 42.9)
})

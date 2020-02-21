library(tidyroll)

data("airquality")
airquality$date <- as.Date(paste("2019", airquality$Month, airquality$Day, sep = "-"))

testthat::test_that("rolling-origin-nested-returns-rolling-origin-object", {
  expect_match(class(rolling_origin_nested(data = airquality, time_var = "date"))[1], "rolling_origin")
})

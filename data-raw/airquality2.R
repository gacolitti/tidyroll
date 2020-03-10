
library(dplyr)

data("airquality")

set.seed(1)

airquality2 <- airquality %>%
  rename_all(tolower) %>%
  rename(solar_rad = solar.r) %>%
  mutate(
    date = as.Date(paste("2017", month, day, sep = "-")),
    ozone_sample = 0.6 * ozone + sqrt(1 - 0.6 * 0.6) * rnorm(nrow(.),
                                                             mean(ozone, na.rm = TRUE),
                                                             sd(ozone, na.rm = TRUE)),
    ozone_sample_date = date - rnorm(nrow(.), 7, 2)) %>%
  select(-c(day, month))

usethis::use_data(airquality2, overwrite = TRUE, compress = "bzip2")

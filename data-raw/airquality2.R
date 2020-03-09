
library(dplyr)

data("airquality")

glimpse(airquality)

airquality2 <- airquality %>%
  rename_all(tolower) %>%
  rename(solar_rad = solar.r) %>%
  mutate(date = as.Date(paste("2017", month, day, sep = "-"))) %>%
  select(-c(day, month))

usethis::use_data(airquality2, overwrite = TRUE, compress = "bzip2")

# head --------------------------------------------------------------------
# Kiernan Nicholls
# 2018-10-20
# Collect forecast model data
library(tidyverse)

# read and format senate data
senate <-
  read_csv("https://projects.fivethirtyeight.com/congress-model-2018/senate_seat_forecast.csv",
           col_types =  cols(incumbent = col_logical())) %>%
  filter(model == "classic",
         party == "D" | party == "R" | party == "I") %>%
  rename(date = forecastdate,
         win.prob = win_probability) %>%
  mutate(chamber = "senate",
         voteshare = voteshare / 100,
         district = "00") %>%
  unite(col = code,
        state, district,
        sep = "-",
        remove = FALSE) %>%
  select(date,
         candidate,
         chamber,
         state,
         district,
         party,
         incumbent,
         voteshare,
         win.prob)

# read and format house data
house <-
  read_csv("https://projects.fivethirtyeight.com/congress-model-2018/house_district_forecast.csv",
           col_types =  cols(incumbent = col_logical())) %>%
  filter(model == "classic",
         party == "D" | party == "R" | party == "I") %>%
  rename(date = forecastdate,
         win.prob = win_probability) %>%
  mutate(chamber = "house",
         voteshare = voteshare / 100,
         district = str_pad(district, 2, pad = "0")) %>%
  unite(col = code,
        state, district,
        sep = "-",
        remove = FALSE) %>%
  select(date,
         candidate,
         chamber,
         state,
         district,
         party,
         incumbent,
         voteshare,
         win.prob)

# combine senate and house
forecast.history <- rbind(senate, house)
rm(house, senate)
forecast.history <- arrange(forecast, date)

# write_csv(forecast.history, "./data/forecast_history.csv")

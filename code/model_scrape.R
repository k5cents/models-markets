# Kiernan Nicholls
# Fall 2018
# GOVT-696
# Collect and format forecast model data
library(tidyverse)

# read and format senate data
senate <-
  read_csv("https://projects.fivethirtyeight.com/congress-model-2018/senate_seat_forecast.csv",
           col_types =  cols(incumbent = col_logical())) %>%
  filter(model == "classic",
         party == "D" | party == "R" | party == "I") %>%
  rename(name = candidate,
         date = forecastdate,
         prob = win_probability) %>%
  mutate(chamber = "senate",
         voteshare = voteshare / 100,
         district = "00") %>%
  unite(col = code,
        state, district,
        sep = "-",
        remove = FALSE) %>%
  select(date,
         name,
         chamber,
         state,
         district,
         party,
         incumbent,
         voteshare,
         prob)

# read and format house data
house <-
  read_csv("https://projects.fivethirtyeight.com/congress-model-2018/house_district_forecast.csv",
           col_types =  cols(incumbent = col_logical())) %>%
  filter(model == "classic",
         party == "D" | party == "R" | party == "I") %>%
  rename(name = candidate,
         date = forecastdate,
         prob = win_probability) %>%
  mutate(chamber = "house",
         voteshare = voteshare / 100,
         district = str_pad(district, 2, pad = "0")) %>%
  unite(col = code,
        state, district,
        sep = "-",
        remove = FALSE) %>%
  select(date,
         name,
         chamber,
         state,
         district,
         party,
         incumbent,
         voteshare,
         prob)

# combine senate and house
model.history <- rbind(senate, house)
model.history <- arrange(model.history, date)
rm(house, senate)

model.history$last <-
  if_else(word(model.history$name, -1) == "Jr.",
          true = word(model.history$name, -2),
          false =  if_else(word(model.history$name, -1) == "III",
                           true = word(model.history$name, -2),
                           false = word(model.history$name, -1)))

model.history <-
  model.history %>%
  unite(col = code,
        state, district,
        sep = "-",
        remove = TRUE) %>%
  select(date,
         name,
         last,
         chamber,
         code,
         party,
         incumbent,
         voteshare,
         prob)

write_csv(model.history, "./data/model_history.csv")

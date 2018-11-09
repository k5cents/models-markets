# Kiernan Nicholls
# Fall 2018
# GOVT-696
# Collect and format forecast model data
library(tidyverse)

# read and format senate data
senate_model <-
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
house_model <-
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
model_history <- rbind(senate_model, house_model)
model_history <- arrange(model_history, date)
rm(senate_model, house_model)

model_history$last <-
  if_else(word(model_history$name, -1) == "Jr.",
          true = word(model_history$name, -2),
          false =  if_else(word(model_history$name, -1) == "III",
                           true = word(model_history$name, -2),
                           false = word(model_history$name, -1)))

model_history <-
  model_history %>%
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

model_history$prob <- round(model_history$prob, 3)

write_csv(model_history, "./data/model_history.csv")

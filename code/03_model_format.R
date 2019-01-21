# Kiernan Nicholls
# Format forecast model data
library(tidyverse)
library(magrittr)

model_history <-
  model_seat %>%
  mutate(chamber = "senate",
         district = if_else(special, 98, 99)) %>%
  bind_rows(model_district) %>%
  mutate(chamber = if_else(is.na(chamber), "house", chamber),
         district = str_pad(district, width = 2, pad = 0),
         win_probability = round(win_probability, 3)) %>%
  unite(col = code,
        state, district,
        sep = "-",
        remove = TRUE) %>%
  rename(name = candidate,
         date = forecastdate,
         prob = win_probability,
         min_share = p10_voteshare,
         max_share = p90_voteshare) %>%
  select(date,
         name,
         chamber,
         code,
         party,
         special,
         incumbent,
         prob,
         min_share,
         voteshare,
         max_share,
         model) %>%
  filter(name != "Others")

# Extract the last name for matching
model_history$name <-
  if_else(word(model_history$name, -1) == "Jr.",
          true = word(model_history$name, -2),
          false =  if_else(word(model_history$name, -1) == "III",
                           true = word(model_history$name, -2),
                           false = word(model_history$name, -1)))

model_history %<>% arrange(date, name)
model_history$special[is.na(model_history$special)] <- FALSE

# Seperate model data by model format
# According to 538, the "classic" model can be used as a default
model <- filter(model_history, model == "classic") %>% select(-model)
model_lite <- filter(model_history, model == "lite") %>% select(-model)
model_delux <- filter(model_history, model == "deluxe") %>% select(-model)

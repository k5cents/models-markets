# Kiernan Nicholls
# Format forecast model data from FiveThirtyEight

# Format district for race variable
model_district2 <- model_district %>%
  mutate(district = str_pad(string = district,
                            width = 2,
                            side = "left",
                            pad = "0"))

# Format class for race variable
model_seat2 <- model_seat %>%
  rename(district = class) %>%
  mutate(district = str_pad(string = district,
                            width = 2,
                            side = "left",
                            pad = "S"))

model_combined <-
  bind_rows(model_district2, model_seat2,
            # Variable identifying which data set obs originates
            .id = "chamber") %>%
  # Create race variable for relational join
  unite(col = race,
        state, district,
        sep = "-",
        remove = TRUE) %>%
  rename(name = candidate,
         date = forecastdate,
         prob = win_probability,
         min_share = p10_voteshare,
         max_share = p90_voteshare) %>%
  filter(name != "Others") %>%
  select(date, race, name, party, chamber, everything()) %>%
  arrange(date, name)

# Recode identifying variable for clarification
model_combined$chamber <- recode(model_combined$chamber,
                                 "1" = "house",
                                 "2" = "senate")

# Change to numeric senate seat codes. The S2/98 are SPECIAL elections.
model_combined$race <- str_replace_all(model_combined$race, "S1", "99")
model_combined$race <- str_replace_all(model_combined$race, "S2", "98")

# Only special elections are for senate.
model_combined$special[is.na(model_combined$special)] <- FALSE

# Convert percent vote share values to decimal
model_combined[, 10:12] <- model_combined[, 10:12] * 0.01

# Recode incumbent Independent senators for relational joins with Markets
# Both caucus with Democrats and were endoresed by Democratic party
model_combined$party[model_combined$name == "Bernard Sanders"] <- "D"
model_combined$party[model_combined$name == "Angus King"]      <- "D"

# Seperate model data by model format
# According to 538, the "classic" model can be used as a default
model <- filter(model_combined, model == "classic") %>% select(-model)
model_lite <- filter(model_combined, model == "lite") %>% select(-model)
model_deluxe <- filter(model_combined, model == "deluxe") %>% select(-model)

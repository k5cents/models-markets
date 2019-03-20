### Kiernan Nicholls
### Format election results

results <- forecast_results_2018 %>%
  filter(branch  != "Governor",
         version == "classic") %>%
  separate(col    = race,
           into   = c("state", "district"),
           sep    = "-") %>%
  rename(winner   = Democrat_Won) %>%
  mutate(winner   = if_else(uncalled, true  = NA, false = winner),
         district = str_pad(district, width = 2,  pad   = "0")) %>%
  unite(col = race,
        state, district,
        sep = "-") %>%
  select(race, winner, category)

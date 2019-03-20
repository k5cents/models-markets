### Kiernan Nicholls
### Based on Cook Partisan Voting Index

# Separate lean value and replace state name with state abbreviation
lean_states <- partisan_lean_STATES %>%
  separate(col = pvi_538,
           into = c("party", "lean"),
           sep = "\\+",
           convert = TRUE) %>%
  rename(race = state) %>%
  mutate(race = paste(state.abb, "S1", sep = "-"))

# Seperate lean value and pad district number for race code
lean_district <- partisan_lean_DISTRICTS %>%
  separate(col = pvi_538,
           into = c("party", "lean"),
           sep = "\\+",
           convert = TRUE) %>%
  separate(col = district,
           into = c("state", "race"),
           sep = "\\-") %>%
  mutate(race = str_pad(race, width = 2, pad = "0")) %>%
  unite(col = race,
        state, race,
        sep = "-")

# Turn single number into negative-positive spectrum
race_lean <-
  bind_rows(lean_states, lean_district) %>%
  mutate(lean = if_else(condition = party == "D",
                        true  = lean * -1,
                        false = lean))

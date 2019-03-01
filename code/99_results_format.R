# Kiernan Nicholls
# Format election results

results <-
  election_results %>%
  filter(branch != "Governor" & version == "classic") %>%
  select(race,
         # The two winner variables are redundant
         # Here, TRUE indicates Dem winner
         Democrat_Won,
         uncalled) %>%
  rename(won = Democrat_Won) %>%
  separate(col = race,
           into = c("state", "district"),
           sep = "-",
           remove = TRUE) %>%
  mutate(district = recode(district,
                           "S1" = "99",
                           "S2" = "98"),
         district = str_pad(district,
                            width = 2,
                            side = "left",
                            pad = "0"),
         won = if_else(uncalled, NA, won)) %>%
  unite(col = race,
        state, district,
        sep = "-",
        remove = TRUE) %>%
  select(-uncalled)

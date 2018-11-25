# Tidy and combine the partisan lean index values from FiveThirtyEight

lean_district <-
  read_csv("https://raw.githubusercontent.com/fivethirtyeight/data/master/partisan-lean/fivethirtyeight_partisan_lean_DISTRICTS.csv") %>%
  separate(col = district, into = c("abb", "num")) %>%
  mutate(num = str_pad(num, 2, pad = "0")) %>%
  unite(col = district, abb, num, sep = "-") %>%
  separate(col = pvi_538, into = c("party", "lean"), sep = "\\+") %>%
  mutate(lean = if_else(condition = party == "D",
                        true = (as.numeric(lean) * -1),
                        false = as.numeric(lean))) %>%
  rename(code = district)

lean_state <-
  read_csv("https://raw.githubusercontent.com/fivethirtyeight/data/master/partisan-lean/fivethirtyeight_partisan_lean_STATES.csv") %>%
  mutate(state = paste(state.abb, "00", sep = "-")) %>%
  separate(col = pvi_538, into = c("party", "lean"), sep = "\\+") %>%
  mutate(lean = if_else(condition = party == "D",
                        true = (as.numeric(lean) * -1),
                        false = as.numeric(lean))) %>%
  rename(code = state)

partisan_lean <-
  bind_rows(lean_state, lean_district) %>%
  arrange(lean) %>%
  select(-party)

rm(lean_district, lean_state)

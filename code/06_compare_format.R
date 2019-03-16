# Kiernan Nicholls
# Check predictions against election results

## Some markets only have data on candidate from 1 party
## We only need probability for one candidate in each race
## I will use the democratic candidate

# Find races with data on multiple Democratic candidates
multiple_dem <- model %>%
  filter(party == "D") %>%
  group_by(race, date) %>%
  summarise(n = n()) %>%
  filter(n > 1) %>%
  select(race) %>%
  as_vector() %>%
  unique()

# Find races with data on multiple Republican candidates
multiple_gop <- model %>%
  filter(party == "R") %>%
  group_by(race, date) %>%
  summarise(n = n()) %>%
  filter(n > 1) %>%
  select(race) %>%
  as_vector() %>%
  unique()

# For markets with only Republicans, take the complimentary probability
# This process assumes all races will only have Republicans or Democrats
# For the few elections with two candidates of 1 party, leading candidate used

model2 <- model %>%
  group_by(date, race, party, incumbent) %>%
  summarise(prob = sum(prob)) %>%
  ungroup() %>%
  filter(party == "D") %>%
  select(-party)

invert_gop <- markets %>%
  group_by(date, race, party, vol, close) %>%
  summarise(n = n()) %>%
  filter(n == 1) %>%
  select(-n) %>%
  ungroup() %>%
  filter(party == "R") %>%
  mutate(close = 1 - close,
         party = "D")

original_dem <- markets %>%
  filter(party == "D") %>%
  select(date, race, party, vol, close)

markets2 <- bind_rows(invert_gop, original_dem) %>% select(-party)

# Join with models
df <-
  left_join(markets2, model2,
            by = c("date", "race")) %>%
  filter(date >= "2018-08-01",
         date <= "2018-11-05") %>%
  select(date, race, incumbent, vol, close, prob) %>%

  # Tidy data, gather by predictive method
  rename(model  = prob,
         market = close) %>%
  gather(model, market,
         key   = method,
         value = prob) %>%
  arrange(date, race) %>%
  mutate(pick = if_else(prob > 0.50, TRUE, FALSE)) %>%

  # Join with election results
  left_join(results, by = "race") %>%
  # Compare the method prediction to actual winner
  mutate(correct = if_else(pick == winner, TRUE, FALSE)) %>%
  select(-incumbent, -vol)

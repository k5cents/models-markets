# Kiernan Nicholls
# Check predictions against election results
library(tidyverse)

# Some markets only have data on candidate from 1 party
# We only need probability for one candidate in each race
# I will use the democratic candidate

# Find races with data on only 1 candidate
single_party_markets <- markets %>%
  group_by(race, date) %>%
  summarise(n = n()) %>%
  filter(n == 1) %>%
  select(race) %>%
  as_vector() %>%
  unique()

# Find races with data on multiple Democratic candidates
multiple_dems <- model %>%
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

only_gop <-
  markets %>%
  filter(race %in% single_party_markets,
         party == "R")

# Invert prices from "Yes" R to "No" R (i.e., "Yes" D)
only_gop$open  <- 1 - only_gop$open
only_gop$low   <- 1 - only_gop$low
only_gop$high  <- 1 - only_gop$high
only_gop$close <- 1 - only_gop$close

# Invert party from R to D
only_gop$party <- "D"

# All markets original ask about incumbent re-election
only_gop$incumbent <- FALSE

# Join back with original D markets
not_gop <- markets %>% filter(!race %in% only_gop$race)

markets2 <-
  bind_rows(only_gop, not_gop) %>%
  select(date, mid, race, party, vol, everything())

# Join with models
predictions <-
  left_join(markets2, model,
            by = c("date", "race", "party")) %>%
  filter(date >= "2018-08-01",
         date <= "2018-11-05") %>%
  select(date, race, name, chamber, party, special, prob, close) %>%

  # Tidy data, gather by predictive method
  rename(model  = prob,
         market = close) %>%
  gather(model, market,
         key   = method,
         value = prob) %>%
  arrange(date) %>%

  # Add the binary win/loss prediction
  mutate(pick = if_else(prob > 0.50, TRUE, FALSE)) %>%

  # Join with election results
  left_join(results, by = "race") %>%

  # Compare the method prediction to actual winner
  mutate(correct = if_else(pick == winner, TRUE, FALSE)) %>%
  select(-pick, -winner)

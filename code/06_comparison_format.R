# Kiernan Nicholls
# Check predictions against election results
library(tidyverse)

# Some markets only have data on candidate from 1 party
# We only need probability for one candidate in each race
# I will use the democratic candidate

# Find races with data on only 1 candidate
single_party_markets <- market %>%
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

# Combine stats for candidates of the party
model %>%
  filter(race %in% c(multiple_dems, multiple_gop)) %>%
  group_by(date, race, party) %>%
  summarise(prob = sum(prob),
            min_share = sum(min_share),
            voteshare = sum(voteshare),
            max_share = sum(max_share))

# For markets with only Republicans, take the complimentary probability
# This process assumes all races will only have Republicans or Democrats
# For the few elections with two candidates of 1 party, leading candidate used

only_gop <-
  market %>%
  filter(race %in% single_party_markets,
         party == "R")

# Invert prices from "Yes" R to "No" R (i.e., "Yes" D)
only_gop$open  <- 1 - only_gop$open
only_gop$low   <- 1 - only_gop$low
only_gop$high  <- 1 - only_gop$high
only_gop$close <- 1 - only_gop$close

# Invert party from R to D
only_gop$party <- "D"

# Join back with original D markets
only_dem <- filter(market, party == "D")
markets <- bind_rows(only_gop, only_dem)

# Join with models
predictions2 <-
  left_join(markets, model,
            by = c("date", "race", "party")) %>%
  filter(date >= "2018-08-01",
         date <= "2018-11-05") %>%
  select(date, race, incumbent, chamber, prob, close) %>%

  # Tidy data, gather by predictive method
  rename(model  = prob,
         market = close) %>%
  gather(model, market,
         key   = method,
         value = prob) %>%
  arrange(date) %>%
  mutate(pick = if_else(prob > 0.50, TRUE, FALSE)) %>%

  # Join with election results
  left_join(results, by = "race") %>%

  # Compare the method prediction to actual winner
  mutate(correct = if_else(pick == winner, TRUE, FALSE)) %>%
  select(-pick, -winner)

predictions2 %>%
  group_by(date, method) %>%
  summarise(ratio = mean(correct, na.rm = TRUE)) %>%
  ggplot() +
  geom_line(aes(date, ratio, color = method), size = 2) +
  scale_color_manual(values = c("#ED713A", "#6633FF"))

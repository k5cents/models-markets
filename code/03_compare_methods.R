### Kiernan Nicholls
### American University
### Spring, 2019
### Predictr: markets vs models
### Check predictions against election results

library(tidyverse)

## We only need probability for one candidate in each race
## Some markets only have data on candidate from 1 party

# Take the complimentary probability if only GOP data
# Find race codes for markets with data on only one candidate
single_party_markets <- markets %>%
  group_by(date, race) %>%
  summarise(n = n()) %>%
  filter(n == 1) %>%
  ungroup() %>%
  select(race) %>%
  as_vector() %>%
  unique()

# Invert the GOP prices for markets with only GOP candidates
invert <- function(x) 1 - x

invert_gop <- markets %>%
  filter(race %in% single_party_markets,
         party == "R") %>%
  mutate(close = invert(close),
         party = "D")

# Take all but the only GOP markets
original_dem <- markets %>%
  filter(!race %in% invert_gop$race,
         party == "D")

# Combined both back together
markets2 <-
  bind_rows(original_dem, invert_gop) %>%
  select(date, race, close) %>%
  arrange(date, race)

# Create model data with only dem party info
model2 <- model %>%
  group_by(date, race, party) %>%
  summarise(prob = sum(prob)) %>%
  ungroup() %>%
  filter(party == "D") %>%
  select(-party)

# Join democratic predictions from both markets and models for comparison
# Keep market and model data in seperate columns
messy <-
  inner_join(markets2, model2,
            by  = c("date", "race")) %>%
  filter(date  >= "2018-08-01",
         date  <= "2018-11-05") %>%
  rename(model  = prob,
         market = close)

# Make the data tidy with each prediction as an observation
tidy <- messy %>%
  gather(model, market,
         key = method,
         value = prob) %>%
  arrange(date, race, method)

# Add in results to determine binary hits/misses

hits <- tidy %>%
  mutate(pred = prob > 0.5) %>%
  inner_join(results, by = "race") %>%
  mutate(hit = pred == winner) %>%
  select(date, race, method, prob, pred, winner, hit)

# Run a welch two sample t-test?

hits %$%
  t.test(hit ~ method, alternative = "greater") %>%
  use_series(p.value) %>%
  is_less_than(0.05)

# Run a 2-sample test for equality of proportions?

hits %>%
  select(date, race, method, hit) %>%
  spread(key = method,
         value = hit) %>%
  summarise(market = sum(market),
            model = sum(model)) %>%
  as_vector() %>%
  prop.test(n = nrow(hits)/2 %>% rep(2))


### Kiernan Nicholls
### Check predictions against election results

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
  left_join(markets2, model2,
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

hits <- messy %>%
  # remove uncalled race
  filter(race != "NC-09") %>%
  # add binary DEM prediction
  mutate(market_guess = if_else(market > 0.5, TRUE, FALSE),
         model_guess  = if_else(model  > 0.5, TRUE, FALSE)) %>%
  # add in election results
  left_join(results, by = "race") %>%
  select(-category) %>%
  # add binary DEM prediction
  mutate(market_hit = (market_guess == winner),
         model_hit = (model_guess == winner)) %>%
  mutate(week = lubridate::week(date),
         month = lubridate::month(date))

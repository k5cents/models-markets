### Kiernan Nicholls
### Check predictions against election results

## We only need probability for one candidate in each race
## Some markets only have data on candidate from 1 party

markets2 <- markets %>% filter(date >= "2018-08-01")

# Take the complimentary probability if only GOP data
# Find race codes for markets with data on only one candidate
single_party_markets <- markets2 %>%
  group_by(date, race) %>%
  summarise(n = n()) %>%
  filter(n == 1) %>%
  ungroup() %>%
  select(race) %>%
  as_vector() %>%
  unique()

# Invert the GOP prices for markets with only GOP candidates
invert <- function(x) 1 - x

invert_gop <- markets2 %>%
  filter(race %in% single_party_markets,
         party == "R") %>%
  mutate(close = invert(close),
         party = "D")

# Take all but the only GOP markets
original_dem <- markets2 %>%
  filter(!race %in% invert_gop$race,
         party == "D")

# Combined both back together
markets3 <-
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

# Join with models
tidy <-
  left_join(x   = markets3,
            y   = model2,
            by  = c("date", "race")) %>%
  filter(date  >= "2018-08-01",
         date  <= "2018-11-05") %>%
  rename(model  = prob,
         market = close) %>%
  gather(key    = method,
         value  = prob,
         model, market) %>%
  mutate(pick = if_else(prob > 0.50, TRUE, FALSE)) %>%
  left_join(results, by = "race") %>%
  mutate(correct = if_else(pick == winner, TRUE, FALSE)) %>%
  select(date, race, method, prob, winner, correct) %>%
  arrange(date, race) %>%
  distinct()

# Keep market and model data in seperate columns
messy <-
  left_join(x   = markets3,
            y   = model2,
            by  = c("date", "race")) %>%
  filter(date  >= "2018-08-01",
         date  <= "2018-11-05") %>%
  rename(model  = prob,
         market = close)



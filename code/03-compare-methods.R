### kiernan nicholls
### american university
### spring, 2020
### markets and models
### check predictions against results

# isolate predictions ------------------------------------------------------------------------

## we only need probability for one candidate in each race
## some markets only have data on candidate from 1 party

# take the complimentary probability if only GOP data
# find race codes for markets with data on only one candidate
single_party_markets <- markets %>%
  group_by(date, race) %>%
  summarise(n = n()) %>%
  filter(n == 1) %>%
  ungroup() %>%
  pull(race) %>%
  unique()

# invert the GOP prices for markets with only GOP candidates
invert <- function(x) 1 - x

invert_gop <- markets %>%
  filter(
    race %in% single_party_markets,
    party == "R"
  ) %>%
  mutate(
    close = invert(close),
    party = "D"
  )

# take all but the only GOP markets
original_dem <- markets %>%
  filter(
    !race %in% invert_gop$race,
    party == "D"
  )

# combined both back together
markets2 <-
  bind_rows(original_dem, invert_gop) %>%
  select(date, race, close) %>%
  arrange(date, race)

# create model data with only dem party info
model2 <- model %>%
  group_by(date, race, party) %>%
  summarise(prob = sum(prob)) %>%
  ungroup() %>%
  filter(party == "D") %>%
  select(-party)

# join wide ----------------------------------------------------------------------------------

# join democratic predictions from both markets and models for comparison
# Keep market and model data in seperate columns
messy <-
  inner_join(
    markets2, model2,
    by = c("date", "race")
  ) %>%
  filter(
    date >= "2018-08-01",
    date <= "2018-11-05"
  ) %>%
  rename(
    model = prob,
    market = close
  )

# pivot longer -------------------------------------------------------------------------------

# make the data tidy with each prediction as an observation
tidy <- messy %>%
  pivot_longer(
    cols = c("model", "market"),
    names_to = "method",
    values_to = "prob"
  ) %>%
  arrange(date, race, method)

# join results -------------------------------------------------------------------------------

hits <- tidy %>%
  mutate(pred = prob > 0.5) %>%
  inner_join(results, by = "race") %>%
  mutate(hit = pred == winner) %>%
  select(date, race, method, prob, pred, winner, hit)

# statistical tests --------------------------------------------------------------------------

# run a welch two sample t-test
# p-value = 0.001691
test_student <- t.test(
  formula = hit ~ method,
  data = hits,
  alternative = "greater"
)

# run a 2-sample test for equality of proportions
# p-value = 0.1324
test_prop <- hits %>%
  select(date, race, method, hit) %>%
  pivot_wider(
    names_from = "method",
    values_from = "hit"
  ) %>%
  select(market, model) %>%
  colSums() %>%
  prop.test(n = nrow(hits)/2 %>% rep(2))

# all
hits %>%
  group_by(pred, winner, method) %>%
  summarise(prob = mean(prob), n = n()) %>%
  arrange(pred, winner)

compare <- mutate(hits, brier_score = raise_to_power(winner - prob, 2))

# save text file
write_csv(
  x = compare,
  path = "data/new/compare.csv",
  na = ""
)

# run a brier score t-test
# p-value = 0.001691
test_brier <- t.test(
  formula = brier_score ~ method,
  data = compare
)

### Kiernan Nicholls
### Analyze the comparison between markets and models

hits <-
  left_join(x   = markets,
            y   = model,
            by  = c("date", "race")) %>%
  filter(date  >= "2018-08-01",
         date  <= "2018-11-05") %>%
  rename(model_guess  = prob,
         market_guess = close) %>%
  mutate(model_guess  = if_else(model_guess > 0.5, TRUE, FALSE),
         market_guess = if_else(market_guess > 0.5, TRUE, FALSE)) %>%
  left_join(results, by = "race") %>%
  mutate(model = (model_guess == winner),
         market = (market_guess == winner)) %>%
  select(date, race, model, market)

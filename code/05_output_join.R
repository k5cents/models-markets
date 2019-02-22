# Kiernan Nicholls
# Join market and model probabilities

predictions <-
  left_join(x = market,
            y = model,
            by = c("date", "race", "party")) %>%
  filter(date > "2018-08-01",
         date < "2018-11-06") %>%
  select(date,
         race,
         name,
         chamber,
         party,
         incumbent,
         special,
         close,
         prob) %>%
  rename(market = close,
         model = prob) %>%
  gather(market, model,
         key = "method",
         value = "prob") %>%
  arrange(date, race, name, method)

# Kiernan Nicholls
# Join market and model probabilities
library(tidyverse)

probs <-
  left_join(x = market,
            y = model,
            by = c("date", "code", "party")) %>%
  filter(date < "2018-11-06") %>%
  select(date,
         code,
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
  arrange(date, code, name, method)

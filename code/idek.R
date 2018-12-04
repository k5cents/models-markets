post <-
  left_join(joined, election_results, by = "code") %>%
  select(-name, -chamber, -mid, -cid, -class) %>%
  filter(party == "D") %>%
  select(date, code, prob, prob, price, volume, voteshare, dem, winner) %>%
  rename(p.vote = voteshare,
         r.vote = dem,
         market = prob,
         model = price) %>%
  mutate(diff = p.vote - r.vote,
         winner = if_else(winner == "D", T, F))

post <-
  post %>%
  mutate(model_guess = if_else(market > 0.5, TRUE, FALSE),
         market_guess = if_else(model > 0.5, TRUE, FALSE))

mean(post$model_guess == post$winner, na.rm = T)
mean(post$market_guess == post$winner, na.rm = T)
unique(post$code[which(post$model_guess != post$winner)])
unique(post$code[which(post$market_guess != post$winner)])

post2 <-
  left_join(joined, election_results, by = "code") %>%
  filter(date == "2018-11-01") %>%
  select(-name, -chamber, -mid, -cid, -class) %>%
  filter(party == "D") %>%
  select(date, code, prob, prob, price, volume, voteshare, dem, winner) %>%
  rename(p.vote = voteshare,
         r.vote = dem,
         market = prob,
         model = price) %>%
  mutate(diff = p.vote - r.vote,
         winner = if_else(winner == "D", T, F)) %>%
  mutate(model_guess = if_else(market > 0.5, TRUE, FALSE),
         market_guess = if_else(model > 0.5, TRUE, FALSE))

mean(post2$model_guess == post2$winner, na.rm = T)
mean(post2$market_guess == post2$winner, na.rm = T)
unique(post2$code[which(post2$model_guess != post2$winner)])
unique(post2$code[which(post2$market_guess != post2$winner)])

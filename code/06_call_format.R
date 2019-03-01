x <-
  market %>%
  group_by(race, date) %>%
  summarise(n = n()) %>%
  filter(n == 1) # races with only data on 1 candidate

y <- market[market$race %in% x$race, ] %>% filter(party != "D")

y$open  <- 1 - y$open
y$low   <- 1 - y$low
y$high  <- 1 - y$low
y$close <- 1 - y$close
y$party <- "D"

y <- y %>% bind_rows(filter(market, party == "D"))

x <- model %>% filter(party == "D")
xy <-
  left_join(y, x, by = c("date", "race", "party")) %>%
  filter(date >= "2018-08-01",
         date <= "2018-11-05") %>%
  arrange(date) %>%
  select(date, race, incumbent, chamber, prob, close) %>%
  rename(model = prob,
         market = close) %>%
  gather(model, market,
         key = method,
         value = prob) %>%
  arrange(date) %>%
  mutate(call = if_else(prob > 0.50, TRUE, FALSE)) %>%
  left_join(results, by = "race") %>%
  mutate(hit = if_else(call == won, TRUE, FALSE))

z <-
  xy %>%
  group_by(date, method) %>%
  summarise(ratio = mean(hit, na.rm = TRUE))

ggplot(z) +
  geom_line(aes(date, ratio, color = method), size = 2) +
  scale_color_manual(values = c("#ED713A", "#6633FF"))

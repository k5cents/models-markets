### Kiernan Nicholls
### Analyze the comparison between markets and models

hits <-
  left_join(x   = markets3,
            y   = model2,
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

h1 <-
  left_join(x   = markets3,
            y   = model2) %>%
  filter(date  == "2018-11-05") %>%
  rename(model  = prob,
         market = close)

h1 %>%
  ggplot(aes(x  = model,
             y  = market)) +
  geom_hline(yintercept = 0.5) +
  geom_vline(xintercept = 0.5) +
  geom_abline(slope = 1,
              intercept = 0) +
  geom_label(aes(label = race))

markets %>%
  filter(race == "NJ-02",
         date > "2018-11-01") %>%
  ggplot(aes(date, close)) +
  geom_line(aes(color = party))

h2 <- hits %>%
  mutate(week = week(date)) %>%
  group_by(week) %>%
  summarise(model = mean(model, na.rm = TRUE),
            market = mean(market, na.rm = TRUE)) %>%
  gather(model, market,
         key = method,
         value = prop) %>%
  arrange(week)

h2 %>%
  ggplot(aes(x = week,
             y = prop)) +
  geom_bar(aes(fill = method),
           stat = "identity",
           position = "dodge") +
  scale_fill_manual(values = c(color_market,
                               color_model)) +
  labs(title = "Proportion of Correct Predictions by Week",
       subtitle = "PredictIt Markets and FiveThirtyEight Model",
       y = "Proportion",
       x = "Week of Year") +
  coord_cartesian(ylim = c(0.75, 0.90))

h2 %>%
  ggplot(aes(x = week,
             y = prop)) +
  geom_line(aes(color = method), size = 3) +
  scale_color_manual(values = c(color_market,
                                color_model)) +
  labs(title = "Proportion of Correct Predictions by Week",
       subtitle = "PredictIt Markets and FiveThirtyEight Model",
       y = "Proportion",
       x = "Week of Year") +
  coord_cartesian(ylim = c(0.75, 0.90))

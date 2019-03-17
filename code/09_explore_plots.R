# Kiernan Nicholls
# Generate exploratory visuals

color_model <- "#ED713A" # 538 brand color
color_market <- colortools::triadic(color_model, plot = FALSE)[3] # complimentary

# Distribution of original probabilities by method
plot_races_hist <-
  # Join market onto model keep all model races
  left_join(x = model,
            y = markets,
            by = c("date", "race", "party")) %>%
  # Show only 1 candidate per race
  filter(date == "2018-11-05", party == "D") %>%
  select(date, close, prob) %>%
  rename(markets = close,
         model = prob) %>%
  gather(markets, model,
         key = "method",
         value = "prob") %>%
  ggplot() +
  geom_histogram(mapping = aes(x = prob, fill = method), binwidth = 0.10) +
  facet_wrap(~method, scales = "free_y") +
  scale_x_continuous(breaks = seq(from = 0, to = 1, by = 0.25)) +
  theme(legend.position = "bottom") +
  scale_fill_manual(values = c(color_market, color_model)) +
  theme(legend.position = "none") +
  labs(title = "Distribution of Race Probabilities by Predictive Method",
       x = "Democratic Win Probability",
       y = "Number of Races")

# Number of polls conducted over time
plot_cum_polls <-
  polling_data %>%
  group_by(start_date) %>%
  summarise(n = n()) %>%
  mutate(cum = cumsum(n)) %>%
  filter(start_date > "2018-01-01",
         start_date < "2018-11-05") %>%
  ggplot(aes(start_date, cum)) +
  geom_line(size = 2,
            color = "#ED713A") +
  labs(title = "Cumulative Number of Congressional Polls",
       x = "Date",
       y = "Polls to Date") +
  geom_vline(xintercept = as.Date("2018-08-01"), size = 0.5) +
  geom_vline(xintercept = as.Date("2018-11-04"), size = 0.5)

# Number of dollars traded over time
plot_cum_dollars <-
  markets %>%
  filter(date > "2018-01-01",
         date < "2018-11-05") %>%
  group_by(date) %>%
  mutate(traded = close * vol) %>%
  summarise(sum = sum(traded)) %>%
  mutate(cum = cumsum(sum)) %>%
  ggplot(aes(date, cum)) +
  geom_line(col = color_market, size = 2) +
  labs(title = "Cumulative Dollars Traded on Election Markets",
       x = "Date",
       y = "Dollars Traded to Date") +
  geom_vline(xintercept = as.Date("2018-08-01"), size = 0.5) +
  geom_vline(xintercept = as.Date("2018-11-04"), size = 0.5) +
  scale_y_continuous(labels = scales::dollar)

# Number of markets opened over time
plot_cum_markets <-
  markets %>%
  filter(date > "2018-01-01",
         date < "2018-11-05") %>%
  group_by(date) %>%
  summarise(count = n()) %>%
  ggplot() +
  geom_line(mapping = aes(date, count),
            size = 2,
            color = color_market) +
  labs(title = "Cumulative Number of Election Markets",
       x = "Date",
       y = "Markets to Date") +
  geom_vline(xintercept = as.Date("2018-08-01"), size = 0.5) +
  geom_vline(xintercept = as.Date("2018-11-04"), size = 0.5)


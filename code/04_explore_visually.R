# Kiernan Nicholls
# Generate exploratory visuals

color_blue   <- "#345995"
color_red    <- "#FB3640"
color_model  <- "#ED713A" # 538 brand color
color_market <- colortools::triadic("#ED713A", plot = FALSE)[3] # compliment

# Distribution of original probabilities by method
plot_races_hist <-
  # Join market onto model keep all model races
  full_join(x = model, y = markets, by = c("date", "race", "party"),
            ) %>%
  # Show only 1 candidate per race
  filter(date == "2018-11-05") %>%
  select(date, race, close, prob) %>%
  rename(markets = close, model = prob) %>%
  gather(markets, model, key = method, value = prob) %>%
  mutate(method = recode(method,
                         "model" = "Forecasting Model",
                         "markets" = "Prediction Markets")) %>%
  ggplot(mapping = aes(x = prob, fill = method)) +
  geom_histogram(binwidth = 0.10) +
  facet_wrap(~method, scales = "free_y") +
  theme(legend.position = "bottom") +
  scale_fill_manual(values = c(color_model, color_market)) +
  theme(legend.position = "none") +
  scale_x_continuous(breaks = seq(from = 0, to = 1, by = 0.2),
                     minor_breaks = 0,
                     labels = scales::percent) +
  labs(title = "Distribution of Race Probabilities by Predictive Method",
       x = "Democratic Win Probability",
       y = "Number of Races") +
  theme(legend.position = "none")

ggsave(plot = plot_races_hist,
       filename = "./plots/plot_races_hist.png",
       dpi = "retina",
       height = 5.625,
       width = 10)

# Number of polls conducted over time
plot_cum_polls <- polling %>%
  group_by(start_date) %>%
  summarise(n = n()) %>%
  mutate(cumsum = cumsum(n)) %>%
  filter(start_date >= "2018-01-01", start_date <= "2018-11-05") %>%
  ggplot(mapping = aes(x = start_date, y = cumsum)) +
  geom_line(color = color_model, size = 2) +
  geom_vline(xintercept = as.Date("2018-08-01"), size = 0.5) +
  geom_vline(xintercept = as.Date("2018-11-04"), size = 0.5) +
  labs(title = "Cumulative Number of Congressional Polls",
       x = "Date",
       y = "Polls to Date")

ggsave(plot = plot_cum_polls,
       filename = "./plots/plot_cum_polls.png",
       dpi = "retina",
       height = 5.625,
       width = 10)

# Number of dollars traded over time
plot_cum_dollars <- markets %>%
  filter(date >= "2018-01-01", date <= "2018-11-05") %>%
  group_by(date) %>%
  mutate(traded = close * vol) %>%
  summarise(sum = sum(traded, na.rm = TRUE)) %>%
  mutate(cumsum = cumsum(sum)) %>%
  ggplot(mapping = aes(x = date, y = cumsum)) +
  geom_line(color = color_market, size = 2) +
  geom_vline(xintercept = as.Date("2018-08-01"), size = 0.5) +
  geom_vline(xintercept = as.Date("2018-11-05"), size = 0.5) +
  scale_y_continuous(labels = scales::dollar) +
  labs(title = "Cumulative Dollars Traded on Election Markets",
       x = "Date",
       y = "Dollars Traded to Date")

ggsave(plot = plot_cum_dollars,
       filename = "./plots/plot_cum_dollars.png",
       dpi = "retina",
       height = 5.625,
       width = 10)

# Number of markets opened over time
plot_cum_markets <- markets %>%
  filter(date > "2018-01-01", date < "2018-11-05") %>%
  group_by(date) %>%
  summarise(count = n()) %>%
  ggplot(mapping = aes(x = date, y = count)) +
  geom_line(color = color_market, size = 2) +
  geom_vline(xintercept = as_date("2018-08-01"), size = 0.5) +
  geom_vline(xintercept = as_date("2018-11-05"), size = 0.5) +
  labs(title = "Cumulative Number of Election Markets",
       x = "Date",
       y = "Markets to Date")

ggsave(plot = plot_cum_markets,
       filename = "./plots/plot_cum_markets.png",
       dpi = "retina",
       height = 5.625,
       width = 10)

# Races by Model on X and Market on Y
plot_cart_labels <- messy %>%
  filter(date == "2018-11-05") %>%
  ggplot(aes(x  = model, y  = market)) +
  geom_hline(yintercept = 0.5) +
  geom_vline(xintercept = 0.5) +
  geom_abline(slope = 1, intercept = 0) +
  geom_label(aes(label = race)) +
  scale_y_continuous(labels = scales::percent) +
  scale_x_continuous(labels = scales::percent) +
  labs(title = "Midterm Races by Democrats Chance of Winning",
       subtitle = "Day Before Election, 2018-11-05",
       x = "FiveThirtyEight Model",
       y = "PredictIt Market")

ggsave(plot = plot_cart_labels,
       filename = "./plots/plot_cart_labels.png",
       dpi = "retina",
       height = 10,
       width = 10)

plot_cart_points <- messy %>%
  mutate(party = "D") %>%
  filter(date == "2018-11-05") %>%
  left_join(model, by = c("date", "race", "party")) %>%
  ggplot(aes(x  = model, y  = market)) +
  geom_hline(yintercept = 0.5) +
  geom_vline(xintercept = 0.5) +
  geom_abline(slope = 1, intercept = 0) +
  geom_label(aes(x = 0.25, y = 0.75, label = "Market Predicts Win")) +
  geom_label(aes(x = 0.75, y = 0.25, label = "Model Predicts Win")) +
  geom_label(aes(x = 0.25, y = 0.25, label = "Both Predict Loss")) +
  geom_label(aes(x = 0.75, y = 0.75, label = "Both Predict Win")) +
  geom_point(aes(color = incumbent, shape = chamber), size = 4) +
  scale_y_continuous(labels = scales::dollar) +
  scale_x_continuous(labels = scales::percent) +
  scale_color_manual(values = c(color_model, color_blue)) +
  labs(title = "Midterm Races by Democrat's Chance of Winning",
       subtitle = "November 5th, Night Before Election Day",
       x = "FiveThirtyEight Model Probability",
       y = "PredictIt Market Price")

ggsave(plot = plot_cart_points,
       filename = "./plots/plot_cart_points.png",
       dpi = "retina",
       height = 10,
       width = 10)

# Weird NJ-02 Market Error
plot_nj_02 <- markets %>%
  filter(race == "NJ-02", date > "2018-10-25") %>%
  ggplot(aes(x = date, y = close)) +
  geom_hline(yintercept = 0.5) +
  geom_line(aes(color = party), size = 2) +
  scale_color_manual(values = c(color_blue, color_red)) +
  scale_y_continuous(labels = scales::dollar) +
  scale_x_date() +
  labs(title = "Price History of New Jersey 2nd Betting Market",
       x = "Date",
       y = "Closing Price")

ggsave(plot = plot_nj_02,
       filename = "./plots/plot_nj_02.png",
       dpi = "retina",
       height = 5.625,
       width = 10)

plot_prop_month <- hits %>%
  filter(date < "2018-11-01") %>%
  group_by(month) %>%
  summarise(market_prop = mean(market_hit, na.rm = TRUE),
            model_prop = mean(model_hit, na.rm = TRUE)) %>%
  gather(model_prop, market_prop, key = method, value = prop) %>%
  mutate(method = recode(method,
                         "model_prop" = "Model",
                         "market_prop" = "Market")) %>%
  ggplot(aes(x = month, y = prop, fill = method)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c(color_market, color_model)) +
  labs(title = "Proportion of Correct Predictions by Week",
       subtitle = "PredictIt Markets and FiveThirtyEight Model",
       y = "Proportion",
       x = "Month of Year") +
  coord_cartesian(ylim = c(0.50, 1.0)) +
  scale_y_continuous(labels = scales::percent) +
  scale_x_continuous(minor_breaks = 0)

ggsave(plot = plot_prop_month,
       filename = "./plots/plot_prop_month.png",
       dpi = "retina",
       height = 5.625,
       width = 10)

plot_prop_week <- hits %>%
  group_by(week) %>%
  summarise(market_prop = mean(market_hit, na.rm = TRUE),
            model_prop = mean(model_hit, na.rm = TRUE)) %>%
  gather(model_prop, market_prop, key = method, value = prop) %>%
  mutate(method = recode(method,
                         "model_prop" = "Model",
                         "market_prop" = "Market")) %>%
  ggplot(aes(x = week, y = prop, color = method)) +
  geom_line(size = 3) +
  coord_cartesian(ylim = c(0.75, 0.95)) +
  scale_y_continuous(labels = scales::percent) +
  scale_color_manual(values = c(color_market, color_model)) +
  labs(title = "Proportion of Correct Predictions by Week",
       subtitle = "PredictIt Markets and FiveThirtyEight Model",
       y = "Proportion",
       x = "Week of Year")

ggsave(plot = plot_prop_week,
       filename = "./plots/plot_prop_week.png",
       dpi = "retina",
       height = 5.625,
       width = 10)

plot_prop_day <- hits %>%
  group_by(date) %>%
  summarise(market_prop = mean(market_hit, na.rm = TRUE),
            model_prop = mean(model_hit, na.rm = TRUE)) %>%
  gather(model_prop, market_prop, key = method, value = prop) %>%
  mutate(method = recode(method,
                         "model_prop" = "Model",
                         "market_prop" = "Market")) %>%
  ggplot(aes(x = date, y = prop, color = method)) +
  geom_line(size = 2) +
  coord_cartesian(ylim = c(0.75, 0.95)) +
  scale_y_continuous(labels = scales::percent) +
  scale_color_manual(values = c(color_market, color_model)) +
  labs(title = "Proportion of Correct Predictions by Week",
       subtitle = "PredictIt Markets and FiveThirtyEight Model",
       y = "Proportion",
       x = "Day of Year")

ggsave(plot = plot_prop_day,
       filename = "./plots/plot_prop_day.png",
       dpi = "retina",
       height = 5.625,
       width = 10)

### Kiernan Nicholls
### American University
### Spring, 2019
### Predictr: markets vs models
### Generate exploratory visuals

library(ggplot2)

color_model  <- "#ED713A" # 538 brand color
color_market <- "#07A0BB" # PredictIt brand color
color_blue   <- "royalblue3" # Democratic
color_red    <- "red3" # Republican

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
  mutate(method = method %>% recode("model" = "Forecasting Model",
                                    "markets" = "Prediction Markets")) %>%
  ggplot(mapping = aes(x = prob, fill = method)) +
  geom_histogram(binwidth = 0.10) +
  facet_wrap(~method, scales = "free_y", drop = TRUE) +
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
       filename = here("plots", "plot_races_hist.png"),
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
       filename = here("plots", "plot_cum_polls.png"),
       dpi = "retina",
       height = 5.625,
       width = 10)

# Number of dollars traded over time
plot_cum_dollars <- markets %>%
  filter(date >= "2018-01-01", date <= "2018-11-05") %>%
  group_by(date) %>%
  mutate(traded = close * volume) %>%
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
       filename = here("plots", "plot_cum_dollars.png"),
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
       filename = here("plots", "plot_cum_markets.png"),
       dpi = "retina",
       height = 5.625,
       width = 10)

# Races by Model on X and Market on Y
plot_cart_labels <- messy %>%
  mutate(party = "D") %>%
  filter(date == "2018-11-05") %>%
  left_join(model, by = c("date", "race", "party")) %>%
  inner_join(results, by = "race") %>%
  ggplot(aes(x  = model, y  = market)) +
  geom_hline(yintercept = 0.5) +
  geom_vline(xintercept = 0.5) +
  geom_abline(slope = 1, intercept = 0) +
  geom_label(aes(fill = winner, label = race)) +
  scale_y_continuous(labels = scales::dollar) +
  scale_x_continuous(labels = scales::percent) +
  scale_fill_manual(values = c("red", "forestgreen")) +
  labs(title = "Midterm Races by Democrat's Chance of Winning",
       subtitle = "November 5th, Night Before Election Day",
       x = "Model Probability",
       y = "Market Price",
       shape = "Chamber",
       color = "Incumbency")

ggsave(plot = plot_cart_labels,
       filename = here("plots", "plot_cart_labels.png"),
       dpi = "retina",
       height = 9,
       width = 10)

plot_cart_points <- messy %>%
  mutate(party = "D") %>%
  filter(date == "2018-11-05") %>%
  left_join(model, by = c("date", "race", "party")) %>%
  inner_join(results, by = "race") %>%
  ggplot(aes(x  = model, y  = market)) +
  geom_hline(yintercept = 0.5) +
  geom_vline(xintercept = 0.5) +
  geom_label(mapping = aes(x = 0.25, y = 0.75, label = "Market Predicts Win"),
             label.size = 0,
             fill = "#ebebeb",
             size = 6) +
  geom_label(mapping = aes(x = 0.75, y = 0.25, label = "Model Predicts Win"),
             label.size = 0,
             fill = "#ebebeb",
             size = 6) +
  geom_label(mapping = aes(x = 0.25, y = 0.25, label = "Both Predict Loss"),
             label.size = 0,
             fill = "#ebebeb",
             size = 6) +
  geom_label(mapping = aes(x = 0.75, y = 0.75, label = "Both Predict Win"),
             label.size = 0,
             fill = "#ebebeb",
             size = 6) +
  geom_abline(slope = 1, intercept = 0, lty = 2) +
  geom_point(aes(color = winner, shape = chamber), size = 4) +
  scale_y_continuous(labels = scales::dollar) +
  scale_x_continuous(labels = scales::percent) +
  scale_color_manual(values = c("red", "forestgreen")) +
  labs(title = "Midterm Races by Democrat's Chance of Winning",
       subtitle = "November 5th, Night Before Election Day",
       x = "Model Probability",
       y = "Market Price",
       shape = "Chamber",
       color = "Democrat Won")

ggsave(plot = plot_cart_points,
       filename = here("plots", "plot_cart_points.png"),
       dpi = "retina",
       height = 5.625,
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
       filename = here("plots", "plot_nj_02.png"),
       dpi = "retina",
       height = 5.625,
       width = 10)

plot_prop_month <- hits %>%
  mutate(month = month(date, label = TRUE)) %>%
  group_by(month, method) %>%
  summarise(prop = mean(hit, na.rm = TRUE)) %>%
  ggplot(aes(x = month, y = prop, fill = method)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c(color_market, color_model)) +
  coord_cartesian(ylim = c(0.50, 1.0)) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Proportion of Correct Predictions by Month",
       subtitle = "PredictIt Markets and FiveThirtyEight Model",
       y = "Proportion",
       x = "Month of Year")

ggsave(plot = plot_prop_month,
       filename = here("plots", "plot_prop_month.png"),
       dpi = "retina",
       height = 5.625,
       width = 10)

plot_prop_week <- hits %>%
  mutate(week = week(date)) %>%
  group_by(week, method) %>%
  summarise(prop = mean(hit, na.rm = TRUE)) %>%
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
       filename = here("plots", "plot_prop_week.png"),
       dpi = "retina",
       height = 5.625,
       width = 10)

plot_prop_day <- hits %>%
  group_by(date, method) %>%
  summarise(prop = mean(hit, na.rm = TRUE)) %>%
  ggplot(aes(x = date, y = prop, color = method)) +
  geom_line(size = 2) +
  coord_cartesian(ylim = c(0.75, 0.95)) +
  scale_y_continuous(labels = scales::percent) +
  scale_color_manual(values = c(color_market, color_model)) +
  labs(title = "Proportion of Correct Predictions by Day",
       subtitle = "PredictIt Markets and FiveThirtyEight Model",
       y = "Proportion",
       x = "Day of Year")

ggsave(plot = plot_prop_day,
       filename = here("plots", "plot_prop_day.png"),
       dpi = "retina",
       height = 5.625,
       width = 10)

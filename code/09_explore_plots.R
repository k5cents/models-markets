# Kiernan Nicholls
# Generate exploratory visuals

col_model <- "#ED713A" # 538 brand color
col_market <- colortools::triadic(col_model, plot = FALSE)[3] # complimentary

# Accuracy of each method over time
plot_accuracy_time <-
  predictions %>%
  group_by(date, method) %>%
  summarise(accuracy = mean(correct, na.rm = TRUE)) %>%
  ggplot() +
  geom_line(aes(date, accuracy,
                color = method), size = 2) +
  scale_color_manual(values = c("#6633FF", "#ED713A")) +
  labs(title = "Accuracy over Time by Predictive Method",
       subtitle = "FiveThirtyEight model and PredictIt markets for races of interest",
       x = "Date of Prediction",
       y = "Correct Predictions") +
  scale_y_continuous(labels = scales::percent) +
  coord_cartesian(ylim = c(0, 1))

# Number of polls conducted over time
plot_n_polls <-
  polling_data %>%
  group_by(start_date) %>%
  summarise(n = n()) %>%
  mutate(cum = cumsum(n)) %>%
  filter(start_date > "2018-01-01",
         start_date < "2018-11-05") %>%
  ggplot(aes(start_date, cum)) +
  geom_line(size = 2, color = "#ED713A") +
  labs(title = "Cumulative Number of Congressional Polls",
       subtitle = "Across all Congressional races, conducted by all polling firms in 2018",
       x = "Date",
       y = "Polls to Date") +
  geom_vline(xintercept = as.Date("2018-08-01"), size = 1) +
  geom_vline(xintercept = as.Date("2018-11-05"), size = 1) +
  geom_label(mapping = aes(x = as.Date("2018-09-18"),
                           y = 500,
                           label = "Span of Model"),
             fill = "#ebebeb",
             label.size = 0,
             size = 7)

# Number of markets opened over time
plot_n_markets <-
  market %>%
  filter(date > "2018-08-01",
         date < "2018-11-05") %>%
  group_by(date) %>%
  summarise(count = n()) %>%
  ggplot() +
  geom_line(mapping = aes(date, count),
            size = 4,
            color = col_market) +
  labs(title = "Cumulative Number of Election Markets Over Time",
       subtitle = "On PredictIt.org from August 1st to Election Day 2018",
       x = "Date",
       y = "Number of Elections")

# Distribution of original probabilities by method
plot_races_hist <-
  # Join market onto model keep all model races
  left_join(x = model,
            y = market,
          by = c("date", "race", "party")) %>%
  # Show only 1 candidate per race
  filter(date == "2018-11-05", party == "D") %>%
  select(date, close, prob) %>%
  rename(market = close,
         model = prob) %>%
  gather(market, model,
         key = "method",
         value = "prob") %>%
  ggplot() +
  geom_histogram(mapping = aes(x = prob, fill = method), binwidth = 0.10) +
  facet_wrap(~method, scales = "free_y") +
  scale_x_continuous(breaks = seq(from = 0, to = 1, by = 0.25)) +
  theme(legend.position = "bottom") +
  scale_fill_manual(values = c(col_market, col_model)) +
  theme(legend.position = "none") +
  labs(title = "Distribution of Race Probabilities by Predictive Method",
       subtitle = "Day Before Election",
       x = "Democratic Win Probability",
       y = "Number of Races")

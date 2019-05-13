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
plot_distribution <-
  # Join market onto model keep all model races
  full_join(x = model, y = markets, by = c("date", "race", "party")) %>%
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
  scale_fill_manual(values = c(color_model, color_market)) +
  theme(legend.position = "none",
        legend.key = element_blank()) +
  scale_x_continuous(breaks = seq(from = 0, to = 1, by = 0.2),
                     minor_breaks = 0,
                     labels = scales::percent) +
  labs(title = "Distribution of Race Probabilities by Predictive Method",
       x = "Democratic Win Probability",
       y = "Number of Races") +
  theme(legend.position = "none")

ggsave(plot = plot_distribution,
       filename = here("plots", "plot_distribution.png"),
       dpi = "retina",
       height = 5.625,
       width = 10)

plot_cartesian <- messy %>%
  mutate(party = "D") %>%
  filter(date == "2018-11-05") %>%
  left_join(model, by = c("date", "race", "party")) %>%
  inner_join(results, by = "race") %>%
  ggplot(mapping = aes(x = model, y = market)) +
  geom_hline(yintercept = 0.5) +
  geom_vline(xintercept = 0.5) +
  geom_label(mapping = aes(label = "Market Predicts Win", x = 0.25, y = 0.75),
             label.size = 0,
             fill = "#ebebeb",
             size = 6) +
  geom_label(mapping = aes(label = "Model Predicts Win", x = 0.75, y = 0.25),
             label.size = 0,
             fill = "#ebebeb",
             size = 6) +
  geom_label(mapping = aes(label = "Both Predict Loss", x = 0.25, y = 0.25),
             label.size = 0,
             fill = "#ebebeb",
             size = 6) +
  geom_label(mapping = aes(label = "Both Predict Win", x = 0.75, y = 0.75),
             label.size = 0,
             fill = "#ebebeb",
             size = 6) +
  geom_abline(slope = 1,
              intercept = 0,
              lty = 2) +
  geom_point(mapping = aes(color = winner, shape = chamber),
             size = 6,
             alpha = 0.66) +
  scale_y_continuous(labels = scales::dollar) +
  scale_x_continuous(labels = scales::percent) +
  scale_color_manual(values = c("red", "forestgreen")) +
  theme(legend.position = "bottom",
        legend.key = element_blank()) +
  labs(title = "Races by Democratic Probability",
       subtitle = "November 5th, 2018",
       x = "Model Probability",
       y = "Market Price",
       shape = "Chamber",
       color = "Won")

ggsave(plot = plot_cartesian,
       filename = here("plots", "plot_cartesian.png"),
       dpi = "retina",
       height = 10,
       width = 10)

# Weird NJ-02 Market Error
plot_manipulation <- markets %>%
  filter(race == "NJ-02",
         date > "2018-10-25") %>%
  ggplot(aes(x = date, y = close)) +
  geom_hline(yintercept = 0.5) +
  geom_line(mapping = aes(color = party),
            size = 2) +
  scale_color_manual(values = c(color_blue, color_red)) +
  scale_y_continuous(labels = scales::dollar) +
  scale_x_date() +
  labs(title = "Price History of New Jersey 2nd Betting Market",
       color = "Method",
       x = "Date",
       y = "Closing Price")

ggsave(plot = plot_manipulation,
       filename = here("plots", "plot_manipulation.png"),
       dpi = "retina",
       height = 5.625,
       width = 10)

plot_proportion <- hits %>%
  mutate(week = week(date)) %>%
  group_by(week, method) %>%
  summarise(prop = mean(hit, na.rm = TRUE)) %>%
  ggplot(mapping = aes(x = week, y = prop, color = method)) +
  geom_line(size = 2) +
  coord_cartesian(ylim = c(0.75, 0.95)) +
  scale_y_continuous(labels = scales::percent) +
  scale_color_manual(values = c(color_market, color_model)) +
  theme(legend.position = "bottom",
        legend.key = element_blank()) +
  labs(title = "Proportion Accuracy",
       color = "Method",
       y = "Proportion",
       x = "Week of Year")

ggsave(plot = plot_proportion,
       filename = here("plots", "plot_proportion.png"),
       dpi = "retina",
       height = 5.625,
       width = 10)

plot_brier <- hits %>%
  mutate(brier = (prob - winner)^2) %>%
  mutate(week = week(date)) %>%
  group_by(week, method) %>%
  summarise(mean = mean(brier, na.rm = TRUE)) %>%
  ggplot(aes(x = week, y = mean, color = method)) +
  geom_line(size = 2) +
  scale_color_manual(values = c(color_market, color_model)) +
  theme(legend.position = "bottom",
        legend.key = element_blank()) +
  labs(title = "Prediction Score",
       color = "Method",
       y = "Mean Brier Score",
       x = "Week of Year")

ggsave(plot = plot_brier,
       filename = here("plots", "plot_brier.png"),
       dpi = "retina",
       height = 5.625,
       width = 10)

plot_calibration <- hits %>%
  mutate(bin = prob %>% round(digits = 1)) %>%
  group_by(method, bin) %>%
  summarise(prop = mean(winner), n = n()) %>%
  ggplot(mapping = aes(bin, prop)) +
  geom_abline(intercept = 0, slope = 1, lty = 2)  +
  geom_point(mapping = aes(color = method, size = n), alpha = 0.75) +
  geom_label(mapping = aes(label = "Underconfident", x = 0.25, y = 0.75),
             label.size = 0,
             fill = "#ebebeb",
             size = 6) +
  geom_label(mapping = aes(label = "Overconfident", x = 0.75, y = 0.25),
             label.size = 0,
             fill = "#ebebeb",
             size = 6) +
  scale_x_continuous(breaks = seq(0, 1, 0.1), minor_breaks = 0,
                     labels = scales::percent) +
  scale_y_continuous(breaks = seq(0, 1, 0.1), minor_breaks = 0,
                     labels = scales::percent) +
  scale_color_manual(values = c(color_market, color_model), guide = FALSE) +
  scale_size(range = c(5, 20), guide = FALSE) +
  theme(legend.position = "bottom",
        legend.key = element_blank()) +
  labs(title = "Prediction Calibration",
       y = "Actual Proportion",
       x = "Expected Proportion")

ggsave(plot = plot_calibration,
       filename = here("plots", "plot_calibration.png"),
       dpi = "retina",
       height = 10,
       width = 10)

plot_confidence <- hits %>%
  group_by(date, method, hit) %>%
  summarise(mean = mean(prob)) %>%
  ggplot(mapping = aes(x = date, y = mean)) +
  geom_hline(yintercept = 0.50, lty = 2) +
  geom_line(mapping = aes(color = method, linetype = hit),
            size = 1) +
  scale_color_manual(values = c(color_market, color_model)) +
  scale_y_continuous(labels = scales::percent) +
  theme(legend.position = "bottom",
        legend.key = element_blank()) +
  labs(title = "Prediction Confidence",
       y = "Mean Probability",
       color = "Method",
       linetype = "Correct")

ggsave(plot = plot_confidence,
       filename = here("plots", "plot_confidence.png"),
       dpi = "retina",
       height = 5.625,
       width = 10)

# Number of dollars traded over time
plot_dollars <- markets %>%
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

ggsave(plot = plot_dollars,
       filename = here("plots", "plot_dollars.png"),
       dpi = "retina",
       height = 5.625,
       width = 10)

# Number of markets opened over time
plot_markets <- markets %>%
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

ggsave(plot = plot_markets,
       filename = here("plots", "plot_markets.png"),
       dpi = "retina",
       height = 5.625,
       width = 10)

# Number of polls conducted over time
plot_polls <- polling %>%
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

ggsave(plot = plot_polls,
       filename = here("plots", "plot_polls.png"),
       dpi = "retina",
       height = 5.625,
       width = 10)

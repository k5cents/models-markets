library(tidyverse)
election_results <- read_csv("./data/election_results.csv")
joined <-
  read_csv("./data/joined.csv") %>%
  mutate(party = recode(party, "I" = "D"))

# market over time --------------------------------------------------------

model_correct <- function(data, day) {
  guess <-
    data %>%
    left_join(election_results, by = "code") %>%
    filter(date == day) %>%
    filter(party == "D") %>%
    mutate(guess = if_else(condition = voteshare > 0.5,
                           true = "D",
                           false = "R")) %>%
    mutate(correct = guess == winner) %>%
    select(code, prob, voteshare, dem, guess, winner) %>%
    rename(before = voteshare,
           after = dem)
  return(mean(guess$guess == guess$winner, na.rm = T))
}

accuracy <- tibble(day = unique(joined$date),
                     model_accuracy = rep(NA, n_distinct(joined$date)),
                     market_accuracy = rep(NA, n_distinct(joined$date)))

for (i in 1:nrow(accuracy)) {
  accuracy$model_accuracy[i] <-
    model_correct(joined, day = accuracy$day[i])
}

# model over time ---------------------------------------------------------

market_correct <- function(data, day) {
  guess <-
    data %>%
    left_join(election_results, by = "code") %>%
    filter(date == day) %>%
    filter(party == "D") %>%
    mutate(guess = if_else(condition = price > 0.5,
                           true = "D",
                           false = "R")) %>%
    mutate(correct = guess == winner) %>%
    select(code, price, volume, dem, guess, winner) %>%
    rename(after = dem)
  return(mean(guess$guess == guess$winner, na.rm = T))
}

for (i in 1:nrow(accuracy)) {
  accuracy$market_accuracy[i] <-
    market_correct(joined, day = accuracy$day[i])
}


# plot --------------------------------------------------------------------

accuracy <-
  accuracy %>%
  gather(key = tool,
         value = accuracy,
         model_accuracy,
         market_accuracy) %>%
  filter(day < "2018-11-06") %>%
  arrange(day) %>%
  mutate(tool = recode(tool,
                       "model_accuracy" = "model",
                       "market_accuracy" = "market"))

write_csv(accuracy, "./data/accuracy.csv")


accuracy_over_time <-
  ggplot(accuracy) +
  geom_smooth(aes(x = day,
                  y = accuracy,
                  color = tool))

ggsave(filename = "./plots/accuracy_over_time.png",
       plot = accuracy_over_time,
       dpi = "retina")

library(tidyverse)

plot_odds <- function(candidate = NULL) {
  forecast <- read_csv("./data/forecast_history.csv")
  market <- read_csv("./data/market_history.csv")
  name <- candidate
  race <-
    left_join(filter(forecast, candidate == as.character(name)),
              filter(market, market.name == stringr::word(name, 2))) %>%
    gather(key = "tool",
           value = "prob",
           "win.prob",
           "market.price")
  plot(ggplot(race) +
         geom_line(mapping = aes(x = date, y= prob, color = tool)) +
         coord_cartesian(ylim = c(0, 1)) +
         ggtitle(as.character(unique(race$candidate))))
}

plot_odds(candidate = "Ted Cruz")

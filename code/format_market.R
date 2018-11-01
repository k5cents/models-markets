# head --------------------------------------------------------------------
library(tidyverse)

forecast.history <-
  read_csv("./data/forecast_history.csv",
                     col_types = cols()) %>%
  unite(col = code,
        state, district,
        sep = "-",
        remove = FALSE)

congress.mebers <-
  read_csv("./data/congress_members.csv",
           col_types = cols()) %>%
  unite(col = code,
        state, district,
        sep = "-",
        remove = FALSE)

markets.history <-
  read_csv("./data/market_history.csv",
           col_types = cols())


for (i in 1:nrow(markets)) {
  crow <- which(congress$last_name == markets$market.name[i])
  markets$chamber[i] <- congress$chamber[crow]
  markets$district[i] <- congress$district[crow]
  markets$party[i] <- congress$party[crow]
  markets$state[i] <- congress$state[crow]
  markets$candidate[i] <- congress$last_name[crow]
}

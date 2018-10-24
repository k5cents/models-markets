# head --------------------------------------------------------------------
# Kiernan Nicholls
# 2018-10-20
# Collect prediction market data
library(tidyverse)
library(httr)
library(jsonlite)
tic("total")
# api to tibble -----------------------------------------------------------
tic("api")
raw <- GET(url = "https://www.predictit.org/",
           path = "api/marketdata/all/")
as.char <- rawToChar(raw$content)
as.list <- fromJSON(as.char)
as.df <- do.call(what = "rbind",
                 args = lapply(as.list, as.data.frame))
markets.all <-
  as_tibble(as.df) %>%
  select(id, shortName)

# trim --------------------------------------------------------------------
# select all markets having to do with re-election or midterms
markets.all <- markets.all[c(grep("re-elect", markets.all$shortName),
                             grep("Which party will", markets.all$shortName)), ]

# remove the ones having to do with governor's races
markets.all <- markets.all[-grep("governor's", markets.all$shortName), ]

# function ----------------------------------------------------------------
toc()
tic("read")
predictit_hist <- function(id = NULL, span = "90d") {
  # define the URL of a single market
  market.url <- paste0("https://www.predictit.org/",
                       "Resource/DownloadMarketChartData",
                       "?marketid=", as.character(id),
                       "&timespan=", as.character(span))
  # download the chart data from defined market
  market.history <-
    read_csv(market.url,
             col_types = cols()) %>%
    select(DateString,
           MarketId,
           ContractName,
           CloseSharePrice,
           TradeVolume) %>%
    rename(date = DateString,
           id = MarketId,
           contract = ContractName,
           price = CloseSharePrice,
           volume = TradeVolume)
  return(market.history)
}

# loop pull ---------------------------------------------------------------
# initialize the vector
markets.list <- rep(list(NA), nrow(markets.all))
# for every market grabed from API, load into list slot
for (i in 1:length(markets.list)) {
  markets.list[[i]] <- predictit_hist(id = markets.all$id[i])
}
# combine the list elements
markets <- bind_rows(markets.list)
# merge with both contract and market names
markets <- as_tibble(merge(markets, markets.all))
# remove uninformative contract names
markets <- as_tibble(markets[, -3])
markets <- arrange(markets, date)

# extract candidate name or district from market name
toc()
tic("format")
markets$market.name <- if_else(condition = word(markets$shortName, 3) == "be",
                               true = word(markets$shortName, 2),
                               false =
                                 if_else(condition = word(markets$shortName, 1) == "Will",
                                         true = word(markets$shortName, 3),
                                         false =
                                           if_else(condition = word(markets$shortName, 1) == "Which",
                                                   true = gsub("?", "", word(markets$shortName, 5), fixed = T),
                                                   false = "FALSE")))
market.history <- markets %>%
  select(date,
         market.name,
         id,
         volume,
         price,
         shortName) %>%
  rename(market.id = id,
         trade.volume = volume,
         market.price = price,
         market.question = shortName)

write_csv(market.history, "./data/market_history.csv")

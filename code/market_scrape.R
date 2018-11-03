# Kiernan Nicholls
# Fall 2018
# GOVT-696
# Get market names and history from PredictIt
library(tidyverse)
library(httr)
library(jsonlite)

# get market names --------------------------------------------------------

# this function will download an API XML tree as a tibble
predictit_api <- function(api.url, api.path) {
  raw <- GET(url = api.url,
             path = api.path)
  as.char <- rawToChar(raw$content)
  as.list <- fromJSON(as.char)
  as.df <- do.call(what = "rbind",
                   args = lapply(as.list, as.data.frame))
  return(as_tibble(as.df))
}

market.names <-
  # run the function to get the tibble of open PredictIt markets
  predictit_api(api.url = "https://www.predictit.org/",
                api.path = "api/marketdata/all/") %>%
  # the API has a 'contract' tree within each market
  # the 'contract' lists the buy options for each market
  # our function downloads these as tibbles inside of a tibble value
  # unnest() grabs pulls these out as their own rows
  unnest() %>%
  select(id,
         shortName,
         id1,
         longName,
         shortName1) %>%
  rename(question = shortName,
         mid = id,
         cid = id1,
         contract = longName,
         option = shortName1) %>%
  # select only markets having to do with re-election or midterms
  filter(str_detect(question, "re-elect") |
         str_detect(question, "Which party will") !=
  # and not having to do with governor races
         str_detect(question, "governor's"))

# get market history ------------------------------------------------------

# this function visits the page for a PredictIt.org market
# then downloads the market history from the provided chart
predictit_scrape <- function(id = NULL, span = "90d") {
  # define the URL of a single market
  market.url <- paste0("https://www.predictit.org/",
                       "Resource/DownloadMarketChartData",
                       "?marketid=", as.character(id),
                       "&timespan=", as.character(span))
  # download the chart data from said market
  market.chart <-
    read_csv(market.url,
             col_types = cols()) %>%
    select(DateString,
           MarketId,
           ContractId,
           ContractName,
           CloseSharePrice,
           TradeVolume) %>%
    rename(date = DateString,
           mid = MarketId,
           cid = ContractId,
           contract = ContractName,
           price = CloseSharePrice,
           volume = TradeVolume)
  return(market.chart)
}

# initialize the a list to fill with history of each market
markets.list <- rep(list(NA), nrow(market.names))

# for every market grabed from API, load history into list element
for (i in 1:nrow(market.names)) {
  markets.list[[i]] <- predictit_scrape(id = market.names$mid[i])
}

# combine the list elements into a single tibble
market.history <- bind_rows(markets.list)
rm(markets.list)

write_csv(x = market.names, path = "./data/market_names.csv")
write_csv(x = market.history, path = "./data/market_history.csv")

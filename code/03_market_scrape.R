# Kiernan Nicholls
# Fall 2018
# GOVT-696
# Get market names and history from PredictIt
library(tidyverse)
library(httr)
library(jsonlite)

# get market names --------------------------------------------------------
# THIS NO LONGER WORKS, OR IS NEEDED. TODAY'S API NO LONGER HAS THE RELEVANT
# MARKETS, ALTHO THE CHART DATA CAN BE SCRAPED FOR 90 DAYS BEFORE CLOSURE


# this function will download an API XML tree as a tibble
scrape_predictit_api <- function(api.url, api.path) {
  raw <- GET(url = api.url,
             path = api.path)
  as.char <- rawToChar(raw$content)
  as.list <- fromJSON(as.char)
  as.df <- do.call(what = "rbind",
                   args = lapply(as.list, as.data.frame))
  return(as_tibble(as.df))
}

market_names <-
  # run the function to get the tibble of open PredictIt markets
  scrape_predictit_api(api.url = "https://www.predictit.org/",
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

market_names <- read_csv("./data/market_names.csv",
                         col_types = cols(mid = col_character(),
                                          cid = col_character()))

# get market history ------------------------------------------------------

# this function visits the page for a PredictIt.org market
# then downloads the market history from the provided chart
scrape_predictit_graphs <- function(id = NULL, span = "90d") {
  # define the URL of a single market
  market_url <- paste0("https://www.predictit.org/",
                       "Resource/DownloadMarketChartData",
                       "?marketid=", as.character(id),
                       "&timespan=", as.character(span))
  # download the chart data from said market
  market_chart <-
    read_csv(market_url,
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
  return(market_chart)
}

# initialize the a list to fill with history of each market
markets_list <- rep(list(NA), nrow(market_names))

# for every market grabed from API, load history into list element
for (i in 1:nrow(market_names)) {
  markets_list[[i]] <- scrape_predictit_graphs(id = market_names$mid[i])
}

# combine the list elements into a single tibble
market_data <- bind_rows(markets_list)
rm(markets_list, i)

# write_csv(x = market_names,
          # path = "./data/market_names.csv")
write_csv(x = market_data,
          path = "./data/market_data.csv")

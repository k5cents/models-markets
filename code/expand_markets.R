# head --------------------------------------------------------------------
# Kiernan Nicholls
# 2018-10-20
# Collect prediction market data
library(tidyverse)
library(httr)
library(jsonlite)

# api to tibble -----------------------------------------------------------
predictit_api <- function(api.url = "https://www.predictit.org/",
                          api.path = "api/marketdata/all/") {
  raw <- GET(url = api.url,
             path = api.path)
  as.char <- rawToChar(raw$content)
  as.list <- fromJSON(as.char)
  as.df <- do.call(what = "rbind",
                   args = lapply(as.list, as.data.frame))
  return(as.df)
}

markets.all <-
  predictit_api(api.url = "https://www.predictit.org/",
                api.path = "api/marketdata/all/") %>%
  as_tibble() %>%
  select(id, shortName)


# trim --------------------------------------------------------------------
# select all markets having to do with re-election or midterms
markets.all <- markets.all[c(grep("re-elect", markets.all$shortName),
                             grep("Which party will", markets.all$shortName)), ]

# remove the ones having to do with governor's races
markets.all <- markets.all[-grep("governor's", markets.all$shortName), ]

# function ----------------------------------------------------------------

# go to predictit.org and download chart data
predictit_scrape <- function(id = NULL, span = "90d") {
  # define the URL of a single market
  market.url <- paste0("https://www.predictit.org/",
                       "Resource/DownloadMarketChartData",
                       "?marketid=", as.character(id),
                       "&timespan=", as.character(span))
  # download the chart data from defined market
  market.chart <-
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
  return(market.chart)
}

# loop pull ---------------------------------------------------------------

# initialize the vector
markets.list <- rep(list(NA), nrow(markets.all))

# for every market grabed from API, load into list slot
for (i in 1:nrow(markets.all)) {
  markets.list[[i]] <- predictit_scrape(id = markets.all$id[i])
}

# combine the list elements
market.history <- bind_rows(markets.list)
# rm(markets.list)

# the contract name is long and irregular
# merge with both contract and market names
market.history <- as_tibble(merge(market.history, markets.all))
# rm(markets.all)

# Contract names contain party affliation for some house races
market.history$contract <- recode(market.history$contract,
                                  "Democratic/DFL" = "Democratic")
market.history$contract <-
  if_else(condition = market.history$contract == "Democratic",
          true  = "Democratic",
          false = if_else(
            condition = market.history$contract == "Republican",
            true  = "Republican",
            false = if_else(
              condition = word(market.history$contract, 3) == "be",
              true  = word(market.history$contract, 2),
              false = word(market.history$contract, 3))))

market.history <- arrange(market.history, date)

# extract candidate name or district from market name
market.history$name <-
  # there are two markets for Ryan and Pelosi with different names
  if_else(condition = word(market.history$shortName, 3) == "be",
          true = word(market.history$shortName, 2),
          false =
            # the incumbent questions use a name as 3rd word
            if_else(condition = word(market.history$shortName, 1) == "Will",
                    true = word(market.history$shortName, 3),
                    false =
                      # some house questions use a district code as 5th word
                      if_else(condition = word(market.history$shortName, 1) == "Which",
                              true = gsub("?", "", word(market.history$shortName, 5), fixed = T),
                              false = "FALSE")))

# reorder and rename
market.history <-
  market.history %>%
  select(date, id, name, contract, price, volume)

market.history$name <- if_else(condition = nchar(market.history$name) == 2,
                               true = paste(market.history$name, "00", sep = "-"),
                               false = market.history$name)

market.history <-
  market.history %>%
  mutate(code = if_else(condition = grepl("-", market.history$name)
                        & nchar(market.history$name) == 5,
                        true = market.history$name,
                        false = "NA")) %>%
  mutate(name = if_else(condition = grepl("-", market.history$name)
                        & nchar(market.history$name) == 5,
                        true = "NA",
                        false = market.history$name))

market.history$code[which(market.history$code == "NA")] <- NA
market.history$name[which(market.history$name == "NA")] <- NA

source('/media/removable/Card/predictr/code/congress_members.R')

test1 <- left_join(market.history, congress.members, by = "code")
test2 <- left_join(market.history, congress.members, by = "name")

# write_csv(market.history, "./data/market_history.csv")

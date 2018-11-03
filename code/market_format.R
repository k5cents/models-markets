# Kiernan Nicholls
# Fall 2018
# GOVT-696
# Combine and format market history
library(tidyverse)

# the contract name is long and irregular
# merge with both contract and market names
market.history <- as_tibble(merge(market.history, market.names))

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

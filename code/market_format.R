# Kiernan Nicholls
# Fall 2018
# GOVT-696
# Combine and format market history
library(tidyverse)

# read in the data from the market_scape.R file
# names of relevent markets, and history of said markets
market.names <- read_csv("./data/market_names.csv",
                         col_types = cols())
market.data <- read_csv("./data/market_data.csv",
                           col_types = cols())

# merge names and history -------------------------------------------------

# each markets has a unique ID
# for each market, there are 1 or more contracts ('shares' to buy)
# we must merge because the market names source
# has different info than the history source
# this different info will allow us to merge with model history
market.history <-
  left_join(market.data,
            market.names,
            by = c("mid", "cid")) %>%
  select(-starts_with("contract")) %>%
  # the `options` var from `names` will turn into party values
  # the `question` var will turn into district codes
  rename("party" = "option",
         "code" = "question")


# get district codes ------------------------------------------------------

# the `code` variable has a regular syntax for 4 types of market names
# 1. "Will Elizabeth Warren be re-elected"
# 2. "Which party will win PA-17?"
# 3. "Which party will win TN Senate race?"
# 4. "Will Pelosi be re-elected?" (No first name for Pelosi or Ryan)
# we want to extract the name, code, or state
market.history$code <-
  # get Pelosi or Ryan from 2nd word if 3rd word is "be"
  if_else(condition = word(market.history$code, 3) == "be",
          true = word(market.history$code, 2),
          false =
  # get the Last name from 3rd word if 1st word is "Will"
  if_else(condition = word(market.history$code, 1) == "Will",
          true = word(market.history$code, 3),
          false =
  # get the district code from 5th word if 1st word is "Which"
  if_else(condition = word(market.history$code, 1) == "Which",
          true = gsub("?", "", word(market.history$code, 5), fixed = T),
          false = "FALSE")))

# add "-00" to state names to create at-large district codes for senate races
market.history$code <- if_else(condition = nchar(market.history$code) == 2,
                  true = paste(market.history$code, "00", sep = "-"),
                  false = market.history$code)

# get party ---------------------------------------------------------------

# Tina Smith is running as the DFL part in the MN Senate special election
market.history$party <- recode(market.history$party, "Democratic/DFL" = "Democratic")

# I use D and R in the model and congress tibbles
# run thru the `party` var and either recode or extract the name
market.history$party <-
  if_else(condition = market.history$party == "Democratic",
          true  = "D",
          false =
  if_else(condition = market.history$party == "Republican",
          true  = "R",
          false =
  if_else(condition = word(market.history$party, 3) == "be",
          true  = word(market.history$party, 2),
          false = word(market.history$party, 3))))

# I accidentally grabbed a market about the Nigerian president's re-election
market.history <- market.history[-c(str_which(market.history$party,
                                              "Nigerian")), ]
market.history <- market.history[-c(str_which(market.history$party,
                                              "Farenthold")), ]


# fix the other values ----------------------------------------------------
# NOT DONE
# DOES NOT WORK :(


# this tibble is created in `code/congress_scrape.R`
congress.members <- read_csv("./data/congress_members.csv",
                             col_types = cols())

# replace names with their party codes from `congress.members`
#
# This puts D in every column
#
for (i in 1:nrow(market.history)) {
  market.history$party[i] <-
    # ignore D
    if_else(condition = market.history$party == "D",
            true = "D",
            false =
    # ignore R
    if_else(condition = market.history$party == "R",
            true = "R",
            # if it's a name, put that member's party as listed in `congress.members`
            false = congress.members$party[which(congress.members$last == market.history$party[i])][1]))
}

#
# This is closer
#
for (i in 1:nrow(market.history)) {
  market.history$code[i] <-
    if_else(condition = grepl(market.history$code[i], "-[0-9-]"),
            true = market.history$code[i],
            false = congress.members$code[which(congress.members$last == market.history$code[i])][1])
}


# Kiernan Nicholls
# Fall 2018
# GOVT-696
# Join model and market histories
library(tidyverse)

# read in the data from the market_scape.R file
# names of relevent markets, and data of said markets
market_names <- read_csv("./data/market_names.csv",
                         col_types = cols())
market_data <- read_csv("./data/market_data.csv",
                           col_types = cols())

# merge names and history -------------------------------------------------

# Each market has a unique ID (mid) and each buy option has a contact ID (cid).
# The market history tibble has insufficient information to join with model
# history. We can join the names and data, recode, then join with model history.
market_history <-
  left_join(market_data,
            market_names,
            by = c("mid", "cid")) %>%
  select(-starts_with("contract")) %>%
  # the `options` var from `names` will turn into party values
  # the `question` var will turn into district codes
  rename("party" = "option",
         "code" = "question")


# get district codes ------------------------------------------------------

# the `code` variable has a regular syntax for 4 types of market names:
#   1. "Will Elizabeth Warren be re-elected"
#   2. "Which party will win PA-17?"
#   3. "Which party will win TN Senate race?"
#   4. "Will Pelosi be re-elected?" (No first name for Pelosi or Ryan)

# we want to extract the name, code, or state
market_history$code <-
  # get Pelosi or Ryan from 2nd word if 3rd word is "be"
  # will get code from name in `congress_members`
  if_else(condition = str_detect(market_history$code, "re-elected"),
          true  = word(market_history$code, 3),
          false =

  # get the district code from 5th word if 6th word is "at-large"
  # make the district code into XX-01
  if_else(condition = str_detect(market_history$code, "at-large"),
          true  = paste(str_remove(word(market_history$code, 5), "\\?"),
                        "01",
                        sep = "-"),
          false =
  # get the district code from 5th word if 1st word is "Which"
  if_else(condition = str_detect(market_history$code, "special"),
          true  = paste(word(market_history$code, 5),
                        "98",
                        sep = "-"),
          false =
  if_else(condition = str_detect(market_history$code, "Senate"),
          true  = paste(word(market_history$code, 5),
                        "99",
                        sep = "-"),
          false =
  if_else(condition = str_detect(market_history$code, "re-elected"),
          true  = word(market_history$code, 3),
          false =
  if_else(condition = str_detect(market_history$code, "Which party"),
          true  = word(market_history$code, 5),
          false = "XXXX"
  ))))))

market_history$code[which(market_history$code == "be")] <- "Pelosi"

# get party ---------------------------------------------------------------

# Tina Smith is running as the DFL part in the MN Senate special election
market_history$party <-
  recode(market_history$party, "Democratic/DFL" = "Democratic")

# I use D and R in the model and congress tibbles
# run thru the `party` var and either recode or extract the name
market_history$party <-
  if_else(condition = market_history$party == "Democratic",
          true  = "D",
          false =
  if_else(condition = market_history$party == "Republican",
          true  = "R",
          false =
  if_else(condition = word(market_history$party, 3) == "be",
          true  = word(market_history$party, 2),
          false = word(market_history$party, 3))))

# fix the other values ----------------------------------------------------

# this tibble is created in `code/congress_scrape.R`
congress_members <- read_csv("./data/congress_members.csv",
                             col_types = cols())

# recode the names into party codes
for (i in 1:nrow(market_history)) {
  market_history$party[i] <-
    # ignore D
    if_else(condition = market_history$party[i] == "D",
            true = "D",
            false =
    # ignore R
    if_else(condition = market_history$party[i] == "R",
            true = "R",
    # if it's a name, put that member's party as listed in `congress_members`
            false = congress_members$party[which(congress_members$last ==
                                                 market_history$party[i])][1]))
}

# keep codes, recode the names into codes
for (i in 1:nrow(market_history)) {
  market_history$code[i] <-
    if_else(condition = str_detect(market_history$code[i], "-[0-9-]"),
            true = market_history$code[i],
            false = congress_members$code[which(congress_members$last ==
                                                market_history$code[i])][1])
}

# this question asking if Ryan will be re-elected is redundant.
market_history <- market_history[-which(market_history$mid == "3455"), ]

# these markets are for special elections and need different district codes
market_history$code[str_which(market_history$mid, "3949")] <- "MN-98"
market_history$code[str_which(market_history$mid, "4192")] <- "MS-98"

# turn the numeric market and contract IDs into characters
market_history$mid <- as.character(market_history$mid)
market_history$cid <- as.character(market_history$cid)

market_history$code <- str_remove(market_history$code, "\\?")

write_csv(market_history, "./data/market_history.csv")

# join markets and models -------------------------------------------------

joined <-
  right_join(x  = read_csv("./data/model_history.csv"),
             y  = market_history,
             by = c("date", "code", "party")) %>%
  select(-last) %>%
  mutate(mid = as.character(mid),
         cid = as.character(cid)) %>%
  arrange(date)

write_csv(joined, "./data/joined.csv")

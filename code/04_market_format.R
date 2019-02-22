# Kiernan Nicholls
# Format market data from PredictIt

# Reorder and recode market data input
market <-
  market_data %>%
  rename(mid      = MarketId,
         symbol   = MarketSymbol,
         party    = ContractName,
         open     = OpenPrice,
         close    = ClosePrice,
         high     = HighPrice,
         low      = LowPrice,
         vol      = Volume,
         date     = Date) %>%
  mutate(party = recode(party,
                        "Democratic"        = "D",
                        "Democratic or DFL" = "D",
                        "Republican"        = "R")) %>%
  select(date, everything(), -ContractSymbol, -MarketName)

# Remove year information from symbol strings
market$symbol <- str_remove(market$symbol, ".2018")
market$symbol <- str_remove(market$symbol, ".18")

# Divide the market symbol into the name and race code
market <- separate(market,
                   col = symbol,
                   into = c("name", "race"),
                   sep = "\\.",
                   remove = TRUE,
                   extra = "drop",
                   fill = "left")

market$race <- str_replace(market$race, "SENATE", "99")
market$race <- str_replace(market$race, "SEN",    "99")
market$race <- str_replace(market$race, "SE",     "99")
market$race <- str_replace(market$race, "AL",     "01")   # at large
market$race <- str_replace(market$race, "OH12G",  "OH12") # not sure
market$race[which(market$name == "SPEC")] <- "MS98"       # special election
market$race[which(market$race == "MN99")] <- "MN98"       # special election
market$race <- paste(str_sub(market$race, 1, 2),          # insert hyphen
                     str_sub(market$race, 3, 4),
                     sep = "-")

# Remove markets without relevant information
market$name[which(market$name == "PARTY")] <- NA   # no name
market$name[which(market$name == "SPEC")] <- NA    # no name
market <- market[-str_which(market$mid, "3455"), ] # paul ryan not needed
market <- market[-str_which(market$mid, "3507"), ] # jeff flake not needed

for (i in 1:nrow(market)) {
  if (is.na(market$party[i])) {
    market$party[i] <-
      members$party[str_sub(tolower(members$name), 1, 4)
                       == str_sub(tolower(market$name), 1, 4)[i]][1]

    }
}

market$race[market$mid == "3857"] <- "CA-99" # PredictIt miscoded as AZ-99

market <- market %>% select(-name)

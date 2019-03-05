# Kiernan Nicholls
# Format market data from PredictIt

# Rename market data input
markets <-
  markets_data %>%
  rename(mid      = MarketId,
         symbol   = MarketSymbol,
         party    = ContractName,
         open     = OpenPrice,
         close    = ClosePrice,
         high     = HighPrice,
         low      = LowPrice,
         vol      = Volume,
         date     = Date) %>%
  select(date, everything()) %>%
  select(-ContractSymbol, -MarketName)

# Recode party variables
markets$party <-  recode(markets$party,
                         "Democratic"        = "D",
                         "Democratic or DFL" = "D",
                         "Republican"        = "R")

# Remove year information from symbol strings
markets$symbol <- str_remove(markets$symbol, ".2018")
markets$symbol <- str_remove(markets$symbol, ".18")

# Divide the market symbol into the name and race code
markets <- markets %>% separate(col = symbol,
                                into = c("name", "race"),
                                sep = "\\.",
                                remove = TRUE,
                                extra = "drop",
                                fill = "left")

markets$race <- str_replace(markets$race, "SENATE", "99")
markets$race <- str_replace(markets$race, "SEN",    "99")
markets$race <- str_replace(markets$race, "SE",     "99")
markets$race <- str_replace(markets$race, "AL",     "01")   # at large
markets$race <- str_replace(markets$race, "OH12G",  "OH12") # not sure
markets$race[markets$name == "SPEC"] <- "MS98"              # special election
markets$race[markets$mid == "3857"]         <- "CA-99"      # miscoded?
markets$race[markets$race == "MN99"] <- "MN98"              # special election
markets$race <- paste(str_sub(markets$race, 1, 2),          # state abb
                      str_sub(markets$race, 3, 4),          # market number
                      sep = "-")

# Remove markets without relevant information
markets$name[markets$name == "PARTY"] <- NA    # no name
markets$name[markets$name == "SPEC"] <- NA     # no name
markets <- markets[-str_which(markets$mid, "3455"), ] # paul ryan not needed
markets <- markets[-str_which(markets$mid, "3507"), ] # jeff flake not needed

# Look into list of members and take party from candidates with a matching name
first4 <- function(v) str_sub(tolower(v), 1, 4)
for (i in 1:nrow(markets)) {
  if (is.na(markets$party[i])) {
    markets$party[i] <- members$party[first4(members$name) == first4(markets$name)[i]][1]
    }
}

markets <- markets %>% select(-name)

library(tidyverse)
library(magrittr)
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
  filter(date >= "2018-08-01") %>%
  mutate(party = recode(party,
                         "Democratic" = "D",
                         "Republican" = "R",
                         "Democratic or DFL" = "D")) %>%
  select(date, everything(), -ContractSymbol, -MarketName)

market$symbol <- str_remove(market$symbol, ".2018")
market$symbol <- str_remove(market$symbol, ".18")

market <- separate(market,
                   col = symbol,
                   into = c("name", "code"),
                   sep = "\\.",
                   remove = TRUE,
                   extra = "drop",
                   fill = "left")

market$code <- str_replace(market$code, "SENATE", "99")
market$code <- str_replace(market$code, "SEN",    "99")
market$code <- str_replace(market$code, "SE",     "99")
market$code <- str_replace(market$code, "AL",     "01") # at large
market$code <- str_replace(market$code, "OH12G",  "OH12") # not sure
market$code[which(market$name == "SPEC")] <- "MS98" # special election
market$code[which(market$code == "MN99")] <- "MN98" # special election
market$code <- paste(str_sub(market$code, 1, 2),
                     str_sub(market$code, 3, 4),
                     sep = "-")

market$name[which(market$name == "PARTY")] <- NA # no name
market$name[which(market$name == "SPEC")] <- NA # no name
market <- market[-str_which(market$mid, "3455"), ] # paul ryan not needed

for (i in 1:nrow(m)) {
  if (is.na(market$party[i])) {
    market$party[i] <- members$party[which(str_sub(tolower(members$name), 1, 4) ==
                                   str_sub(tolower(market$name), 1, 4)[i])][1]
  }
}

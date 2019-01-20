library(tidyverse)
library(magrittr)
m <-
  read_csv(file = "./data/market_file.csv",
           na = c("n/a", "NA"),
           col_types = cols(MarketId = col_character(),
                            ContractName = col_character(),
                            ContractSymbol = col_character())) %>%
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

m$symbol <- str_remove(m$symbol, ".2018")
m$symbol <- str_remove(m$symbol, ".18")

m <- separate(m,
              col = symbol,
              into = c("name", "code"),
              sep = "\\.",
              remove = TRUE,
              extra = "drop",
              fill = "left")

m$code <- str_replace(m$code, "SENATE", "99")
m$code <- str_replace(m$code, "SEN",    "99")
m$code <- str_replace(m$code, "SE",     "99")
m$code <- str_replace(m$code, "AL",     "01") # at large
m$code <- str_replace(m$code, "OH12G",  "OH12") # not sure
m$code[which(m$name == "SPEC")] <- "MS98" # special election
m$code[which(m$code == "MN99")] <- "MN98" # special election
m$code <- paste(str_sub(m$code, 1, 2), str_sub(m$code, 3, 4), sep = "-")
m$name[which(m$name == "PARTY")] <- NA # no name
m$name[which(m$name == "SPEC")] <- NA # no name
m <- m[-str_which(m$mid, "3455"), ] # paul ryan not needed

c <- read_csv("./data/congress_members.csv", col_types = cols())

for (i in 1:nrow(m)) {
  if (is.na(m$party[i])) {
    m$party[i] <- c$party[which(str_sub(tolower(c$last), 1, 4) ==
                                   str_sub(tolower(m$name), 1, 4)[i])][1]
  }
}

for (i in 1:nrow(m)) {
  if (!is.na(m$party[i])) {
    m$name[i] <- c$last[which(str_sub(tolower(c$last), 1, 4) ==
                                str_sub(tolower(m$name), 1, 4)[i])][1]
  }
}

m %<>% mutate(party = recode(party, "I" = "D"))

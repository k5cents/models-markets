library(tidyverse)
m <-
  read_csv(file = "./data/market_file.csv",
           na = c("n/a", "NA"),
           col_types = cols(MarketId = col_character(),
                            ContractName = col_character(),
                            ContractSymbol = col_character())) %>%
  rename(mid   = MarketId,
         symbol   = MarketSymbol,
         option   = ContractName,
         contract   = ContractSymbol,
         open  = OpenPrice,
         close = ClosePrice,
         high  = HighPrice,
         low   = LowPrice,
         vol   = Volume,
         date  = Date) %>%
  mutate(option = recode(option, "Democratic or DFL" = "Democratic")) %>%
  select(date, everything(), -MarketName)
m$symbol <- str_remove(m$symbol, ".2018")
m <- separate(m,
         col = symbol,
         into = c("canidate", "race"),
         sep = "\\.",
         remove = TRUE,
         fill = "right")
unique(m$symbol)

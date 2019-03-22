markets <- DailyMarketData_formatted %>%
  rename(mid      = MarketId,
         name     = MarketName,
         symbol   = MarketSymbol,
         party    = ContractName,
         open     = OpenPrice,
         close    = ClosePrice,
         high     = HighPrice,
         low      = LowPrice,
         vol      = Volume,
         date     = Date) %>%
  select(date, everything()) %>%
  select(-ContractSymbol)

# Get candidate names from full market question
markets$name[str_which(markets$name, "Which party will")] <- NA
markets$name %<>% word(start = 2, end = 3)

# Recode party variables
markets$party %<>% recode("Democratic or DFL" = "D",
                          "Democratic"        = "D",
                          "Republican"        = "R")

# Remove year information from symbol strings
markets$symbol %<>% str_remove(".2018")
markets$symbol %<>% str_remove(".18")

# Divide the market symbol into the name and race code
markets %<>%
  separate(col = symbol,
           into = c("symbol", "race"),
           sep = "\\.",
           extra = "drop",
           fill = "left") %>%
  select(-symbol)

# Recode the original contract strings for race variables
markets$race %<>% str_replace("SENATE", "S1")
markets$race %<>% str_replace("SEN",    "S1")
markets$race %<>% str_replace("SE",     "S1")
markets$race %<>% str_replace("AL",     "01")   # at large
markets$race %<>% str_replace("OH12G",  "OH12") # not sure
markets$race %<>% str_replace("MN99",   "MNS2") # special election
markets$race[markets$name == "SPEC"] <- "MSS2"  # special election
markets$race[markets$mid  == "3857"] <- "CAS1"  # market name mustyped
markets$name[markets$name == "PARTY"] <- NA     # no name
markets$name[markets$name == "SPEC"]  <- NA     # no name

markets$race <- paste(str_sub(markets$race, 1, 2), # state abbreviation
                      sep = "-",                   # put hyphen in middle
                      str_sub(markets$race, 3, 4)) # market number)

# Remove markets incorrectly included
markets %<>% filter(mid != "3455", # Paul Ryan
                    mid != "3507", # Jeff Flake
                    mid != "3539") # Shea-Porter

# Divide the data based on market question syntax
# Some market questions provided name, others party
no_party <- markets %>%
  filter(is.na(party)) %>%
  select(-party)

# Take the members list, get the party, add back with those with party
markets <- members %>%
  select(name, party) %>%
  right_join(no_party, by = "name") %>%
  select(date, mid, everything()) %>%
  bind_rows(markets %>% filter(!is.na(party)))

# Fix some incorrect party values resulting from name confusion
markets$party[markets$race == "CO-05"] <- "R" # Lamborn (R) not Lamb (D)
markets$party[markets$race == "MN-02"] <- "R" # Lewis (R) not Lewis (D)
markets$party[markets$race == "WI-S1"] <- "D" # Balderson (R) Baldwin (D)

# Add in ME-02 and NY-27 which were left out of initial data
ny_27 <-
  read_csv(file = "./input/Contract_NY27_formatted.csv",
           col_types = cols(ContractID = col_character())) %>%
  mutate(mid = "4729",
         race = "NY-27",
         party = "R") %>%
  select(-Average)

me_02 <-
  read_csv(file = "./input/Market_ME02_formatted.csv",
           col_types = cols(ContractID = col_character())) %>%
  mutate(mid = "4945",
         race = "ME-02") %>%
  rename(party = LongName) %>%
 filter(Date != "2018-10-10")

markets_extra <-
  bind_rows(ny_27, me_02) %>%
  rename(vol = Volume) %>%
  select(Date, mid, race, party, Open, Low, High, Close, vol)

names(markets_extra) <- tolower(names(markets_extra))
markets_extra$party[str_which(markets_extra$party, "GOP")] <- "R"
markets_extra$party[str_which(markets_extra$party, "Dem")] <- "D"

# Bind with ME-02 and NY-27
markets %<>%
  select(-name) %>%
  bind_rows(markets_extra)

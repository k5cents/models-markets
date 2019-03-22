### Kiernan Nicholls
### American University
### Spring, 2019
### Predictr: markets vs models
### Format input data for joins and comparisons

library(tidyverse)
library(magrittr)
library(lubridate)

# format member list ------------------------------------------------------

## SOURCE:    https://theunitedstates.io/
## INPUT:     input/legislators_current.csv
## DESC:      members of the 115th Congress w/ bio and pol info
## USE:       suppliment prediction history and contextualize election results

members <- legislators_current %>%
  unite(first_name, last_name,
        col = name,
        sep = " ") %>%
  rename(chamber = type,
         gid     = govtrack_id) %>%
  select(name,
         gid,
         birthday,
         state,
         district,
         senate_class,
         party,
         gender,
         chamber) %>%
  arrange(chamber)

# Recode, Encode, and Pad
members$name %<>% iconv(to = "ASCII//TRANSLIT")
members$name %<>% str_replace_all("Robert Menendez", "Bob Menendez")
members$name %<>% str_replace_all("Robert Casey",    "Bob Casey")
members$name %<>% str_replace_all("Bernard Sanders", "Bernie Sanders")
members$chamber %<>% recode("rep" = "house", "sen" = "senate")
members$district %<>%  str_pad(width = 2, pad = "0")
members$senate_class %<>% str_pad(width = 2, pad = "S")
members$party %<>% recode("Democrat"    = "D",
                          "Independent" = "D",
                          "Republican"  = "R")

members$district <- if_else(condition = is.na(members$district),
                            true = members$senate_class,
                            false = members$district)

# Create district code as relational key
members <- members %<>%
  unite(col = race,
        state, district,
        sep = "-",
        remove = TRUE) %>%
  select(-senate_class) %>%
  arrange(name)

# Format member stats for join
members_stats <-
  bind_rows(sponsorshipanalysis_h, sponsorshipanalysis_s,
            .id = "chamber") %>%
  select(ID, chamber, party, ideology, leadership) %>%
  rename(gid = ID)
members_stats$chamber %<>% recode("1" = "house", "2" = "senate")
members_stats$party %<>% recode("Democrat" = "D", "Republican" = "R")
members_stats$gid %<>% as.character()

# Add stats to frame by GovTrack ID
members %<>% left_join(members_stats, by = c("gid", "party", "chamber"))

# format markets history ------------------------------------------------------

## SOURCE:    https://predictit.org/
## INPUT:     input/DailyMarketData.csv
## DESC:      history of contract prices for midterm election markets
## USE:       operationalize probabalistic forecasts from prediction markets

markets <- DailyMarketData %>%
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
# Market questions provided name or party, never both
markets_with_name <- markets %>%
  filter(is.na(party)) %>%
  select(-party)

markets_with_party <- markets %>%
  filter(is.na(name)) %>%
  select(-name)

# Join with members key to add party, then back with rest of market
markets <- markets_with_name %>%
  left_join(members, by = c("name", "race")) %>%
  select(date, mid, race, party, open, low, high, close, vol) %>%
  bind_rows(markets_with_party)

# Add in ME-02 and NY-27 which were left out of initial data
ny_27 <- Contract_NY27 %>%
  slice(6:154) %>%
  mutate(mid = "4729",
         race = "NY-27",
         party = "R") %>%
  select(-Average)

me_02 <- Market_ME02 %>%
  slice(2:176) %>%
  mutate(mid = "4945",
         race = "ME-02") %>%
  rename(party = LongName)

markets_extra <-
  bind_rows(ny_27, me_02) %>%
  rename(vol = Volume) %>%
  select(Date, mid, race, party, Open, Low, High, Close, vol)

names(markets_extra) <- tolower(names(markets_extra))
markets_extra$party[str_which(markets_extra$party, "GOP")] <- "R"
markets_extra$party[str_which(markets_extra$party, "Dem")] <- "D"

# Bind with ME-02 and NY-27
markets %<>%  bind_rows(markets_extra)

# format polling data -----------------------------------------------------

## SOURCE:    https://fivethirtyeight.com/
## INPUT:     input/*_polls.csv
## DESC:      history of individual public opinion poll results
## USE:       quantify changes in the primary input to the forecasting model

# Create a key for pollster and sponsor IDs
polling_key <-
  bind_rows(house_polls, senate_polls) %>%
  select(display_name,
         pollster_id, pollster,
         sponsor_ids, sponsors) %>%
  distinct()

polling_key$pollster_id %<>% as.character()
polling_key$sponsor_ids %<>% as.character()

# Formated for relational joins and key info
polling <-
  bind_rows(house_polls, senate_polls) %>%
  select(start_date,
         end_date,
         poll_id,
         pollster_id,
         sponsor_ids,
         sample_size,
         population,
         methodology,
         office_type,
         state,
         seat_number,
         internal,
         partisan,
         tracking,
         answer,
         candidate_party,
         pct) %>%
  rename(name = answer,
         party = candidate_party,
         support = pct,
         poll = poll_id,
         pollster = pollster_id,
         sponsor = sponsor_ids,
         n = sample_size,
         pop = population,
         method = methodology,
         chamber = office_type,
         district = seat_number) %>%
  filter(party == "DEM" | party == "REP" | party == "IND") %>%
  arrange(start_date)

polling$chamber %<>% str_extract("\\w*$") %>% tolower()

polling$party %<>% recode("DEM" = "D",
                          "REP" = "R",
                          "IND" = "I")

polling$support <- polling$support * 0.01

polling$district[polling$chamber == "house"]  %<>% str_pad(width = 2, pad = "0")

polling$district[polling$chamber == "senate"] %<>%
  str_pad(width = 2, pad = "S") %>%
  recode("S0" = "S1")

# Replace state names with state abbreviations for race code
polling <- polling %>%
  left_join(y = tibble(state = state.name, abb = state.abb),
            by = "state") %>%
  select(-state) %>%
  rename(state = abb) %>%
  unite(state, district,
        col = race,
        sep = "-",
        remove = TRUE) %>%
  mutate(length = end_date - start_date) %>%
  select(start_date,
         length,
         race,
         name,
         party,
         chamber,
         support,
         everything())

# format model history ----------------------------------------------------

## SOURCE:    https://fivethirtyeight.com/
## INPUT:     input/*_forecast.csv
## DESC:      history of forecasting model top line probabilities
## USE:       operationalize probabalistic forecasts from a forcasting model

# Format district for race variable
model_district <- house_district_forecast %>%
  mutate(district = str_pad(string = district,
                            width = 2,
                            side = "left",
                            pad = "0"))

# Format class for race variable
model_seat <- senate_seat_forecast %>%
  rename(district = class) %>%
  mutate(district = str_pad(string = district,
                            width = 2,
                            side = "left",
                            pad = "S"))

model_combined <-
  bind_rows(model_district, model_seat, .id = "chamber") %>%
  # Create race variable for relational join
  unite(col = race,
        state, district,
        sep = "-",
        remove = TRUE) %>%
  rename(name = candidate,
         date = forecastdate,
         prob = win_probability,
         min_share = p10_voteshare,
         max_share = p90_voteshare) %>%
  filter(name != "Others") %>%
  select(date, race, name, party, chamber, everything()) %>%
  arrange(date, name)

# Recode identifying variable for clarification
model_combined$chamber %<>% recode("1" = "house",
                                   "2" = "senate")

# Only special elections are for senate.
model_combined$special[is.na(model_combined$special)] <- FALSE

# Convert percent vote share values to decimal
model_combined[, 10:12] <- model_combined[, 10:12] * 0.01

# Recode incumbent Independent senators for relational joins with Markets
# Both caucus with Democrats and were endoresed by Democratic party
model_combined$party[model_combined$name == "Bernard Sanders"] <- "D"
model_combined$party[model_combined$name == "Angus King"]      <- "D"

# Seperate model data by model format
# According to 538, the "classic" model can be used as a default
model <- filter(model_combined, model == "classic") %>% select(-model)
model_lite <- filter(model_combined, model == "lite") %>% select(-model)
model_deluxe <- filter(model_combined, model == "deluxe") %>% select(-model)

# format election results -------------------------------------------------

## SOURCE:    https://fivethirtyeight.com/
## INPUT:     input/forecast_results_2018.csv
## DESC:      final predictions and election results
## USE:       assess the accuracy of both predictive methods

results <- forecast_results_2018 %>%
  filter(branch  != "Governor",
         version == "classic") %>%
  separate(col    = race,
           into   = c("state", "district"),
           sep    = "-") %>%
  rename(winner   = Democrat_Won) %>%
  mutate(winner   = if_else(uncalled, true  = NA, false = winner),
         district = str_pad(district, width = 2,  pad   = "0")) %>%
  unite(col = race,
        state, district,
        sep = "-") %>%
  select(race, winner, category)


# format partisan lean index ----------------------------------------------

## SOURCE:    https://fivethirtyeight.com/
## INPUT:     input/partisan_lean_*.csv
## DESC:      relative partisanship of state or district vs national average
## USE:       assess race predictions for partisan bias

# Separate lean value and replace state name with state abbreviation
lean_states <- partisan_lean_STATES %>%
  separate(col = pvi_538,
           into = c("party", "lean"),
           sep = "\\+",
           convert = TRUE) %>%
  rename(race = state) %>%
  mutate(race = paste(state.abb, "S1", sep = "-"))

# Seperate lean value and pad district number for race code
lean_district <- partisan_lean_DISTRICTS %>%
  separate(col = pvi_538,
           into = c("party", "lean"),
           sep = "\\+",
           convert = TRUE) %>%
  separate(col = district,
           into = c("state", "race"),
           sep = "\\-") %>%
  mutate(race = str_pad(race, width = 2, pad = "0")) %>%
  unite(col = race,
        state, race,
        sep = "-")

# Turn single number into negative-positive spectrum
race_lean <-
  bind_rows(lean_states, lean_district) %>%
  mutate(lean = if_else(condition = party == "D",
                        true  = lean * -1,
                        false = lean))


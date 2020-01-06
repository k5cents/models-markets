### Kiernan Nicholls
### American University
### Spring, 2020
### Markets and Models
### Format input data for joins and comparisons

library(tidyverse)
library(magrittr)
library(lubridate)

# format member list ------------------------------------------------------

## source:    https://theunitedstates.io/
## input:     data/raw/members/legislators_current.csv
## desc:      members of the 115th Congress w/ bio and pol info
## use:       suppliment prediction history and contextualize election results

members <- legislators_current %>%
  unite(
    first_name, last_name,
    col = name,
    sep = " "
  ) %>%
  rename(
    gid     = govtrack_id,
    chamber = type,
    class   = senate_class,
    birth   = birthday
  ) %>%
  select(
    name,
    gid,
    birth,
    state,
    district,
    class,
    party,
    gender,
    chamber
  ) %>%
  arrange(chamber)

# recode, encode, and pad
members <- members %>%
  mutate(
    name = name %>%
      iconv(to = "ASCII//TRANSLIT") %>%
      str_replace_all("Robert Menendez", "Bob Menendez") %>%
      str_replace_all("Robert Casey",    "Bob Casey") %>%
      str_replace_all("Bernard Sanders", "Bernie Sanders"),
    chamber = recode(chamber, "rep" = "house", "sen" = "senate"),
    district = str_pad(district, width = 2, pad = "0"),
    class = str_pad(class, width = 2, pad = "S"),
    party = party %>% recode(
      "Democrat" = "D",
      "Independent" = "D",
      "Republican" = "R"
    ),
    district = if_else(
      condition = is.na(district),
      true = class,
      false = district
    )
  ) %>%
  # create district code as relational key
  unite(
    col = race,
    state, district,
    sep = "-",
    remove = TRUE
  ) %>%
  select(-class) %>%
  arrange(name)

# format member stats for join
members_stats <-
  bind_rows(
    sponsorshipanalysis_h,
    sponsorshipanalysis_s,
    .id = "chamber"
  ) %>%
  select(
    ID,
    chamber,
    party,
    ideology,
    leadership
  ) %>%
  rename(gid = ID) %>%
  mutate(
    gid = as.character(gid),
    chamber = recode(chamber, "1" = "house", "2" = "senate"),
    party = party %>% recode(
      "Democrat" = "D",
      "Independent" = "D",
      "Republican" = "R"
    )
  )

# add stats to frame by GovTrack ID
members <- inner_join(
  x = members,
  y = members_stats,
  by = c("gid", "party", "chamber")
)

# format markets history ------------------------------------------------------

## source:    https://predictit.org/
## input:     data/raw/models/DailyMarketData.csv
## desc:      history of contract prices for midterm election markets
## use:       operationalize probabalistic forecasts from prediction markets

markets <- DailyMarketData %>%
  rename(
    mid    = MarketId,
    name   = MarketName,
    symbol = MarketSymbol,
    party  = ContractName,
    open   = OpenPrice,
    close  = ClosePrice,
    high   = HighPrice,
    low    = LowPrice,
    volume = Volume,
    date   = Date
  ) %>%
  select(date, everything()) %>%
  select(-ContractSymbol)

# Get candidate names from full market question
markets$name[str_which(markets$name, "Which party will")] <- NA
markets$name <- word(markets$name, start = 2, end = 3)

# Recode party variables
markets$party <- markets$party %>%
  recode(
    "Democratic or DFL" = "D",
    "Democratic" = "D",
    "Republican" = "R"
  )

# Remove year information from symbol strings
markets <- markets %>%
  mutate(
    race = symbol %>%
      str_remove("\\.\\d{2,4}$") %>% # year
      str_remove("(.*)\\.") %>% # names
      str_replace("(?<=[:upper:])SE(.*)$", "S1") %>% # senate
      str_replace("AL", "01") %>% # at large
      str_remove("((?<=\\d))G") %>% # general?
      str_replace("99$", "S2"), # special election
    race = case_when(
      name == "SPEC" ~ "MSS2",
      mid == "3857" ~ "CAS1",
      TRUE ~ race
    ),
    name = case_when(
      name == "PARTY" ~ NA_character_,
      name == "SPEC" ~ NA_character_,
      TRUE ~ name
    ),
    race = race %>%
      str_replace(
        pattern = "([:alpha:]{2})(S\\d|\\d{2})",
        replacement = "\\1-\\2"
      )
  ) %>%
  # Remove markets incorectly repeated
  # Some not running for re-election
  filter(
    mid != "3455", # Paul Ryan
    mid != "3507", # Jeff Flake
    mid != "3539", # Shea-Porter
    mid != "3521", # Darrell Issa
    mid != "3522", # Repeat of 4825
    mid != "4177", # Repeat of 4232
    mid != "4824"  # Repeat of 4776
  )

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
  inner_join(members, by = c("name", "race")) %>%
  select(date, mid, race, party, open, low, high, close, volume) %>%
  bind_rows(markets_with_party)

# Add in ME-02 and NY-27 which were left out of initial data
ny_27 <- Contract_NY27 %>%
  rename_all(tolower) %>%
  slice(6:154) %>%
  mutate(mid = "4729",
         race = "NY-27",
         party = "R") %>%
  select(-average)

me_02 <- Market_ME02 %>%
  rename_all(tolower) %>%
  rename(party = longname) %>%
  filter(date != "2018-10-10") %>%
  mutate(mid = "4945",
         race = "ME-02")

markets_extra <-
  bind_rows(ny_27, me_02) %>%
  select(date, mid, race, party, open, low, high, close, volume)

markets_extra$party[str_which(markets_extra$party, "GOP")] <- "R"
markets_extra$party[str_which(markets_extra$party, "Dem")] <- "D"

# Bind with ME-02 and NY-27
markets %<>% bind_rows(markets_extra)

# format model history ----------------------------------------------------

## source:    https://fivethirtyeight.com/
## input:     input/*_forecast.csv
## desc:      history of forecasting model top line probabilities
## use:       operationalize probabalistic forecasts from a forcasting model

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
model_combined$party[model_combined$name == "Bernard Sanders"]   <- "D"
model_combined$party[model_combined$name == "Angus S. King Jr."] <- "D"
model_combined %<>% filter(name != "Zak Ringelstein")

# Seperate model data by model format
# According to 538, the "classic" model can be used as a default
model <- filter(model_combined, model == "classic") %>% select(-model)
model_lite <- filter(model_combined, model == "lite") %>% select(-model)
model_deluxe <- filter(model_combined, model == "deluxe") %>% select(-model)

# format election results -------------------------------------------------

## source:    https://fivethirtyeight.com/
## input:     input/forecast_results_2018.csv
## desc:      final predictions and election results
## use:       assess the accuracy of both predictive methods

results <- forecast_results_2018 %>%
  filter(branch  != "Governor",
         version == "classic") %>%
  separate(col    = race,
           into   = c("state", "district"),
           sep    = "-") %>%
  rename(winner   = Democrat_Won) %>%
  mutate(district = str_pad(district, width = 2,  pad   = "0")) %>%
  unite(state, district,
        col = race,
        sep = "-") %>%
  select(race, winner) %>%
  filter(race != "NC-09") # Harris fraud charges

# format partisan lean index ----------------------------------------------

## source:    https://fivethirtyeight.com/
## input:     input/partisan_lean_*.csv
## desc:      relative partisanship of state or district vs national average
## use:       assess race predictions for partisan bias

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


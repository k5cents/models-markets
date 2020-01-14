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

# save text file
new_dir <- dir_create(here::here("data", "new"))
write_csv(
  x = members,
  path = "data/new/members.csv",
  na = ""
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

# get candidate names from full market question
markets$name[str_which(markets$name, "Which party will")] <- NA
markets$name <- word(markets$name, start = 2, end = 3)

# recode party variables
markets$party <- markets$party %>%
  recode(
    "Democratic or DFL" = "D",
    "Democratic" = "D",
    "Republican" = "R"
  )

# remove year information from symbol strings
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
  select(-symbol) %>%
  # remove markets incorectly repeated
  # some not running for re-election
  filter(
    mid != "3455", # Paul Ryan
    mid != "3507", # Jeff Flake
    mid != "3539", # Shea-Porter
    mid != "3521", # Darrell Issa
    mid != "3522", # Repeat of 4825
    mid != "4177", # Repeat of 4232
    mid != "4824"  # Repeat of 4776
  )

# divide the data based on market question syntax
# market questions provided name or party, never both
markets_with_name <- markets %>%
  filter(is.na(party)) %>%
  select(-party)

markets_with_party <- markets %>%
  filter(is.na(name)) %>%
  select(-name)

# join with members key to add party, then back with rest of market
markets <- markets_with_name %>%
  inner_join(members, by = c("name", "race")) %>%
  select(date, mid, race, party, open, low, high, close, volume) %>%
  bind_rows(markets_with_party)

# add in ME-02 and NY-27 which were left out of initial data
ny_27 <- Contract_NY27 %>%
  rename_all(str_to_lower) %>%
  slice(6:154) %>%
  mutate(
    mid = "4729",
    race = "NY-27",
    party = "R"
  ) %>%
  select(-average)

me_02 <- Market_ME02 %>%
  rename_all(str_to_lower) %>%
  rename(party = longname) %>%
  filter(date != "2018-10-10") %>%
  mutate(mid = "4945", race = "ME-02")

markets_extra <-
  bind_rows(ny_27, me_02) %>%
  select(date, mid, race, party, open, low, high, close, volume)

markets_extra$party[str_which(markets_extra$party, "GOP")] <- "R"
markets_extra$party[str_which(markets_extra$party, "Dem")] <- "D"

# bind with ME-02 and NY-27
markets <- bind_rows(markets, markets_extra)

# save text file
write_csv(
  x = markets,
  path = "data/new/markets.csv",
  na = ""
)

# format polling data -----------------------------------------------------

## source:    https://fivethirtyeight.com/
## input:     input/*_polls.csv
## desc:      history of individual public opinion poll results
## use:       quantify changes in the primary input to the forecasting model

# Create a key for pollster and sponsor IDs
polling_key <-
  bind_rows(
    house_polls,
    senate_polls
  ) %>%
  select(
    display_name,
    pollster_id,
    pollster,
    sponsor_ids,
    sponsors
  ) %>%
  distinct()

# Formated for relational joins and key info
polling <-
  bind_rows(
    house_polls,
    senate_polls
  ) %>%
  select(
    start_date,
    end_date,
    poll = poll_id,
    pollster = pollster_id,
    sponsor = sponsor_ids,
    n = sample_size,
    pop = population,
    method = methodology,
    chamber = office_type,
    state,
    district = seat_number,
    internal,
    partisan,
    tracking,
    name = answer,
    party = candidate_party,
    support = pct
  ) %>%
  filter(party %in% c("DEM", "REP", "IND")) %>%
  arrange(start_date) %>%
  mutate(
    chamber = chamber %>%
      str_extract("\\w+$") %>%
      str_to_lower(),
    party = party %>%
      recode(
        "DEM" = "D",
        "REP" = "R",
        "IND" = "I"
      ),
    support = support * 0.01,
    district = case_when(
      chamber == "house" ~ str_pad(district, 2, pad = "0"),
      chamber == "senate" ~ str_pad(district, 2, pad = "S") %>%
        recode("S0" = "S1")
    )
  ) %>%
  # replace state names with state abbreviations
  inner_join(
    y = tibble(state = state.name, abb = state.abb),
    by = "state"
  ) %>%
  select(-state) %>%
  rename(state = abb) %>%
  unite(
    state, district,
    col = race,
    sep = "-",
    remove = TRUE
  ) %>%
  mutate(length = end_date - start_date) %>%
  select(
    start_date,
    length,
    race,
    name,
    party,
    chamber,
    support,
    everything()
  )

# save text file
write_csv(
  x = polling,
  path = "data/new/polling.csv",
  na = ""
)

# format model history ----------------------------------------------------

## source:    https://fivethirtyeight.com/
## input:     input/*_forecast.csv
## desc:      history of forecasting model top line probabilities
## use:       operationalize probabalistic forecasts from a forcasting model

# format district for race variable
model_district <- house_district_forecast %>%
  mutate(
    district = str_pad(
      string = district,
      width = 2,
      side = "left",
      pad = "0"
    )
  )

# format class for race variable
model_seat <- senate_seat_forecast %>%
  rename(district = class) %>%
  mutate(
    district = str_pad(
      string = district,
      width = 2,
      side = "left",
      pad = "S"
    )
  )

model_combined <-
  bind_rows(model_district, model_seat, .id = "chamber") %>%
  # create race variable for relational join
  unite(
    col = race,
    state, district,
    sep = "-",
    remove = TRUE
  ) %>%
  rename(
    name = candidate,
    date = forecastdate,
    prob = win_probability,
    min_share = p10_voteshare,
    max_share = p90_voteshare
  ) %>%
  mutate(
    chamber = recode(
      .x = chamber,
      "1" = "house",
      "2" = "senate"
    ),
    # only special elections are for senate.
    special = case_when(
      is.na(special) ~ FALSE,
      !is.na(special) ~ special
    ),
    # both caucus with Democrats
    party = case_when(
      name == "Bernard Sanders" ~ "D",
      name == "Angus S. King Jr." ~ "D",
      TRUE ~ party
    )
  ) %>%
  # Convert percent vote share values to decimal
  mutate_at(vars(10:12), multiply_by, 0.01) %>%
  # keep only named candidates
  filter(name != "Others", name != "Zak Ringelstein") %>%
  # reorder data frame
  select(date, race, name, party, chamber, everything()) %>%
  arrange(date, name)

# seperate model data by model format
model_combined <- model_combined %>%
  group_split(model) %>%
  set_names(c("classic", "lite", "deluxe")) %>%
  map(select, -model)

# according to 538, the "classic" model can be used as a default
model <- model_combined$classic

# save text file
write_csv(
  x = model,
  path = "data/new/markets.csv",
  na = ""
)

# format election results -------------------------------------------------

## source:    https://fivethirtyeight.com/
## input:     input/forecast_results_2018.csv
## desc:      final predictions and election results
## use:       assess the accuracy of both predictive methods

results <- forecast_results %>%
  filter(
    branch != "Governor",
    version == "classic"
  ) %>%
  separate(
    col = race,
    into = c("state", "district"),
    sep = "-"
  ) %>%
  rename(winner = Democrat_Won) %>%
  mutate(district = str_pad(district, width = 2,  pad   = "0")) %>%
  unite(
    state, district,
    col = race,
    sep = "-"
  ) %>%
  select(race, winner) %>%
  filter(race != "NC-09") # Harris fraud charges

# save text file
write_csv(
  x = results,
  path = "data/new/results.csv",
  na = ""
)

# format partisan lean index ----------------------------------------------

## source:    https://fivethirtyeight.com/
## input:     input/partisan_lean_*.csv
## desc:      relative partisanship of state or district vs national average
## use:       assess race predictions for partisan bias

# Separate lean value and replace state name with state abbreviation
lean_states <- partisan_lean_STATES %>%
  separate(
    col = pvi_538,
    into = c("party", "lean"),
    sep = "\\+",
    convert = TRUE
  ) %>%
  rename(race = state) %>%
  mutate(race = paste(state.abb, "S1", sep = "-"))

# Seperate lean value and pad district number for race code
lean_district <- partisan_lean_DISTRICTS %>%
  separate(
    col = pvi_538,
    into = c("party", "lean"),
    sep = "\\+",
    convert = TRUE
  ) %>%
  separate(
    col = district,
    into = c("state", "race"),
    sep = "\\-"
  ) %>%
  mutate(race = str_pad(race, width = 2, pad = "0")) %>%
  unite(
    col = race,
    state, race,
    sep = "-"
  )

# Turn single number into negative-positive spectrum
lean <-
  bind_rows(lean_states, lean_district) %>%
  mutate(
    lean = case_when(
      party == "D" ~ lean * -1,
      party == "R" ~ lean
    )
  )

# save text file
write_csv(
  x = lean,
  path = "data/new/lean.csv",
  na = ""
)

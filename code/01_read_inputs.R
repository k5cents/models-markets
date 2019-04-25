### Kiernan Nicholls
### American University
### Spring, 2019
### Predictr: markets vs models
### Read in raw input data

# devtools::install_github("hrbrmstr/wayback")
library(wayback)
library(tidyverse)

# read market data from https://www.predictit.org/ ------------------------

## Market Data sent by will.jennings@predictit.org
## Detailed price history provided to academic researchers
DailyMarketData <-
  here::here("data", "DailyMarketData.csv") %>%
  read_delim(delim = "|",
             na = "n/a",
             col_types = cols(
               MarketId = col_character(),
               ContractName = col_character(),
               ContractSymbol = col_character(),
               Date = col_date(format = "")))

Market_ME02 <-
  here::here("data", "Market_ME02.csv") %>%
  read_csv(col_types = cols(ContractID = col_character(),
                            Date = col_date(format = "%m/%d/%Y")))

Contract_NY27 <-
  here::here("data" , "Contract_NY27.csv") %>%
  read_csv(na = c("n/a", "NA"),
           skip = 156, # this file was a mess
           col_types = cols(ContractID = col_character(),
                            Date = col_date(format = "%m/%d/%Y")))

# read member data from https://theunitedstates.io/ -----------------------

## Current members of the 115th
## Archived: 2018-10-22 at 18:11
legislators_current <-
  "https://theunitedstates.io/congress-legislators/legislators-current.csv" %>%
  read_memento(timestamp = "2018-10-22", as = "raw") %>%
  read_csv(col_types = cols(govtrack_id = col_character()))

# The ideology and leadership scores of the 115th
# Calculated with cosponsorship analysis
# Archived 2019-01-21 17:13:08
sponsorshipanalysis_h <-
  "https://www.govtrack.us/data/analysis/by-congress/115/sponsorshipanalysis_h.txt" %>%
  read_memento(timestamp = "2019-03-23", as = "raw") %>%
  read_csv(col_types = cols(ID = col_character()))

sponsorshipanalysis_s <-
  "https://www.govtrack.us/data/analysis/by-congress/115/sponsorshipanalysis_s.txt" %>%
  read_memento(timestamp = "2019-03-23", as = "raw") %>%
  read_csv(col_types = cols(ID = col_character()))

# read model, polling, and results data from https://fivethirtyeig --------

## District level 538 House model history
## Updated:  2018-11-06 at 01:56
## Archived: 2018-11-06 at 12:06
house_district_forecast <-
  "https://projects.fivethirtyeight.com/congress-model-2018/house_district_forecast.csv" %>%
  read_memento(timestamp = "2018-11-06", as = "raw") %>%
  read_csv()


# National level 538 House model history
# Updated:  2018-11-06 at 01:56
# Archived: 2018-11-06 at 12:06
house_national_forecast <-
  "https://projects.fivethirtyeight.com/congress-model-2018/house_district_forecast.csv" %>%
  read_memento(timestamp = "2018-11-06", as = "raw") %>%
  read_csv()

# Seat level 538 Senate model history
# Updated:  2018-11-06 at 11:06
# Archived: 2018-11-06 at 21:00
senate_seat_forecast <-
  "https://projects.fivethirtyeight.com/congress-model-2018/senate_seat_forecast.csv" %>%
  read_memento(timestamp = "2018-11-06", as = "raw") %>%
  read_csv()

# National level 538 Senate model history
# Updated:  2018-11-06 at 11:06
# Archived: 2018-11-06 at 21:00
senate_national_forecast <-
  "https://projects.fivethirtyeight.com/congress-model-2018/senate_national_forecast.csv" %>%
  read_memento(timestamp = "2018-11-06", as = "raw") %>%
  read_csv()

# Midterm election results via ABC and 538
# Used in https://53eig.ht/2PiFb0f
# Published: 2018-12-04 at 17:56
# Archived:  2018-04-04 at 16:08
forecast_results_2018 <-
  "https://raw.githubusercontent.com/fivethirtyeight/data/master/forecast-review/forecast_results_2018.csv" %>%
  read_memento(timestamp = "2019-04-04", as = "raw") %>%
  read_csv(col_types  = cols(
    Democrat_Won = col_logical(),
    Republican_Won = col_logical(),
    uncalled = col_logical(),
    forecastdate = col_date(format = "%m/%d/%y"),
    category = col_factor(ordered = TRUE,
                          levels = c("Solid D",
                                     "Likely D",
                                     "Lean D",
                                     "Tossup (Tilt D)",
                                     "Tossup (Tilt R)",
                                     "Lean R",
                                     "Likely R",
                                     "Safe R"))))

# Average difference between how a district votes and the country
# Updated:  2018-11-19 at 16:13
# Archived: 2018-04-04 at 16:05
partisan_lean_DISTRICTS <-
  "https://raw.githubusercontent.com/fivethirtyeight/data/master/partisan-lean/fivethirtyeight_partisan_lean_DISTRICTS.csv" %>%
  read_memento(timestamp = "2019-04-04", as = "raw") %>%
  read_csv()

partisan_lean_STATES <-
  "https://raw.githubusercontent.com/fivethirtyeight/data/master/partisan-lean/fivethirtyeight_partisan_lean_STATES.csv" %>%
  read_memento(timestamp = "2019-04-04", as = "raw") %>%
  read_csv()

# Polls incorperated in the 538 models
# Archived 2019-01-29 at 21:45
senate_polls <-
  "https://projects.fivethirtyeight.com/polls-page/senate_polls.csv" %>%
  read_memento(timestamp = "2019-01-29", as = "raw") %>%
  read_csv(col_types = cols(
    question_id = col_character(),
    poll_id     = col_character(),
    pollster_id = col_character(),
    sponsor_ids = col_character(),
    start_date  = col_date("%m/%d/%y"),
    end_date    = col_date("%m/%d/%y"),
    created_at  = col_datetime("%m/%d/%y %H:%M")))

house_polls <-
  "https://projects.fivethirtyeight.com/polls-page/house_polls.csv" %>%
  read_memento(timestamp = "2019-01-29", as = "raw") %>%
  read_csv(col_types = cols(
    question_id = col_character(),
    poll_id     = col_character(),
    pollster_id = col_character(),
    sponsor_ids = col_character(),
    start_date  = col_date("%m/%d/%y"),
    end_date    = col_date("%m/%d/%y"),
    created_at  = col_datetime("%m/%d/%y %H:%M")))

generic_ballot_polls <-
  "https://projects.fivethirtyeight.com/polls-page/generic_ballot_polls.csv" %>%
  read_memento(timestamp = "2019-01-29", as = "raw") %>%
  read_csv(col_types = cols(
    question_id = col_character(),
    poll_id     = col_character(),
    pollster_id = col_character(),
    sponsor_ids = col_character(),
    start_date  = col_date("%m/%d/%y"),
    end_date    = col_date("%m/%d/%y"),
    created_at  = col_datetime("%m/%d/%y %H:%M")))

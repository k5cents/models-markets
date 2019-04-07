### Kiernan Nicholls
### American University
### Spring, 2019
### Predictr: markets vs models
### Read in raw input data

library(tidyverse)

# read market data from https://www.predictit.org/ ------------------------

## Market Data sent by will.jennings@predictit.org
## Detailed market history provided to partnered academic researchers
DailyMarketData <-
  readLines(con = file("./data/DailyMarketData.csv",
                        encoding = "UTF-16LE")) %>%
  read_delim(delim = "|",
             na = "n/a",
             col_types = cols(
               MarketId = col_character(),
               ContractName = col_character(),
               ContractSymbol = col_character(),
               Date = col_date(format = "")))

Market_ME02 <-
  read_csv(file = "./data/Market_ME02.csv",
           col_types = cols(ContractID = col_character(),
                            Date = col_date(format = "%m/%d/%Y")))

Contract_NY27 <-
  read_csv("./data/Contract_NY27.csv",
           na = c("n/a", "NA"),
           skip = 156, # this file was a mess
           col_types = cols(ContractID = col_character(),
                            Date = col_date(format = "%m/%d/%Y")))

# read member data from https://theunitedstates.io/ -----------------------

## Current members of the 115th
## Archived: 2018-10-22 at 18:11
legislators_current <-
  str_c(arch = "http://web.archive.org/web",
        date = "2018-10-22",
        site = "https://theunitedstates.io",
        path = "congress-legislators",
        file = "legislators-current.csv",
        sep  = "/") %>%
  read_csv(col_types = cols(govtrack_id = col_character()))

# The ideology and leadership scores of the 115th
# Calculated with cosponsorship analysis
# Archived 2019-01-21 17:13:08
sponsorshipanalysis_h <-
  str_c(arch = "http://web.archive.org/web",
        date = "2019-03-23",
        site = "https://www.govtrack.us",
        path = "data/analysis/by-congress/115",
        file = "sponsorshipanalysis_h.txt",
        sep  = "/") %>%
  read_csv(col_types = cols(ID = col_character()))

sponsorshipanalysis_s <-
  str_c(arch = "http://web.archive.org/web",
        date = "2019-03-23",
        site = "https://www.govtrack.us",
        path = "data/analysis/by-congress/115",
        file = "sponsorshipanalysis_s.txt",
        sep  = "/") %>%
  read_csv(col_types = cols(ID = col_character()))

# read model, polling, and results data from https://fivethirtyeig --------

## District level 538 House model history
## Updated:  2018-11-06 at 01:56
## Archived: 2018-11-06 at 12:06
house_district_forecast <-
  str_c(arch = "http://web.archive.org/web",
        date = "2018-11-06",
        site = "https://projects.fivethirtyeight.com",
        path = "congress-model-2018",
        file = "house_district_forecast.csv",
        sep  = "/") %>%
  read_csv(col_types = cols())

# National level 538 House model history
# Updated:  2018-11-06 at 01:56
# Archived: 2018-11-06 at 12:06
house_national_forecast <-
  str_c(arch = "http://web.archive.org/web",
        date = "2018-11-06",
        site = "https://projects.fivethirtyeight.com",
        path = "congress-model-2018",
        file = "house_national_forecast.csv",
        sep  = "/") %>%
  read_csv(col_types = cols())

# Seat level 538 Senate model history
# Updated:  2018-11-06 at 11:06
# Archived: 2018-11-06 at 21:00
senate_seat_forecast <-
  str_c(arch = "http://web.archive.org/web",
        date = "2018-11-06",
        site = "https://projects.fivethirtyeight.com",
        path = "congress-model-2018",
        file = "senate_seat_forecast.csv",
        sep  = "/") %>%
  read_csv(col_types = cols())

# National level 538 Senate model history
# Updated:  2018-11-06 at 11:06
# Archived: 2018-11-06 at 21:00
senate_national_forecast <-
  str_c(arch = "http://web.archive.org/web",
        date = "2018-11-06",
        site = "https://projects.fivethirtyeight.com",
        path = "congress-model-2018",
        file = "senate_national_forecast.csv",
        sep  = "/") %>%
  read_csv(col_types = cols())

# Midterm election results via ABC and 538
# Used in https://53eig.ht/2PiFb0f
# Published: 2018-12-04 at 17:56
# Archived:  2018-04-04 at 16:08

forecast_results_2018 <-
  str_c(arch = "https://web.archive.org/web",
        date = "2019-04-04",
        site = "https://raw.githubusercontent.com",
        user = "fivethirtyeight",
        repo = "data",
        bran = "master",
        path = "forecast-review",
        file = "forecast_results_2018.csv",
        sep = "/") %>%
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
  str_c(arch = "https://web.archive.org/web",
        date = "2019-04-04",
        site = "https://raw.githubusercontent.com",
        user = "fivethirtyeight",
        repo = "data",
        bran = "master",
        path = "partisan-lean",
          file = "fivethirtyeight_partisan_lean_DISTRICTS.csv",
        sep = "/") %>%
  read_csv(col_types = cols())

partisan_lean_STATES <-
  str_c(arch = "https://web.archive.org/web",
        date = "2019-04-04",
        site = "https://raw.githubusercontent.com",
        user = "fivethirtyeight",
        repo = "data",
        bran = "master",
        path = "partisan-lean",
        file = "fivethirtyeight_partisan_lean_STATES.csv",
        sep = "/") %>%
  read_csv(col_types = cols())

# Polls incorperated in the 538 models
# Archived 2019-01-29 at 21:45
senate_polls <-
  str_c(arch = "http://web.archive.org/web",
        date = "2019-01-29",
        site = "https://projects.fivethirtyeight.com",
        path = "polls-page",
        file = "senate_polls.csv",
        sep = "/") %>%
  read_csv(col_types = cols(
    question_id = col_character(),
    poll_id     = col_character(),
    pollster_id = col_character(),
    sponsor_ids = col_character(),
    start_date  = col_date("%m/%d/%y"),
    end_date    = col_date("%m/%d/%y"),
    created_at  = col_datetime("%m/%d/%y %H:%M")))

house_polls <-
  str_c(arch = "http://web.archive.org/web",
        date = "2019-01-29",
        site = "https://projects.fivethirtyeight.com",
        path = "polls-page",
        file = "house_polls.csv",
        sep = "/") %>%
  read_csv( col_types = cols(
    question_id = col_character(),
    poll_id     = col_character(),
    pollster_id = col_character(),
    sponsor_ids = col_character(),
    start_date  = col_date("%m/%d/%y"),
    end_date    = col_date("%m/%d/%y"),
    created_at  = col_datetime("%m/%d/%y %H:%M")))

generic_ballot_polls <-
  str_c(arch = "http://web.archive.org/web",
        date = "2019-01-29",
        site = "https://projects.fivethirtyeight.com",
        path = "polls-page",
        file = "generic_ballot_polls.csv",
        sep = "/") %>%
  read_csv( col_types = cols(
    question_id = col_character(),
    poll_id     = col_character(),
    pollster_id = col_character(),
    sponsor_ids = col_character(),
    start_date  = col_date("%m/%d/%y"),
    end_date    = col_date("%m/%d/%y"),
    created_at  = col_datetime("%m/%d/%y %H:%M")))

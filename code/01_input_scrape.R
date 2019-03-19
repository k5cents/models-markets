# Kiernan Nicholls
# Scrape archived websites and github repos for initial data
# Run all formatting code at once
library(tidyverse)

# Functions to scrape CSV from archive.org and github.com
read_archive <- function(archive, date, site, folder, file, ...) {
  paste("https://web.archive.org/web",
        str_remove_all(string = as.character(date), pattern = "[[:punct:]\\s]"),
        site,
        folder,
        file,
        sep = "/") %>%
    read_csv(...)
}
read_github <- function(user, repo, branch, folder, file, ...) {
  paste("https://raw.githubusercontent.com",
        user,
        repo,
        branch,
        folder,
        file,
        sep = "/") %>%
    read_csv(...)
}

# Prediction Market data courtesy of PredictIt.org
# Advance data provided to partnered researchers
# See /old for code to scrape similar public data
DailyMarketData <-
  read_delim(file = "./input/DailyMarketData.csv",
             delim = "|",
             na = c("n/a", "NA"),
             col_types = cols(MarketId = col_character(),
                              ContractName = col_character(),
                              ContractSymbol = col_character()))

DailyMarketData %>% write_csv("./input/DailyMarketData.csv")

Market_ME02 <-
  read_csv(file = "./input/Market_ME02.csv",
           col_types = cols(ContractID = col_character(),
                            Date = col_date(format = "%m/%d/%Y"))) %>%
  filter(Date > "2018-10-10")

Market_ME02 %>% write_csv("./input/Market_ME02.csv")

Market_NY27 <-
  read_csv("./input/Market_NY27.csv",
           na = c("n/a", "NA"),
           skip = 157, # this file was a mess
           col_types = cols(ContractID = col_character(),
                            Date = col_date(format = "%m/%d/%Y"))) %>%
  slice(6:154)

Market_NY27 %>% write_csv("./input/Market_NY27.csv")

# Current members of the 115th Congress
# Archived: 2018-10-22 at 18:11
legislators_current <-
  read_archive(date = "2018-10-22 18:11:18",
               site = "https://theunitedstates.io",
               folder = "congress-legislators",
               file = "legislators-current.csv")

legislators_current %>% write_csv("./input/legislators_current.csv")

# District level FiveThirtyEight House model
# Updated:  2018-11-06 at 01:56
# Archived: 2018-11-06 at 12:06
house_district_forecast <-
  read_archive(date   = "2018-11-06 12:06:23",
               site   = "https://projects.fivethirtyeight.com",
               folder = "congress-model-2018",
               file   = "house_district_forecast.csv")

house_district_forecast %>% write_csv("./input/house_district_forecast.csv")

# National level FiveThirtyEight House model
# Updated:  2018-11-06 at 01:56
# Archived: 2018-11-06 at 12:06
house_national_forecast <-
  read_archive(date   = "2018-11-06 12:06:23",
               site   = "https://projects.fivethirtyeight.com",
               folder = "congress-model-2018",
               file   = "house_national_forecast.csv")

house_national_forecast %>% write_csv("./input/house_national_forecast.csv")

# Seat level FiveThirtyEight Senate model
# Updated:  2018-11-06 at 11:06
# Archived: 2018-11-06 at 21:00
senate_seat_forecast <-
  read_archive(date   = "2018-11-06 21:00:48",
               site   = "https://projects.fivethirtyeight.com",
               folder = "congress-model-2018",
               file   = "senate_seat_forecast.csv")

senate_seat_forecast %>% write_csv("./input/senate_seat_forecast.csv")

# National level FiveThirtyEight Senate model
# Updated:  2018-11-06 at 11:06
# Archived: 2018-11-06 at 21:00
senate_national_forecast <-
  read_archive(date   = "2018-11-06 21:00:48",
               site   = "https://projects.fivethirtyeight.com",
               folder = "congress-model-2018",
               file   = "senate_national_forecast.csv")

senate_national_forecast %>% write_csv("./input/senate_national_forecast.csv")

# Midterm election results via ABC and FiveThirtyEight
# Used in https://53eig.ht/2PiFb0f
# Published 2018-12-04 5:56
forecast_results_2018 <-
  read_github(user   = "fivethirtyeight",
              branch = "master",
              repo   = "data",
              folder = "forecast-review",
              file   = "forecast_results_2018.csv",
              col_types = cols(cycle = col_character(),
                               forecastdate = col_date(format = "%m/%d/%y"),
                               Democrat_Won = col_logical(),
                               Republican_Won = col_logical(),
                               uncalled = col_logical()))

forecast_results_2018 %>% write_csv("./input/forecast_results_2018.csv")

# Average difference between how a state or district votes and how the country
# votes overall (50% pres. 2016, 25% pres. 2012, 25% state legislatures)
partisan_lean_DISTRICTS <-
  read_github(user   = "fivethirtyeight",
              branch = "master",
              repo   = "data",
              folder = "partisan-lean",
              file   = "fivethirtyeight_partisan_lean_DISTRICTS.csv")

partisan_lean_DISTRICTS %>% write_csv("./input/partisan_lean_DISTRICTS.csv")

partisan_lean_STATES <-
  read_github(user   = "fivethirtyeight",
              branch = "master",
              repo   = "data",
              folder = "partisan-lean",
              file   = "fivethirtyeight_partisan_lean_STATES.csv")

partisan_lean_STATES %>% write_csv("./input/partisan_lean_STATES.csv")

# Polls used to create the 538 models
# Archived 2019-01-29 21:45:47
senate_polls <-
  read_archive(date = "2019-01-29 21:45:47",
               site = "https://projects.fivethirtyeight.com",
               folder = "polls-page",
               file = "senate_polls.csv")

senate_polls %>% write_csv("./input/senate_polls.csv")

house_polls <-
  read_archive(date = "2019-01-29 21:45:47",
               site = "https://projects.fivethirtyeight.com",
               folder = "polls-page",
               file = "house_polls.csv")

house_polls %>% write_csv("./input/house_polls.csv")

generic_ballot_polls <-
  read_archive(date = "2019-01-29 21:45:47",
               site = "https://projects.fivethirtyeight.com",
               folder = "polls-page",
               file = "generic_ballot_polls.csv")

generic_ballot_polls %>% write_csv("./input/generic_ballot_polls.csv")

# Read in the GovTrack stats for 115th
sponsorshipanalysis_h <-
  read_archive(date = "2019-01-21 17:13:08",
               site = "https://www.govtrack.us",
               folder = "data/us/115/stats",
               file = "sponsorshipanalysis_h.txt",
               col_types = cols(ID = col_character())) %>%
  mutate(chamber = "house")

sponsorshipanalysis_h %>% write_csv("./input/sponsorshipanalysis_h.csv")

sponsorshipanalysis_s <-
  read_archive(date = "2019-01-21 17:13:08",
               site = "https://www.govtrack.us",
               folder = "data/us/115/stats",
               file = "sponsorshipanalysis_s.txt",
               col_types = cols(ID = col_character())) %>%
  mutate(chamber = "senate")

sponsorshipanalysis_s %>% write_csv("./input/sponsorshipanalysis_s.csv")

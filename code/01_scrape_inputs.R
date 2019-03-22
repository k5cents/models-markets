### Kiernan Nicholls
### American University
### Spring, 2019
### Predictr: markets vs models
### Read in raw input data

library(tidyverse)

# define reading functions ------------------------------------------------

## Most inputs manually archived using the archive.org "WaybackMachine"

read_archive <- function(archive, date, site, folder, file, ...) {
  paste("https://web.archive.org/web",
        str_remove_all(string = as.character(date), pattern = "[[:punct:]\\s]"),
        site,
        folder,
        file,
        sep = "/") %>%
    read_csv(...)
}

read_github  <- function(user, repo, branch, folder, file, ...) {
  paste("https://raw.githubusercontent.com",
        user,
        repo,
        branch,
        folder,
        file,
        sep = "/") %>%
    read_csv(...)
}

# read input data ---------------------------------------------------------

## Prediction Market data courtesy of    https://www.predictit.org/
## Forecast Model data courtesy of       https://fivethirtyeight.com/
## Congress Member data courtsey of      https://theunitedstates.io/

# Market Data sent by will.jennings@predictit.org
# Detailed market history provided to partnered academic researchers
DailyMarketData <-
  readLines(con = file("./input/DailyMarketData.csv",
                        encoding = "UTF-16LE")) %>%
  read_delim(delim = "|",
             na = "n/a",
             col_types = cols(
               MarketId = col_character(),
               ContractName = col_character(),
               ContractSymbol = col_character(),
               Date = col_date(format = "")))

close(con = file("./input/DailyMarketData.csv"))

Market_ME02 <-
  read_csv(file = "./input/Market_ME02.csv",
           col_types = cols(ContractID = col_character(),
                            Date = col_date(format = "%m/%d/%Y")))

Contract_NY27 <-
  read_csv("./input/Contract_NY27.csv",
           na = c("n/a", "NA"),
           skip = 157, # this file was a mess
           col_types = cols(ContractID = col_character(),
                            Date = col_date(format = "%m/%d/%Y")))

# Current members of the 115th
# Archived: 2018-10-22 at 18:11
legislators_current <-
  read_archive(date = "2018-10-22 18:11:18",
               site = "https://theunitedstates.io",
               folder = "congress-legislators",
               file = "legislators-current.csv",
               col_types = cols(govtrack_id = col_character()))

# District level 538 House model history
# Updated:  2018-11-06 at 01:56
# Archived: 2018-11-06 at 12:06
house_district_forecast <-
  read_archive(date   = "2018-11-06 12:06:23",
               site   = "https://projects.fivethirtyeight.com",
               folder = "congress-model-2018",
               file   = "house_district_forecast.csv",
               col_types = cols(
                 model = col_factor(levels = c("lite", "classic", "deluxe"))))

# National level 538 House model history
# Updated:  2018-11-06 at 01:56
# Archived: 2018-11-06 at 12:06
house_national_forecast <-
  read_archive(date   = "2018-11-06 12:06:23",
               site   = "https://projects.fivethirtyeight.com",
               folder = "congress-model-2018",
               file   = "house_national_forecast.csv",
               col_types = cols(
                 model = col_factor(levels = c("lite", "classic", "deluxe"))))

# Seat level 538 Senate model history
# Updated:  2018-11-06 at 11:06
# Archived: 2018-11-06 at 21:00
senate_seat_forecast <-
  read_archive(date   = "2018-11-06 21:00:48",
               site   = "https://projects.fivethirtyeight.com",
               folder = "congress-model-2018",
               file   = "senate_seat_forecast.csv",
               col_types = cols(
                 model = col_factor(levels = c("lite", "classic", "deluxe"))))

# National level 538 Senate model history
# Updated:  2018-11-06 at 11:06
# Archived: 2018-11-06 at 21:00
senate_national_forecast <-
  read_archive(date   = "2018-11-06 21:00:48",
               site   = "https://projects.fivethirtyeight.com",
               folder = "congress-model-2018",
               file   = "senate_national_forecast.csv",
               col_types = cols(
                 model = col_factor(levels = c("lite", "classic", "deluxe"))))

# Midterm election results via ABC and 538
# Used in https://53eig.ht/2PiFb0f
# Published 2018-12-04 17:56
forecast_results_2018 <-
  read_github(user   = "fivethirtyeight",
              branch = "master",
              repo   = "data",
              folder = "forecast-review",
              file   = "forecast_results_2018.csv",
              col_types  = cols(
                category = col_factor(ordered = TRUE,
                                      levels = c("Solid D",
                                                 "Likely D",
                                                 "Lean D",
                                                 "Tossup (Tilt D)",
                                                 "Tossup (Tilt R)",
                                                 "Lean R",
                                                 "Likely R",
                                                 "Safe R")),
                Democrat_Won = col_logical(),
                Republican_Won = col_logical(),
                uncalled = col_logical()))

# Average difference between how a district votes and the country
# First introduced in http://53eig.ht/1rtnTwh
# Last updated 2018-11-19 16:13
partisan_lean_DISTRICTS <-
  read_github(user   = "fivethirtyeight",
              branch = "master",
              repo   = "data",
              folder = "partisan-lean",
              file   = "fivethirtyeight_partisan_lean_DISTRICTS.csv")

partisan_lean_STATES <-
  read_github(user   = "fivethirtyeight",
              branch = "master",
              repo   = "data",
              folder = "partisan-lean",
              file   = "fivethirtyeight_partisan_lean_STATES.csv")

# Polls incorperated in the 538 models
# Archived 2019-01-29 21:45:47
senate_polls <-
  read_archive(date = "2019-01-29 21:45:47",
               site = "https://projects.fivethirtyeight.com",
               folder = "polls-page",
               file = "senate_polls.csv",
               col_types = cols(
                 question_id = col_character(),
                 poll_id = col_character(),
                 pollster_id = col_character(),
                 sponsor_ids = col_character(),
                 start_date = col_date("%m/%d/%y"),
                 end_date = col_date("%m/%d/%y"),
                 created_at = col_datetime("%m/%d/%y %H:%M")))

house_polls <-
  read_archive(date = "2019-01-29 21:45:47",
               site = "https://projects.fivethirtyeight.com",
               folder = "polls-page",
               file = "house_polls.csv",
               col_types = cols(
                 question_id = col_character(),
                 poll_id = col_character(),
                 pollster_id = col_character(),
                 sponsor_ids = col_character(),
                 start_date = col_date("%m/%d/%y"),
                 end_date = col_date("%m/%d/%y"),
                 created_at = col_datetime("%m/%d/%y %H:%M")))

generic_ballot_polls <-
  read_archive(date = "2019-01-29 21:45:47",
               site = "https://projects.fivethirtyeight.com",
               folder = "polls-page",
               file = "generic_ballot_polls.csv",
               col_types = cols(
                 question_id = col_character(),
                 poll_id = col_character(),
                 pollster_id = col_character(),
                 sponsor_ids = col_character(),
                 start_date = col_date("%m/%d/%y"),
                 end_date = col_date("%m/%d/%y"),
                 created_at = col_datetime("%m/%d/%y %H:%M")))

# The ideology and leadership scores of the 115th
# Calculated with cosponsorship analysis
# Archived 2019-01-21 17:13:08
sponsorshipanalysis_h <-
  read_archive(date = "2019-01-21 17:13:08",
               site = "https://www.govtrack.us",
               folder = "data/us/115/stats",
               file = "sponsorshipanalysis_h.txt",
               col_types = cols(ID = col_character()))

sponsorshipanalysis_s <-
  read_archive(date = "2019-01-21 17:13:08",
               site = "https://www.govtrack.us",
               folder = "data/us/115/stats",
               file = "sponsorshipanalysis_s.txt",
               col_types = cols(ID = col_character()))

# Kiernan Nicholls
# Scrape archived websites and github repos for initial data
# Run all formatting code at once
library(tidyverse)

# Read --------------------------------------------------------------------

# Functions to scrape CSV from archive.org and github.com
read_archive <- function(archive, date, site, folder, file, ...) {
  archive_url <- paste("https://web.archive.org/web",
                       str_remove_all(string = as.character(date),
                                      pattern = "[[:punct:]\\s]"),
                       site,
                       folder,
                       file,
                       sep = "/")
  read_csv(archive_url, ...)
}

read_github <- function(user, repo, branch, folder, file, ...) {
  github_url <- paste("https://raw.githubusercontent.com",
                      user,
                      repo,
                      branch,
                      folder,
                      file,
                      sep = "/")
  read_csv(github_url, ...)
}

# Current members of the 115th Congress
# Archived: 2018-10-22 at 18:11
members_115 <- read_archive(date = "2018-10-22 18:11:18",
                            site = "https://theunitedstates.io",
                            folder = "congress-legislators",
                            file = "legislators-current.csv")
write_csv(members_115, "./input/members_115.csv")

# Current members of the 116th Congress
# Archived: 2019-01-19 at 17:30
members_116 <- read_archive(date   = "2019-01-19 at 17:30:05",
                            site   = "https://theunitedstates.io",
                            folder = "congress-legislators",
                            file   = "legislators-current.csv")
write_csv(members_116, "./input/members_116.csv")

# District level FiveThirtyEight House model
# Updated:  2018-11-06 at 01:56
# Archived: 2018-11-06 at 12:06
model_district <- read_archive(date   = "2018-11-06 12:06:23",
                               site   = "https://projects.fivethirtyeight.com",
                               folder = "congress-model-2018",
                               file   = "house_district_forecast.csv")
write_csv(model_district, "./input/model_district.csv")

# National level FiveThirtyEight House model
# Updated:  2018-11-06 at 01:56
# Archived: 2018-11-06 at 12:06
model_house <- read_archive(date   = "2018-11-06 12:06:23",
                            site   = "https://projects.fivethirtyeight.com",
                            folder = "congress-model-2018",
                            file   = "house_national_forecast.csv")
write_csv(model_house, "./input/model_house.csv")

# Seat level FiveThirtyEight Senate model
# Updated:  2018-11-06 at 11:06
# Archived: 2018-11-06 at 21:00
model_seat <- read_archive(date   = "2018-11-06 21:00:48",
                           site   = "https://projects.fivethirtyeight.com",
                           folder = "congress-model-2018",
                           file   = "senate_seat_forecast.csv")
write_csv(model_seat, "./input/model_seat.csv")

# National level FiveThirtyEight Senate model
# Updated:  2018-11-06 at 11:06
# Archived: 2018-11-06 at 21:00
model_senate <- read_archive(date   = "2018-11-06 21:00:48",
                             site   = "https://projects.fivethirtyeight.com",
                             folder = "congress-model-2018",
                             file   = "senate_national_forecast.csv")
write_csv(model_senate, "./input/model_senate.csv")

# Prediction Market data courtesy of PredictIt.org
# Advance data provided to partnered researchers
# See /old for code to scrape similar public data
market_data <- read_csv(file = "./input/market_data.csv",
                        na = c("n/a", "NA"),
                        col_types = cols(MarketId = col_character(),
                                         ContractName = col_character(),
                                         ContractSymbol = col_character()))

# Midterm election results via ABC and FiveThirtyEight
# Used in https://53eig.ht/2PiFb0f
# Published 2018-12-04 5:56
election_results <-
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
write_csv(election_results, "./input/election_results.csv")

# Average difference between how a state or district votes and how the country
# votes overall (50% pres. 2016, 25% pres. 2012, 25% state legislatures)
lean_district <-
  read_github(user   = "fivethirtyeight",
              branch = "master",
              repo   = "data",
              folder = "partisan-lean",
              file   = "fivethirtyeight_partisan_lean_DISTRICTS.csv")
write_csv(lean_district, "./input/lean_district.csv")

lean_states <-
  read_github(user   = "fivethirtyeight",
              branch = "master",
              repo   = "data",
              folder = "partisan-lean",
              file   = "fivethirtyeight_partisan_lean_STATES.csv")
write_csv(lean_states, "./input/lean_states.csv")

# Polls used to create the 538 models
# Archived 2019-01-29 21:45:47
polls_senate <- read_archive(date = "2019-01-29 21:45:47",
                             site = "https://projects.fivethirtyeight.com",
                             folder = "polls-page",
                             file = "senate_polls.csv")
write_csv(polls_senate, "./input/polls_senate.csv")

polls_house <- read_archive(date = "2019-01-29 21:45:47",
                            site = "https://projects.fivethirtyeight.com",
                            folder = "polls-page",
                            file = "house_polls.csv")
write_csv(polls_house, "./input/polls_house.csv")

polls_generic <- read_archive(date = "2019-01-29 21:45:47",
                              site = "https://projects.fivethirtyeight.com",
                              folder = "polls-page",
                              file = "generic_ballot_polls.csv")
write_csv(polls_generic, "./input/polls_generic.csv")

# Read in the GovTrack stats for 115th
house_115_stats <-
  read_archive(date = "2019-01-21 17:13:08",
               site = "https://www.govtrack.us",
               folder = "data/us/115/stats",
               file = "sponsorshipanalysis_h.txt",
               col_types = cols(ID = col_character())) %>%
  mutate(chamber = "house")
write_csv(house_115_stats, "./input/house_115_stats.csv")

senate_115_stats <-
  read_archive(date = "2019-01-21 17:13:08",
               site = "https://www.govtrack.us",
               folder = "data/us/115/stats",
               file = "sponsorshipanalysis_s.txt",
               col_types = cols(ID = col_character())) %>%
  mutate(chamber = "senate")
write_csv(senate_115_stats, "./input/senate_115_stats.csv")

# Format and Write --------------------------------------------------------

# Run all scripts to format inputs
# Read names of all code scripts
code_filenames <- list.files(path = "./code", full.names = TRUE)
# Source scripts from names
for (i in 2:length(code_filenames)) {
  source(file = code_filenames[i], echo = FALSE)
}
rm(code_filenames, i, house_115_stats, senate_115_stats)

write_csv(members,      "./output/members.csv")
write_csv(market,       "./output/market.csv")
write_csv(model,        "./output/model.csv")
write_csv(model_lite,   "./output/model_lite.csv")
write_csv(model_delux,  "./output/model_delux.csv")
write_csv(predictions,  "./output/predictions.csv")
write_csv(race_lean,    "./output/race_lean.csv")
write_csv(polling_key,  "./output/polling_key.csv")
write_csv(polling_data, "./output/polling_data.csv")

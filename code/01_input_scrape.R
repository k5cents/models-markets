# Kiernan Nicholls
# Scrape archived websites for Members of Congress and 538 model history
library(tidyverse)
library(rvest)

# Current members of the 115th Congress
# Archived: 2018-10-22 at 18:11
members_115 <- read_csv("https://web.archive.org/web/20181022181118/https://theunitedstates.io/congress-legislators/legislators-current.csv")

# Current members of the 116th Congress
# Archived: 2019-01-19 at 17:30
members_116 <- read_csv("https://web.archive.org/web/20190119173005/https://theunitedstates.io/congress-legislators/legislators-current.csv")

# District level FiveThirtyEight House model
# Updated:  2018-11-06 at 01:56
# Archived: 2018-11-06 at 12:06
# model_district <- read_csv("https://web.archive.org/web/20181106120623/https://projects.fivethirtyeight.com/congress-model-2018/house_district_forecast.csv")
model_district <- read_csv("https://projects.fivethirtyeight.com/congress-model-2018/house_district_forecast.csv")

# National level FiveThirtyEight House model
# Updated:  2018-11-06 at 01:56
# Archived: 2018-11-06 at 12:06
# model_house <- read_csv("https://web.archive.org/web/20181106120623/https://projects.fivethirtyeight.com/congress-model-2018/house_national_forecast.csv")
model_house <- read_csv("https://projects.fivethirtyeight.com/congress-model-2018/house_national_forecast.csv")

# Seat level FiveThirtyEight Senate model
# Updated:  2018-11-06 at 11:06
# Archived: 2018-11-06 at 21:00
# model_seat <- read_csv("https://web.archive.org/web/20181106210048/https://projects.fivethirtyeight.com/congress-model-2018/senate_seat_forecast.csv")
model_seat <- read_csv("https://projects.fivethirtyeight.com/congress-model-2018/senate_seat_forecast.csv")

# National level FiveThirtyEight Senate model
# Updated:  2018-11-06 at 11:06
# Archived: 2018-11-06 at 21:00
# model_senate <- read_csv("https://web.archive.org/web/20181106210048/https://projects.fivethirtyeight.com/congress-model-2018/senate_national_forecast.csv")
model_senate <- read_csv("https://projects.fivethirtyeight.com/congress-model-2018/senate_national_forecast.csv")

# Prediction Market data courtesy of PredictIt.org
# Advance data provided to partnered researchers
# See /old for code to scrape similar public data
market_data <- read_csv(file = "./input/market_data.csv",
                        na = c("n/a", "NA"),
                        col_types = cols(MarketId = col_character(),
                                         ContractName = col_character(),
                                         ContractSymbol = col_character()))

read_github <- function(user, repo, branch = "master", folder, file, ...) {
  github_url <- paste("https://raw.githubusercontent.com",
                      user,
                      repo,
                      branch,
                      folder,
                      file,
                      sep = "/")
  read_csv(github_url, ...)
}

election_results <- read_github(user   = "fivethirtyeight",
                                repo   = "data",
                                folder = "forecast-review",
                                file   = "forecast_results_2018.csv",
                                col_types = cols(cycle = col_character(),
                                                 Democrat_Won = col_logical(),
                                                 Republican_Won = col_logical(),
                                                 uncalled = col_logical()))

lean_district <- read_github(user   = "fivethirtyeight",
                             repo   = "data",
                             folder = "partisan-lean",
                             file   = "fivethirtyeight_partisan_lean_DISTRICTS.csv")

lean_states <- read_github(user   = "fivethirtyeight",
                           repo   = "data",
                           folder = "partisan-lean",
                           file   = "fivethirtyeight_partisan_lean_STATES.csv")

# write_csv(members_115,    "./input/members_115.csv")
# write_csv(members_116,    "./input/members_116.csv")
# write_csv(model_district, "./input/model_district.csv")
# write_csv(model_house,    "./input/model_house.csv")
# write_csv(model_seat,     "./input/model_seat.csv")
# write_csv(model_senate,   "./input/model_senate.csv")

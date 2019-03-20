# Kiernan Nicholls
# Quickly read written data from 01_input_scrape
library(tidyverse)

DailyMarketData <- read_csv(file = "./input/DailyMarketData.csv",
                            locale = locale(tz = "EST"),
                            col_types = cols(
                              MarketId = col_character(),
                              ContractName = col_character(),
                              ContractSymbol = col_character(),
                              Date = col_date(format = "")))

forecast_results_2018 <-
  read_csv(file = "./input/forecast_results_2018.csv",
           locale = locale(tz = "EST"),
           col_types = cols(
             branch = col_factor(),
             version = col_factor(),
             category = col_factor(ordered = TRUE,
                                   levels = c("Solid D",
                                              "Likely D",
                                              "Lean D",
                                              "Tossup (Tilt D)",
                                              "Tossup (Tilt R)",
                                              "Lean R",
                                              "Likely R",
                                              "Safe R"))))

generic_ballot_polls <-
  read_csv(file = "./input/generic_ballot_polls.csv",
           locale = locale(tz = "EST"),
           col_types = cols(
             question_id = col_character(),
             poll_id = col_character(),
             pollster_id = col_character(),
             sponsor_ids = col_character(),
             start_date = col_date("%m/%d/%y"),
             end_date = col_date("%m/%d/%y"),
             created_at = col_datetime("%m/%d/%y %H:%M")))

house_district_forecast  <-
  read_csv(file = "./input/house_district_forecast.csv",
           locale = locale(tz = "EST"),
           col_types = cols(
             model = col_factor(levels = c("lite", "classic", "deluxe"))))

house_national_forecast <-
  read_csv(file = "./input/house_national_forecast.csv",
           locale = locale(tz = "EST"),
           col_types = cols(
             model = col_factor(levels = c("lite", "classic", "deluxe"))))

house_polls <-
  read_csv(file = "./input/house_polls.csv",
           locale = locale(tz = "EST"),
           col_types = cols(
             question_id = col_character(),
             poll_id = col_character(),
             pollster_id = col_character(),
             sponsor_ids = col_character(),
             start_date = col_date("%m/%d/%y"),
             end_date = col_date("%m/%d/%y"),
             created_at = col_datetime("%m/%d/%y %H:%M")))

legislators_current <-
  read_csv(file = "./input/legislators_current.csv",
           col_types = cols(govtrack_id = col_character()))

Market_ME02 <- read_csv(file = "./input/Market_ME02.csv",
                        col_types = cols(
                          ContractID = col_character(),
                          Date = col_date(format = "%m/%d/%Y")))

Market_NY27 <- read_csv(file = "./input/Market_NY27.csv",
                        col_types = cols(ContractID = col_character()))

partisan_lean_DISTRICTS  <- read_csv("./input/partisan_lean_DISTRICTS.csv")

partisan_lean_STATES     <- read_csv("./input/partisan_lean_STATES.csv")

senate_national_forecast <-
  read_csv(file = "./input/senate_national_forecast.csv",
           locale = locale(tz = "EST"),
           col_types = cols(
             model = col_factor(levels = c("lite", "classic", "deluxe"))))

senate_polls <-
  read_csv(file = "./input/senate_polls.csv",
           locale = locale(tz = "EST"),
           col_types = cols(
             question_id = col_character(),
             poll_id = col_character(),
             pollster_id = col_character(),
             sponsor_ids = col_character(),
             start_date = col_date("%m/%d/%y"),
             end_date = col_date("%m/%d/%y"),
             created_at = col_datetime("%m/%d/%y %H:%M")))

senate_seat_forecast <-
  read_csv(file = "./input/senate_seat_forecast.csv",
           col_types = cols(
             model = col_factor(levels = c("lite", "classic", "deluxe"))))

sponsorshipanalysis_h <- read_csv(file = "./input/sponsorshipanalysis_h.csv",
                                  col_types = cols(ID = col_character()))

sponsorshipanalysis_s <- read_csv(file = "./input/sponsorshipanalysis_s.csv",
                                  col_types = cols(ID = col_character()))

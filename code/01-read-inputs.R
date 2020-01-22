### kiernan nicholls
### american university
### spring, 2020
### markets and models
### save and read raw input data

# read market data from https://www.predictit.org/ ------------------------

## Market Data sent by will.jennings@predictit.org
## Detailed price history provided to academic researchers
DailyMarketData <- read_delim(
  file = here("data", "raw", "markets", "DailyMarketData.csv"),
  delim = "|",
  na = "n/a",
  col_types = cols(
    MarketId = col_character(),
    ContractName = col_character(),
    ContractSymbol = col_character(),
    Date = col_date(format = "")
  )
)

Market_ME02 <- read_csv(
  file = here("data", "raw", "markets", "Market_ME02.csv"),
  col_types = cols(
    ContractID = col_character(),
    Date = col_date(format = "%m/%d/%Y")
  )
)

Contract_NY27 <- read_csv(
  file = here("data", "raw", "markets", "Contract_NY27.csv"),
  na = c("n/a", "NA"),
  skip = 156, # this file was a mess
  col_types = cols(
    ContractID = col_character(),
    Date = col_date(format = "%m/%d/%Y")
  )
)

# save member data from https://theunitedstates.io/ -----------------------
# for every file, save raw and read parsed

## Current members of the 115th
## Archived: 2018-10-22 at 18:11
write_memento(
  url = "https://theunitedstates.io/congress-legislators/legislators-current.csv",
  date = "2018-10-22",
  dir = "members"
)

legislators_current <- read_csv(
  file = here("data", "raw", "members", "legislators-current.csv"),
  col_types = cols(
    birthday = col_date(),
    govtrack_id = col_character()
  )
)

# The ideology and leadership scores of the 115th
# Calculated with cosponsorship analysis
# Archived 2019-01-21 17:13:08
write_memento(
  url = "https://www.govtrack.us/data/analysis/by-congress/115/sponsorshipanalysis_h.txt",
  date = "2019-03-23",
  dir = "members"
)

sponsorshipanalysis_h <- read_csv(
  file = here("data", "raw", "members", "sponsorshipanalysis_h.txt"),
  col_types = cols(
    ID = col_character()
  )
)

write_memento(
  url = "https://www.govtrack.us/data/analysis/by-congress/115/sponsorshipanalysis_s.txt",
  date = "2019-03-23",
  dir = "members"
)

sponsorshipanalysis_s <- read_csv(
  file = here("data", "raw", "members", "sponsorshipanalysis_h.txt"),
  col_types = cols(
    ID = col_character()
  )
)

# read model and results data from https://fivethirtyeight.com ------------

## District level 538 House model history
## Updated:  2018-11-06 at 01:56
## Archived: 2018-11-06 at 12:06
write_memento(
  url = "https://projects.fivethirtyeight.com/congress-model-2018/house_district_forecast.csv",
  date = "2018-11-06",
  dir = "models"
)

house_district_forecast <- read_csv(
  file = here("data", "raw", "models", "house_district_forecast.csv"),
  col_types = cols(
    forecastdate = col_date(),
    state = col_character(),
    district = col_double(),
    special = col_logical(),
    candidate = col_character(),
    party = col_character(),
    incumbent = col_logical(),
    model = col_character(),
    win_probability = col_double(),
    voteshare = col_double(),
    p10_voteshare = col_double(),
    p90_voteshare = col_double()
  )
)

# Seat level 538 Senate model history
# Updated:  2018-11-06 at 11:06
# Archived: 2018-11-06 at 21:00
write_memento(
  url = "https://projects.fivethirtyeight.com/congress-model-2018/senate_seat_forecast.csv",
  date = "2018-11-06",
  dir = "models"
)

senate_seat_forecast <- read_csv(
  file = here("data", "raw", "models", "senate_seat_forecast.csv"),
  col_types = cols(
    forecastdate = col_date(),
    state = col_character(),
    class = col_double(),
    special = col_logical(),
    candidate = col_character(),
    party = col_character(),
    incumbent = col_logical(),
    model = col_character(),
    win_probability = col_double(),
    voteshare = col_double(),
    p10_voteshare = col_double(),
    p90_voteshare = col_double()
  )
)

# Midterm election results via ABC and 538
# Used in https://53eig.ht/2PiFb0f
# Published: 2018-12-04 at 17:56
# Archived:  2018-04-04 at 16:08

# Midterm election results via ABC and 538
# Used in https://53eig.ht/2PiFb0f
# Published: 2018-12-04 at 17:56
# Archived:  2018-04-04 at 16:08
github_538 <- "https://raw.githubusercontent.com/fivethirtyeight/data/master"
write_memento(
  url = paste(github_538, "forecast-review", "forecast_results_2018.csv", sep = "/"),
  date = "2019-04-04",
  dir = "results"
)

forecast_results <- read_csv(
  file = here::here("data", "raw", "results", "forecast_results_2018.csv"),
  col_types  = cols(
    Democrat_Won = col_logical(),
    Republican_Won = col_logical(),
    uncalled = col_logical(),
    forecastdate = col_date(format = "%m/%d/%y"),
    category = col_factor(
      ordered = TRUE,
      levels = c(
        "Solid D",
        "Likely D",
        "Lean D",
        "Tossup (Tilt D)",
        "Tossup (Tilt R)",
        "Lean R",
        "Likely R",
        "Safe R"
      )
    )
  )
)

# Average difference between how a district votes and the country
# Updated:  2018-11-19 at 16:13
# Archived: 2018-04-04 at 16:05
write_memento(
  url = paste(github_538, "partisan-lean", "fivethirtyeight_partisan_lean_DISTRICTS.csv", sep = "/"),
  date = "2019-04-04",
  dir = "results"
)

partisan_lean_DISTRICTS <- read_csv(
  file = here("data", "raw", "results", "fivethirtyeight_partisan_lean_DISTRICTS.csv"),
  col_types = cols(
    district = col_character(),
    pvi_538 = col_character()
  )
)

write_memento(
  url = paste(github_538, "partisan-lean", "fivethirtyeight_partisan_lean_STATES.csv", sep = "/"),
  date = "2019-04-04",
  dir = "results"
)

partisan_lean_STATES <- read_csv(
  file = here("data", "raw", "results", "fivethirtyeight_partisan_lean_STATES.csv"),
  col_types = cols(
    state = col_character(),
    pvi_538 = col_character()
  )
)

# Polls incorperated in the 538 models
# Archived 2019-01-29 at 21:45
poll_cols <- cols(
  question_id = col_character(),
  poll_id     = col_character(),
  pollster_id = col_character(),
  sponsor_ids = col_character(),
  start_date  = col_date("%m/%d/%y"),
  end_date    = col_date("%m/%d/%y"),
  created_at  = col_datetime("%m/%d/%y %H:%M")
)

write_memento(
  url = "https://projects.fivethirtyeight.com/polls-page/senate_polls.csv",
  date = "2019-01-29",
  dir = "polling"
)

senate_polls <- read_csv(
  file = here("data", "raw", "polling", "senate_polls.csv"),
  col_types = poll_cols
)

write_memento(
  url = "https://projects.fivethirtyeight.com/polls-page/house_polls.csv",
  date = "2019-01-29",
  dir = "polling"
)

house_polls <- read_csv(
  file = here("data", "raw", "polling", "house_polls.csv"),
  col_types = poll_cols
)

write_memento(
  url = "https://projects.fivethirtyeight.com/polls-page/generic_ballot_polls.csv",
  date = "2019-01-29",
  dir = "polling"
)

generic_ballot_polls <- read_csv(
  file = here("data", "raw", "polling", "generic_ballot_polls.csv"),
  col_types = poll_cols
)

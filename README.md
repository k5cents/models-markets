*predictr*
================

  - [Introduction](#introduction)
  - [Reproducibility](#reproducibility)
  - [Forecasting Models](#forecasting-models)
  - [Prediction Markets](#prediction-markets)
  - [Wrangling](#wrangling)
  - [Exploration](#exploration)
  - [Results](#results)

## Introduction

Election prediction helps party officials, campaign operatives, and
journalists interpret campaigns in a quantitative manner. Uncertainty is
key to a useful election prediction.

The forecast model has become a staple of political punditry in recent
years. Popularized by the data journalist at
[FiveThirtyEight](https://fivethirtyeight.com/), the forecasting model
is a statistical tool used to incorporate a number of quantitative
inputs and output a *probabilistic* view of all possible outcomes.

Prediction markets can be used as alternative method of generating
similarly probabilistic views of election outcomes. Markets utilize the
economic forces of price discovery and risk aversion to overcome the
ideological bias of self-interested traders on a binary options
exchange.

Can markets predict elections better than the models? If so, under what
conditions?

I propose a null hypothesis of no difference between the proportion of
accurate predictions made by forecasting models and prediction markets
in the 2018 congressional midterm elections.

## Reproducibility

All public input data has been saved on the [internet
archive](https://archive.org/) and can be accessed through their wayback
machine.

Data manipulation is done primarily using R packages from the
[`tidyverse`](https://github.com/tidyverse/) collection. Installing
those packages should contain all functions needed to run the project.

``` r
# devtools::install_cran("here")
# devtools::install_cran("tidyverse")
# devtools::install_cran("verification")
# devtools::install_github("hrbrmstr/wayback")
```

``` r
library(verification)
library(tidyverse)
library(lubridate)
library(magrittr)
library(wayback)
```

Package versions are maintained through
[`packrat`](https://rstudio.github.io/packrat/).

The R scripts in the [`/code`](/code) folder can be run in sequential
order to reproduce the results. There are four scripts:

1.  Read archived data with `wayback` and `readr`
2.  Wrangle and format with `dplyr` and `tidyr`
3.  Evaluate predictions with `stats` and `verification`
4.  Communicate results with `ggplot2` and `rmarkdown`

<!-- end list -->

``` r
source("code/01_read_inputs.R")
source("code/02_format_inputs.R")
source("code/03_compare_methods.R")
source("code/04_explore_visually.R")
```

## Forecasting Models

I will be using the FiveThirtyEight “classic” model to represent the
best capabilities of statistical election forecasting. FiveThirtyEight
has a track record of accuracy over the last decade.

[According to Nate
Silver](https://fivethirtyeight.com/features/how-the-fivethirtyeight-senate-forecast-model-works/),
the goal of these models is “not to divine some magic formula that
miraculously predicts every election. Instead, it’s to make sense of
publicly available information in a rigorous and disciplined way.”

To achieve this, [Silver
explains](https://fivethirtyeight.com/methodology/how-fivethirtyeights-house-and-senate-models-work/)
that most models “take lots of polls, perform various types of
adjustments to them, and then blend them with other kinds of empirically
useful indicators to forecast each race”. Most importantly, “they
account for the uncertainty in the forecast and simulate the election
thousands of times” to generate a probabilistic forecast.

The model incorporates three types of inputs:

1.  **Polling:** District level polling, adjusted by [pollster
    rating](https://projects.fivethirtyeight.com/pollster-ratings/)
2.  **CANTOR:** An algorithm to impute polling from districts without
    any
3.  **Fundamentals:** Historically useful non-polling factors:
      - Scandals
      - Incumbency
      - Fundraising
      - Partisanship
      - Generic ballot
      - Previous margin
      - Incumbent voting
      - Challenger office

From this, model calculates the most likely split of the vote in a race.
The probability distribution around this mean is calculated using proven
variables:

1.  Fewer polls
2.  Lopsided race
3.  Election further away
4.  More undecideds or third-party voters
5.  Polls disagree with other polls or fundamentals

The model is run with a Monte Carlo simulation. Simulated elections are
drawn from the race’s probability distribution. The percentage of
simulated elections won represents the probability of victory.

FiveThirtyEight published two files with top-level daily predictions:

1.  [`senate_seat_forecast.csv`](https://projects.fivethirtyeight.com/congress-model-2018/senate_seat_forecast.csv)
2.  [`house_district_forecast.csv`](https://projects.fivethirtyeight.com/congress-model-2018/house_district_forecast.csv)

These files contain over 100,000 rows, each a daily predictions from the
“classic” model with 11 variables:

1.  Date
2.  State
3.  District/Class
4.  Election type
5.  Candidate name
6.  Political party
7.  Model version
8.  **Probability of victory**
9.  Expected share of the vote
10. Minimum share
11. Maximum share

<!-- end list -->

``` r
"https://projects.fivethirtyeight.com/congress-model-2018/senate_seat_forecast.csv" %>%
  read_memento(timestamp = "2018-11-06", as = "raw") %>% 
  read_csv(col_types = "Dcdlcclcdddd")
```

| Date       | State | Party | Incumbent | Probability | Vote Share |
| :--------- | :---- | :---- | :-------- | ----------: | ---------: |
| 2018-11-05 | AZ    | D     | FALSE     |       0.613 |      49.83 |
| 2018-11-05 | AZ    | R     | FALSE     |       0.387 |      48.21 |
| 2018-11-05 | AZ    | G     | FALSE     |       0.000 |       1.96 |
| 2018-11-05 | CA    | D     | TRUE      |       0.956 |      57.59 |
| 2018-11-05 | CA    | D     | FALSE     |       0.044 |      42.41 |
| 2018-11-05 | CT    | D     | TRUE      |       0.997 |      59.76 |
| 2018-11-05 | CT    | R     | FALSE     |       0.003 |      38.45 |
| 2018-11-05 | CT    | NA    | FALSE     |       0.000 |       1.80 |

## Prediction Markets

Prediction markets generate probabilistic forecasts by crowd-sourcing
the collection of data from self-interested and risk averse traders.
[The efficient market
hypothesis](https://en.wikipedia.org/wiki/Efficient-market_hypothesis)
holds that asset prices reflect *all* available information (including
forecasting models). Markets have traders put their money where their
mouth is when predicting elections.

PredictIt is an exchange run by Victoria University of Wellington, New
Zealand. The site offers a continuous double-auction exchange, where
traders buy and sell shares of futures contracts tied to election
outcomes. As a trader’s perception of probabilities changes, they can
sell owned shares, causing the market equilibrium price to update
accordingly.

PredictIt provided the price history in the
[`data/DailyMarketData.csv`](data/DailyMarketData.csv) file.

1.  Market ID
2.  Market name
3.  Market symbol
4.  Contract name
5.  Contract symbol
6.  Prediction date
7.  Opening contract price
8.  Low contract price
9.  High contract price
10. **Closing contract price**
11. Volume of shares traded

<!-- end list -->

``` r
read_delim(file = "data/DailyMarketData.csv",
           col_types = "cccccDddddd",
           delim = "|", 
           na = "n/a")
```

| Market             | Contract      | Date       | Price | Volume |
| :----------------- | :------------ | :--------- | ----: | -----: |
| AKAL.2018          | DEM.AKAL.2018 | 2018-11-05 |  0.28 |    237 |
| AKAL.2018          | GOP.AKAL.2018 | 2018-11-05 |  0.72 |    553 |
| AZ02.2018          | DEM.AZ02.2018 | 2018-11-05 |  0.98 |    662 |
| AZ02.2018          | GOP.AZ02.2018 | 2018-11-05 |  0.05 |    787 |
| AZSEN18            | DEM.AZSEN18   | 2018-11-05 |  0.46 |  34137 |
| AZSEN18            | GOP.AZSEN18   | 2018-11-05 |  0.57 |  27913 |
| BACO.NE02.2018     | NA            | 2018-11-05 |  0.83 |    897 |
| BALD.WISENATE.2018 | NA            | 2018-11-05 |  0.93 |   6822 |

## Wrangling

The above data sets were both formatted to contain two key variables:
`date` and `race`. Together, these can be used to join the two data sets
for comparison.

Observations can then be gathered into a single
[tidy](http://vita.had.co.nz/papers/tidy-data.html) data frame, with
each observation representing one prediction (on one day, for one party,
from one source). Redundant complimentary predictions are then removed.

These predictions are compared against the election results to evaluate
the two methods.

``` r
inner_join(markets2, model2) %>%
  filter(date %>% between(17744, 17840)) %>%
  rename(model = prob, market = close) %>% 
  gather(model, market, key = method, value = prob) %>%
  inner_join(results) %>%
  mutate(hit = (prob > 0.50) == winner) %>% 
  mutate(score = (prob - winner)^2) 
```

| Date       | Race  | Method | Probability | Accurate |  Score |
| :--------- | :---- | :----- | ----------: | :------- | -----: |
| 2018-08-01 | AZ-S1 | market |      0.6600 | TRUE     | 0.1156 |
| 2018-08-01 | AZ-S1 | model  |      0.7380 | TRUE     | 0.0686 |
| 2018-08-01 | CA-12 | market |      0.9100 | TRUE     | 0.0081 |
| 2018-08-01 | CA-12 | model  |      1.0000 | TRUE     | 0.0000 |
| 2018-08-01 | CA-22 | market |      0.3000 | TRUE     | 0.0900 |
| 2018-08-01 | CA-22 | model  |      0.0493 | TRUE     | 0.0024 |
| 2018-08-01 | CA-25 | market |      0.6100 | TRUE     | 0.1521 |
| 2018-08-01 | CA-25 | model  |      0.7453 | TRUE     | 0.0649 |
| 2018-08-01 | CA-39 | market |      0.6100 | TRUE     | 0.1521 |
| 2018-08-01 | CA-39 | model  |      0.3768 | FALSE    | 0.3884 |

## Exploration

![probabiliy distrobutions](plots/plot_races_hist.png)

![races by cartesian points](plots/plot_cart_points.png)

![calibration plot](plots/plot_calibration_point.png)

## Results

There is a statistically significant difference between the proportion
of accurate predictions made by the markets vs. the model.

| Test statistic | df |      P value       | Alternative hypothesis |
| :------------: | :-: | :----------------: | :--------------------: |
|     16.79      | 1  | 4.166e-05 \* \* \* |       two.sided        |

2-sample test for equality of proportions with continuity correction:
`proportion` by `method` (continued below)

| market proportion | model proportion |
| :---------------: | :--------------: |
|      0.8603       |      0.8381      |

![accuracy by week](plots/plot_prop_week.png)

This is not the most useful test for predictive usefulness. The model is
generally more confident in both correct and incorrect predictions.
Reducing probabalistic forecasts to binary correct/incorrect based on
the 50% line removes all nuance.

![confidence by week](plots/plot_confidence.png)

[The Brier score](https://en.wikipedia.org/wiki/Brier_score) allows for
probablistic forecasts to be meaningfully tested with for mean squared
error. Using this test, there is no statistically significant difference
in the respective skill scores of each predictive method.

| Test statistic |  df   | P value | Alternative hypothesis |
| :------------: | :---: | :-----: | :--------------------: |
|    \-0.339     | 16943 | 0.7346  |       two.sided        |

Welch Two Sample t-test: `score` by `method` (continued below)

| mean in group market | mean in group model |
| :------------------: | :-----------------: |
|        0.1084        |       0.1091        |

![score by week](plots/plot_brier_week.png)

*predictr*
================

  - [Overview](#overview)
  - [Reproduce](#reproduce)
      - [Docker and Packrat](#docker-and-packrat)
  - [Forecasting Models](#forecasting-models)
      - [Model Inputs](#model-inputs)
      - [Model Output](#model-output)
  - [Prediction Markets](#prediction-markets)
      - [Market Inputs](#market-inputs)
      - [Market Output](#market-output)
  - [Wrangling](#wrangling)
  - [Exploration](#exploration)
  - [Findings](#findings)

## Overview

The forecast model has become a staple of political punditry.
Popularized by the data journalism site
[FiveThirtyEight](https://fivethirtyeight.com/), the forecast model is a
statistical tool used to incorporate a number of quantitative inputs and
output a *probabilistic* view of all possible outcomes.

Prediction markets can be used as alternative method of generating
similarly probabilistic views of election outcomes. Markets utilize the
economic forces of price discovery and risk aversion to overcome the
implicit bias of self-interested traders on a binary options exchange.

How do these two predictive methods fare in their ability to prediction
elections? I propose a null hypothesis of no difference between the
proportion of accurate predictions made by forecasting models and
prediction markets in the 2018 congressional midterm elections.

For model data, the public data from the proprietary model written by
the data journalists at FiveThirtyEight. For market data, Victoria
University of Wellington, New Zealand provided the detailed price
history on their [PredictIt exchange](https://www.predictit.org/).

![data logos](plots/predictr.png)

## Reproduce

All public input data has been archived on the [internet
archive](https://archive.org/) and can be accessed through their wayback
machine.

Data reading, wrangling, combining, and visualizing is done primarily
using `R` packages from the [`tidyverse`](https://github.com/tidyverse/)
collection. The following packages should allow you to run the project
from start to finish:

``` r
library(tidyverse) # for data
library(lubridate) # for dates
library(magrittr)  # for pipes
```

The `R` scripts in the [`/code`](/code) folder can be run in sequantial
order to reproduce the project findings.

1.  Scrape archived data with the `readr` package and
    [`01_read_inputs.R`](code/01_read_inputs.R)
2.  Format data with the `dplyr` package and
    [`02_format_inputs.R`](code/02_format_inputs.R)
3.  Compare predictive methods with the `tidyr` package and
    [`03_compare_methods.R`](code/03_compare_methods.R)
4.  Create visualizations with the `ggplot2` package and
    [`04_explore_viz.R`](code/04_explore_viz.R)
5.  Run statistical tests with the `stats` package and
    [`05_analyze_stat.R`](code/05_analyze_stat.R)

### Docker and Packrat

*todo*

## Forecasting Models

As Nate Silver, FiveThirtyEight’s founder and the primary author of
their model, explains in their [methedological
article](https://fivethirtyeight.com/methodology/how-fivethirtyeights-house-and-senate-models-work/):

> (Forecasting models) take lots of polls, perform various types of
> adjustments to them, and then blend them with other kinds of
> empirically useful indicators (what we sometimes call “the
> fundamentals”) to forecast each race. Then they account for the
> uncertainty in the forecast and simulate the election thousands of
> times.

I will be using the FiveThirtyEight model data to represent the best
capabilities of statistical election forecasting. FiveThirtyEight has a
track record of accuracy over the last decade, including the 2016
Presidential election, where they gave President Trump a 30% chance of
winning (compared to 1% from some competitors). Furthermore, they make
the top-line output of their model free to the public.

The goal of these mathematical forecasting models, [according to
Silver](https://fivethirtyeight.com/features/how-the-fivethirtyeight-senate-forecast-model-works/),
is “not to divine some magic formula that miraculously predicts every
election. Instead, it’s to make sense of publicly available information
in a rigorous and disciplined way.”

### Model Inputs

FiveThirtyEight’s 2018 House and Senate models incorporate four types of
quantitative data:

1.  **Polling:** District level polling. [FiveThirtyEight rates
    pollsters](https://projects.fivethirtyeight.com/pollster-ratings/)
    to adjust their findings. The results are further adjusted three
    times:
    1.  The likely voter adjustment ensures a more accurate sampling
        frame.
    2.  The conservative timeline adjustment to favor recency.
    3.  The house effects adjustment corrects for persistent statistical
        biases.
2.  **CANTOR:** A proprietary k-nearest neighbors algorithm to identify
    similar congressional districts (based on demographic, geographic
    and political factors) to infers results for polling-sparce
    districts.
3.  **Fundamentals:** Non-polling factors that historically help in
    predicting congressional races:
      - Incumbency
      - Partisanship
      - Previous margin
      - Generic ballot
      - Fundraising
      - Incumbent voting
      - Challenger experience
      - [Scandals](https://docs.google.com/spreadsheets/d/1ksBLxRR3GCZd33IvhkcNqqBd5K8HwlWC7YuAkVmS1lg/)
4.  **Expert forecasts:** Ratings published by the historically accurate
    experts at the [Cook Political Report](https://cookpolitical.com/),
    [Inside Elections](https://insideelections.com/), and [Sabato’s
    Crystal Ball](http://www.centerforpolitics.org/crystalball/).

FiveThirtyEight uses these inputs to generate three models. The “Lite”
model only uses polling and CANTOR; “Classic” adds in the fundamental
data; and “Deluxe” further incorporates the less quantitative expert
forecasts.

In [describing](http://53eig.ht/1u2pSbD) the process of their 2014
Senate Model, Silver described the general process by which the above
inputs are incorporated in producing a probabilistic output:

> Most election models (including \[FiveThirtyEight’s\]) work in
> something like the following way: First, they calculate the most
> likely outcome in a particular state (“The Republican wins by 1
> point”) and then they determine the degree of uncertainty around
> that estimate. Most models do this by means of a normal distribution
> or something similar to it.

In an analysis of past elections, it has been proven that the degree of
uncertainty is *greater* when:

1.  The election is further away
2.  There are fewer polls
3.  The polls disagree more with one another
4.  The polling average disagrees more with the state fundamentals
5.  There are more undecideds or third-party voters in the polls
6.  The race is more lopsided

With these quantitative factors in mind, the model calculates the
probability distribution in each candidate’s share of the vote.

The model then runs uses these predicted shares to run a Monte Carlo
simulation. In each iteration of the simulation, a share of the vote for
each candidate in a race is drawn from the above probability
distributions. A winner is determined and the simulation runs again. The
percentage of simulated elections won is analogous to the probability of
victory on election day.

### Model Output

The team at FiveThirtyEight makes public a portion of their model’s
output as four separate `.csv` files on their website:

1.  [`/congress-model-2018/senate_national_forecast.csv`](https://projects.fivethirtyeight.com/congress-model-2018/senate_national_forecast.csv)
2.  [`/congress-model-2018/house_national_forecast.csv`](https://projects.fivethirtyeight.com/congress-model-2018/house_national_forecast.csv)
3.  [`/congress-model-2018/senate_seat_forecast.csv`](https://projects.fivethirtyeight.com/congress-model-2018/senate_seat_forecast.csv)
4.  [`/congress-model-2018/house_district_forecast.csv`](https://projects.fivethirtyeight.com/congress-model-2018/house_district_forecast.csv)

The two national forecasts provide the FiveThirtyEight calculations for
each party’s probability of winning a majority in their respective
chambers on any given day (e.g., “Today, he Democratic party has an 85%
chance of winning control of the House of Representatives with a simple
majority of seats”).

The Senate seat and House district level forecasts will be used in this
project. Each observation represents one day’s probability of victory
for one candidate. There are 28353 observations in the Senate seat level
file and 299760 for the House district level. Both data sets can be
easily combined; together, there are an average of 3348 unique daily
predictions from 2018-08-01 to 2018-11-06.

For each observation, there are 12 variables recorded:

1.  Date
2.  State
3.  District or Senate class
4.  Election type (regular or special)
5.  Candidate
6.  Political party
7.  Model version
8.  **Probability of victory**
9.  Expected share of the vote
10. Minimum share of the vote
11. Maximum share of the vote

Below is a random sample of observations from the combined House
district and Senate seat congressional model data sets.

| Date       | State | District | Candidate     | Party | Incumbent | Model   | Probability | Vote Share |
| :--------- | :---- | -------: | :------------ | :---- | :-------- | :------ | ----------: | ---------: |
| 2018-08-08 | NY    |        3 | Thomas Suozzi | D     | TRUE      | classic |       0.992 |      60.98 |
| 2018-08-10 | NY    |       17 | Nita Lowey    | D     | TRUE      | classic |       0.999 |      80.78 |
| 2018-08-15 | MD    |        2 | Others        | NA    | FALSE     | classic |       0.000 |       3.54 |
| 2018-08-21 | MI    |       10 | Paul Mitchell | R     | TRUE      | classic |       0.998 |      62.17 |
| 2018-09-07 | MD    |        4 | Anthony Brown | D     | TRUE      | deluxe  |       1.000 |      77.76 |

## Prediction Markets

As summarized [on
Wikipedia](https://en.wikipedia.org/wiki/Prediction_market):

> Prediction markets are exchange-traded markets created for the purpose
> of trading the outcome of events. The market prices can indicate what
> the crowd thinks the probability of the event is. A prediction market
> contract trades between 0 and 100%… The main purposes of prediction
> markets are eliciting aggregating beliefs over an unknown future
> outcome. Traders with different beliefs trade on contracts whose
> payoffs are related to the unknown future outcome and the market
> prices of the contracts are considered as the aggregated belief.

I will be using the market history of the PredictIt exchange run by
Victoria University of Wellington, New Zealand. PredictIt is one of the
few prediction markets permitted to operate domestically due to the
academic value of the markets. PredictIt partners with academic
researchers to provide market history free of charge.

### Market Inputs

The fundamental input to a prediction market is a bet between two
traders. These bets are made in the form of binary futures contracts
that execute for a fixed price based on the outcome of some future
event. Contracts tied to a correct prediction pay out, paid for by the
incorrect contract. PredictIt runs a continuous double-auction exchange
where traders buy and sell shares of futures contracts.

Traders on PredictIt place bets using real money, ensuring the proper
incentives for traders to overcome bias and make bets in line with their
individual estimates of probability and their level of risk aversion.
The greater the volume of money traded on a market, the better forces of
price discovery can determine equilibrium. Betting on elections is
illegal, but PredictIt and a handful of other markets are allowed to
operate under a letter of No-Action by the Commodity Futures Trading
Commission. The CFTC did cap the maximum bet to $850, potentially
hindering true price discovery.

### Market Output

Each Congressional race is predicted with it’s own market, where traders
buy and sell shares of the opposing outcomes. Instead of producing a
single prediction every day, the market equilibrium price is continually
adjusting to take into account the views of the traders. The history of
this price is provided to researchers. As [PredictIt
outlines](https://www.predictit.org/research) in their data agreement:

> In order to take full advantage of the research opportunities
> presented by prediction markets like PredictIt, we make our data
> available to members of the academic community at no cost. PredictIt’s
> market data offers researchers a wealth of information that can be
> used to further our understanding of a wide array of subjects in
> fields of study as diverse as microeconomics, political behavior,
> computer science and game theory.

I scraped [the PredictIt
API](https://www.predictit.org/api/marketdata/all/) before the election
and used the data to find all market ID’s related to 2018 Congressional
elections. PredictIt then provided the relevant market data as a single
`.csv` file.

Each observation represents one day’s opening, closing, low, and high
price for a single contract from a single market. There are 44,711
observations covering 145 contracts across 118 markets. For each
observation there are 11 variables:

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

Below is a random sample of observations from the PredictIt trading
markets.

| ID   | Market         | Contract      | Date       | Open |  Low | High | Close | Volume |
| :--- | :------------- | :------------ | :--------- | ---: | ---: | ---: | ----: | -----: |
| 3520 | KNIG.CA25.2018 | NA            | 2017-09-25 | 0.39 | 0.39 | 0.39 |  0.39 |      0 |
| 3772 | TNSEN18        | GOP.TNSEN18   | 2017-12-04 | 0.79 | 0.79 | 0.83 |  0.83 |    111 |
| 3739 | MI11.2018      | DEM.MI11.2018 | 2018-03-05 | 0.64 | 0.64 | 0.64 |  0.64 |      1 |
| 4039 | CA49.2018      | GOP.CA49.2018 | 2018-03-07 | 0.25 | 0.25 | 0.25 |  0.25 |      0 |
| 4447 | NV04.2018      | GOP.NV04.2018 | 2018-09-30 | 0.10 | 0.10 | 0.20 |  0.20 |      1 |

## Wrangling

The above data sets were both formatted to contain two key variables:
`date` and `race`. Together, these variables create a relational key
that can be used to join the two data sets for comparison.

For model data, the new `race` variable is created by combining the old
`state` and `district` variables. For market data, the new `race` code
is extracted from the old `MarketSymbol`.

Observations can then be gathered to make the single combined data frame
[tidy](http://vita.had.co.nz/papers/tidy-data.html), with each
observation representing *one* prediction (on one date, for one party,
from one predictive method).

Redundant complimentary predictions are removed by selecting only
democratic party probabilities. For markets comprised of yes/no
contracts on a single Republican incumbent’s re-election probability,
the price can be inverted.

Below is the data frame of historical predictions along with the
election results. There are 17694 observations of 4 variables:

1.  Prediction date
2.  Election code
3.  Predictive method
4.  **Win probability**

<!-- end list -->

``` r
inner_join(x    = markets2, 
           y    = model2, 
           by   = c("date", "race")) %>%
  filter(date   > "2018-07-31",
         date   < "2018-11-06") %>%
  rename(model  = prob,
         market = close) %>% 
  gather(key    = method,
         value  = prob,
         model, market) %>%
  arrange(date, race, method)
```

| Date       | Race  | Method | Probability |
| :--------- | :---- | :----- | ----------: |
| 2018-08-01 | AZ-S1 | market |      0.6600 |
| 2018-08-01 | AZ-S1 | model  |      0.7380 |
| 2018-08-01 | CA-12 | market |      0.9100 |
| 2018-08-01 | CA-12 | model  |      1.0000 |
| 2018-08-01 | CA-22 | market |      0.3000 |
| 2018-08-01 | CA-22 | model  |      0.0493 |
| 2018-08-01 | CA-25 | market |      0.6100 |
| 2018-08-01 | CA-25 | model  |      0.7453 |
| 2018-08-01 | CA-39 | market |      0.6100 |
| 2018-08-01 | CA-39 | model  |      0.3768 |

## Exploration

![probabiliy](plots/plot_races_hist.png)

![cumulative markets](plots/plot_cum_markets.png)

![cumulative polls](plots/plot_cum_polls.png)

![cumulative dollars](plots/plot_cum_dollars.png)

![races by cartesian points](plots/plot_cart_points.png)

![accuracy by day](plots/plot_prop_day.png)

![accuracy by month](plots/plot_prop_month.png)

## Findings

*todo*

Models and Markets
================

  - [Reproduce](#reproduce)
  - [Data](#data)
  - [Compare](#compare)

Election prediction helps party officials, campaign operatives, and
journalists interpret campaigns in a quantitative manner. Uncertainty is
key to a useful election prediction.

The forecast model has become a staple of political punditry.
Popularized by the data journalist at
[FiveThirtyEight](https://fivethirtyeight.com/), the forecasting model
is a statistical tool used to incorporate a number of quantitative
inputs and produce a *probabilistic* view of all possible outcomes.

Prediction markets can be used to generate similarly probabilistic views
of election outcomes by utilizing the economic forces of price discovery
and risk aversion to overcome the ideological bias of self-interested
traders on a binary options exchange.

**Can markets predict elections better than the models?** If so, under
what conditions? I propose a null hypothesis of no difference in the
mean [Brier score](https://en.wikipedia.org/wiki/Brier_score) of
forecasting models and prediction markets for the 2018 U.S.
Congressional midterm elections.

## Reproduce

All public input data has been saved on the [internet
archive](https://archive.org/) and can be accessed through their wayback
machine.

Data manipulation is done using the R language and packages from the
[`tidyverse`](https://github.com/tidyverse/) ecosystem.

The R scripts in the [`/code`](/code) directory can be run in sequential
order to reproduce the results. There are four scripts to perform four
steps:

1.  Read archived data with `wayback` and `readr`
2.  Wrangle and format with `dplyr` and `tidyr`
3.  Evaluate predictions with `stats` and `verification`
4.  Communicate results with `ggplot2` and `rmarkdown`

## Data

### Forecasting Models

I will be using the FiveThirtyEight “classic” model to represent the
best capabilities of statistical election forecasting. FiveThirtyEight
has a track record of accuracy over the last decade.

[According to Nate
Silver](https://fivethirtyeight.com/features/how-the-fivethirtyeight-senate-forecast-model-works/):

> \[The model’s\] goal is not to divine some magic formula that
> miraculously predicts every election. Instead, it’s to make sense of
> publicly available information in a rigorous and disciplined way.

To achieve this, [Silver
explains](https://fivethirtyeight.com/methodology/how-fivethirtyeights-house-and-senate-models-work/)
that most forecasting models (1) “take lots of polls, perform various
types of adjustments to them, and then blend them with other kinds of
empirically useful indicators to forecast each race”. Importantly, they
(2) “account for the uncertainty in the forecast and simulate the
election thousands of times” to generate a probabilistic forecast.

The model incorporates three types of inputs:

1.  **Polling:** District level polling, adjusted by [pollster
    rating](https://projects.fivethirtyeight.com/pollster-ratings/).
2.  **CANTOR:** polling imputation for districts without any.
3.  **Fundamentals:** Historically useful non-polling factors:
      - Challenger office
      - Incumbent voting
      - Previous margin
      - Generic ballot
      - Partisanship
      - Fundraising
      - Incumbency
      - Scandals

From this data, the model calculates (1) the most likely split of the
vote in a race, and (2) the probability distribution around this mean
given proven variables of uncertainty.

FiveThirtyEight publishes two files with top-level daily predictions:

1.  [`senate_seat_forecast.csv`](https://projects.fivethirtyeight.com/congress-model-2018/senate_seat_forecast.csv)
2.  [`house_district_forecast.csv`](https://projects.fivethirtyeight.com/congress-model-2018/house_district_forecast.csv)

Together, there are 110,404 daily “classic” model prediction, from 470
races, with 13 variables:

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

| forecastdate | state | district | party | share |   prob |
| :----------- | :---- | -------: | :---- | ----: | -----: |
| 2018-08-23   | FL    |        7 | R     | 41.23 | 0.0197 |
| 2018-09-24   | PA    |        7 | R     | 42.90 | 0.0631 |
| 2018-10-03   | CA    |       28 | D     | 81.15 | 1.0000 |
| 2018-10-26   | OR    |        3 | D     | 83.36 | 1.0000 |
| 2018-09-08   | IL    |        4 | D     | 85.09 | 1.0000 |
| 2018-09-13   | NY    |       25 | D     | 63.22 | 0.9995 |
| 2018-11-02   | TX    |       22 | R     | 51.64 | 0.8045 |
| 2018-10-09   | IN    |        2 | R     | 56.63 | 0.9481 |
| 2018-09-26   | IA    |        1 | R     | 41.71 | 0.0284 |
| 2018-08-18   | NY    |        2 | D     | 44.65 | 0.1700 |

### Prediction Markets

Prediction markets generate probabilistic forecasts by crowd-sourcing
the collection of data from self-interested and risk averse traders.
\[The efficient market hypothesis\]\[efm\] holds that asset prices
reflect *all* available information (including forecasting models).

[PredictIt](https://www.predictit.org/) is an exchange run by [Victoria
University](https://www.victoria.ac.nz/) of Wellington, New Zealand. The
site offers a continuous double-auction exchange, where traders buy and
sell shares of futures contracts tied to election outcomes. As a
trader’s perception of probabilities changes, they can sell owned
shares. The market equilibrium price then updates to reflect current
probability.

PredictIt provided the price history in
[`data/raw/DailyMarketData.csv`](data/raw/DailyMarketData.csv).
Together, there are 44,711 daily market prices, from 118 races, with 11
variables:

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

| Date       | MarketSymbol          | ClosePrice | Volume |
| :--------- | :-------------------- | ---------: | -----: |
| 2018-03-01 | NY19.2018             |       0.60 |      2 |
| 2017-08-23 | PELO.CA12.2018        |       0.87 |      0 |
| 2017-05-16 | MANCHIN.WVSENATE.2018 |       0.69 |      0 |
| 2018-09-19 | NY19.2018             |       0.41 |      0 |
| 2018-05-09 | WI01.2018             |       0.56 |      0 |
| 2017-12-12 | PARTY.MNSEN.18        |       0.80 |    510 |
| 2018-06-18 | PA15.2018             |       0.90 |      2 |
| 2018-06-25 | CASE.PASENATE.2018    |       0.84 |      0 |
| 2018-04-24 | MI08.2018             |       0.44 |      0 |
| 2017-12-11 | RYAN.WI01.2018        |       0.77 |    443 |

## Compare

The FiveThirtyEight model and PredictIt markets data sets were joined
using the date and unique election code. The data was then pivoted to a
long format, which allows us to compare each method against the ultimate
binary results of the race.

| date       | race  | method |  prob | pred  | winner | hit   | brier |
| :--------- | :---- | :----- | ----: | :---- | :----- | :---- | ----: |
| 2018-08-01 | AZ-S1 | market | 0.660 | TRUE  | TRUE   | TRUE  | 0.116 |
| 2018-08-01 | AZ-S1 | model  | 0.738 | TRUE  | TRUE   | TRUE  | 0.069 |
| 2018-08-01 | CA-12 | market | 0.910 | TRUE  | TRUE   | TRUE  | 0.008 |
| 2018-08-01 | CA-12 | model  | 1.000 | TRUE  | TRUE   | TRUE  | 0.000 |
| 2018-08-01 | CA-22 | market | 0.300 | FALSE | FALSE  | TRUE  | 0.090 |
| 2018-08-01 | CA-22 | model  | 0.049 | FALSE | FALSE  | TRUE  | 0.002 |
| 2018-08-01 | CA-25 | market | 0.610 | TRUE  | TRUE   | TRUE  | 0.152 |
| 2018-08-01 | CA-25 | model  | 0.745 | TRUE  | TRUE   | TRUE  | 0.065 |
| 2018-08-01 | CA-39 | market | 0.610 | TRUE  | TRUE   | TRUE  | 0.152 |
| 2018-08-01 | CA-39 | model  | 0.377 | FALSE | TRUE   | FALSE | 0.388 |

Here we can see how each each race was predicted by each method
highlighted by the race results.

![](plots/plot_cartesian.png)<!-- -->

A probabalistic prediction should find that events with a 60%
probability occur 60% of the time. Here we see how many of each method’s
predictions occured that frequently. Predictions with a 60% probability
that occured 85% of the time are underconfident.

![](plots/plot_calibration.png)<!-- -->

[The Brier score](https://en.wikipedia.org/wiki/Brier_score) allows for
probablistic forecasts to be meaningfully tested with mean squared
error. Using this test, there is no statistically significant difference
in the respective skill scores of each predictive method.

| Test statistic |  df   |    P value     | Alternative hypothesis |
| :------------: | :---: | :------------: | :--------------------: |
|      3.14      | 13749 | 0.001691 \* \* |       two.sided        |

Welch Two Sample t-test: `brier` by `method` (continued below)

| mean in group market | mean in group model |
| :------------------: | :-----------------: |
|        0.1172        |       0.1095        |

![](plots/plot_brier.png)<!-- -->

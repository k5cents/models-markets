Models and Markets
================

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

**Can markets predict elections better than the models?** I propose a
null hypothesis of no difference in the mean [Brier
score](https://en.wikipedia.org/wiki/Brier_score) of forecasting models
and prediction markets for competitive races in the 2018 U.S.
Congressional midterm elections.

## Reproduce

All public input data has been saved on the [internet
archive](https://archive.org/) and can be accessed through their wayback
machine.

Data manipulation is done using the R language and packages from the
[tidyverse](https://github.com/tidyverse/) ecosystem.

The R scripts in the [`/code`](/code) directory can be run in sequential
order to reproduce the results.

## Data

### Forecasting Models

I will be using the FiveThirtyEight “classic” model to represent the
best capabilities of statistical election forecasting. FiveThirtyEight
has a track record of accuracy over the last decade.

As [Nate Silver
explains](https://fivethirtyeight.com/methodology/how-fivethirtyeights-house-and-senate-models-work/),
most forecasting models (1) “take lots of polls, perform various types
of adjustments to them, and then blend them with other kinds of
empirically useful indicators to forecast each race”. Importantly, they
(2) “account for the uncertainty in the forecast and simulate the
election thousands of times” to generate a probabilistic forecast.

The classic model incorporates three types of inputs, primarily direct
and imputed polling as well as fundamentals factors like incumbency and
the generic ballot.

FiveThirtyEight publishes two files with daily top-level predictions:

1.  [`senate_seat_forecast.csv`](https://projects.fivethirtyeight.com/congress-model-2018/senate_seat_forecast.csv)
2.  [`house_district_forecast.csv`](https://projects.fivethirtyeight.com/congress-model-2018/house_district_forecast.csv)

Together, there are 110,404 daily “classic” model prediction from 470
races with 13 variables.

### Prediction Markets

Prediction markets generate probabilistic forecasts by crowd-sourcing
the collection of data from self-interested and risk averse traders.
[The efficient market
hypothesis](https://en.wikipedia.org/wiki/Efficient-market_hypothesis)
holds that asset prices reflect *all* available information (including
forecasting models).

[PredictIt](https://www.predictit.org/) is an exchange run by [Victoria
University](https://www.victoria.ac.nz/) of Wellington, New Zealand. The
site offers a continuous double-auction exchange, where traders buy and
sell shares of futures contracts tied to election outcomes. As a
trader’s perception of probabilities changes, they can sell those
shares. The market equilibrium price updates accordingly to reflect
current probability. As outcomes become more likely, prices rise as
demand for shares increases.

PredictIt provided the price history in
[`DailyMarketData.csv`](data/raw/DailyMarketData.csv). Together, there
are 44,711 daily market prices from 118 races with 11 variables.

## Compare

The FiveThirtyEight model and PredictIt markets data sets were joined
using the date and a unique race code. The data was then pivoted to a
long format, which allows us to compare each method against the ultimate
binary results of the race.

| Date       | Race  | Method | Probability | Dem. Favorite? | Won?  | Correct? | Brier score |
| :--------- | :---- | :----- | ----------: | :------------: | :---: | :------: | ----------: |
| 2018-08-01 | AZ-S1 | market |       0.660 |      TRUE      | TRUE  |   TRUE   |       0.116 |
| 2018-08-01 | AZ-S1 | model  |       0.738 |      TRUE      | TRUE  |   TRUE   |       0.069 |
| 2018-08-01 | CA-12 | market |       0.910 |      TRUE      | TRUE  |   TRUE   |       0.008 |
| 2018-08-01 | CA-12 | model  |       1.000 |      TRUE      | TRUE  |   TRUE   |       0.000 |
| 2018-08-01 | CA-22 | market |       0.300 |     FALSE      | FALSE |   TRUE   |       0.090 |
| 2018-08-01 | CA-22 | model  |       0.049 |     FALSE      | FALSE |   TRUE   |       0.002 |
| 2018-08-01 | CA-25 | market |       0.610 |      TRUE      | TRUE  |   TRUE   |       0.152 |
| 2018-08-01 | CA-25 | model  |       0.745 |      TRUE      | TRUE  |   TRUE   |       0.065 |
| 2018-08-01 | CA-39 | market |       0.610 |      TRUE      | TRUE  |   TRUE   |       0.152 |
| 2018-08-01 | CA-39 | model  |       0.377 |     FALSE      | TRUE  |  FALSE   |       0.388 |

Here we can see how each each race was predicted by each method,
highlighted by the race results.

<img src="plots/plot_cartesian.png" width="922" />

A probabilistic prediction should find that events with a 60%
probability occur 60% of the time. Here we see how many of each method’s
predictions occurred that frequently. Predictions with a 60% probability
that occurred 85% of the time are underconfident and vice versa.

<img src="plots/plot_calibration.png" width="922" />

[The Brier score](https://en.wikipedia.org/wiki/Brier_score) allows for
probabilistic forecasts to be meaningfully tested with mean squared
error. The Brier score rewards skillful predictions, with a 100%
probability earning a score of zero if correct. Using this test, there
is no statistically significant difference in the respective skill
scores of each predictive method.

| Test statistic |  df   | P value | Alternative hypothesis |
| :------------: | :---: | :-----: | :--------------------: |
|     \-0.34     | 16942 | 0.7338  |       two.sided        |

Welch Two Sample t-test: `brier` by `method` (continued below)

| mean in group market | mean in group model |
| :------------------: | :-----------------: |
|        0.1084        |       0.1091        |

<img src="plots/plot_brier.png" width="922" />

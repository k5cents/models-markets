*predictr*
==========

Using R to compare the predictive capabilities of markets and models.

  * [Project Background](#project-background)
  * [Predictive Methods](#predictive-methods)
    + [Polling and Aggrigation](#polling-and-aggrigation)
    + [Forecasting Models](#forecasting-models)
    + [Prediction Markets](#prediction-markets)
  * [Prediction Data](#prediction-data)
    + [FiveThirtyEight Model](#fivethirtyeight-model)
    + [PredictIt Markets](#predictit-markets)
  * [Data Wrangling](#data-wrangling)
  * [Data Exploration](#data-exploration)
  * [Project Findings](#project-findings)
  * [Conclusion](#conclusion)
  * [Biblography](#biblography)

Project Background
------------------

The forecast model has become a staple of political punditry.
Popularized by the data journalism site
[FiveThirtyEight](https://fivethirtyeight.com/ "538 home page"), the
forecast model is a statistical tool used to incorporate a number of
quantitative inputs and output a probabilistic view of all possible
outcomes.

On the eve of the 2016 Presidential election, all mainstream forecasts
gave Hillary Clinton significant odds to win the presidency.
FiveThirtyEight's forecast model gave Clinton the lowest odds [at
71%](https://goo.gl/CLPrUC "538 2016"). Meanwhile, The New York Times
Upshot calculated [85%](https://goo.gl/QES9vJ "NYT Upshot 2016") and the
HuffPo Pollster's published an infamous [98% chance of a Clinton
victory](https://goo.gl/XJqwyD "HuffPo 2016").

Is there a better alternative to forecasting models?

Markets can be used to ascertain a probabilistic prediction of election
results. Instead of a incorporating quantitative inputs, a market has
self-interested traders bet on the outcomes to determine the likelihood
of each.

This project compares the accuracy of markets and models in their
ability to predict the winner of 2018 midterm congressional elections.

Predictive Methods
------------------

### Polling and Aggrigation

Opinion polling is the most common form of election predicting. By
[randomly
sampling](https://en.wikipedia.org/wiki/Sampling_(statistics) "Sandom sampling wiki")
the overall population of potential voters, pollsters can ask a thousand
Americans their voting intentions and determine the likely division of
votes in the actual election. Sampling errors and systemic errors
prevent this statistical tool from perfectly predicting the election. By
aggregating a bunch of polls and averaging their results, sites like
[RealClearPolitics](https://www.realclearpolitics.com/ "RCP home page")
take advantage of the [law of large
numbers](https://en.wikipedia.org/wiki/Law_of_large_numbers "Law large nums wiki")
to better calculate the true opinion of the population.

### Forecasting Models

In [the
word's](https://fivethirtyeight.com/methodology/how-fivethirtyeights-house-and-senate-models-work/ "538 model how")
of Nate Silver, FiveThirty's founder and primary author of their model:

> (Forecasting models) take lots of polls, perform various types of
> adjustments to them, and then blend them with other kinds of
> empirically useful indicators (what we sometimes call “the
> fundamentals”) to forecast each race. Then they account for the
> uncertainty in the forecast and simulate the election thousands of
> times.

I will be using the FiveThirtyEight model to collect forecasting data.
In 2016, FiveThirtyEight's prediction was closest to reality. They are
one of the few mainstream forecasters to continue their work into the
2018 midterm elections.

The exact process of the FiveThirtyEight is proprietary, so we can't
know exactly what data is being incorporated in what ways. In the
"classic" version of their model, three types of quantitative data are
used:

1.  **Polling**: District-by-district polling, adjusted for house
    effects and other factors in some unknownn way. [FiveThirtyEight
    rates
    pollsters](https://projects.fivethirtyeight.com/pollster-ratings/ "538 poll ratings")
    to adjust their findings.
2.  **C.A.N.T.O.R.**: A proprietary system which infers results for
    districts with little or no polling from similar districts where
    polling has been done.
3.  **Fundamentals**: Non-polling factors that historically help in
    predicting congressional races:
    -   Incumbency
    -   State partisanship
    -   Incumbent previous margins
    -   Generic ballot
    -   Fundraising
    -   Incumbent voting record
    -   Challenger experience
    -   Scandals

From everything that has been said publicly about the mathematics of
their model, FiveThirtyEight uses these quantitative inputs to predict
each candidate's share of the vote. The model is then uses the
statistical program Stata to run a [Monte Carlo
simulation](https://en.wikipedia.org/wiki/Monte_Carlo_method "Monte carlo sim wiki").
By predicting the lower limit, upper limit, central tendency, and
distribution of shares of the vote for two candidates, you can simulate
a given election 20,000 times and simply use the percentage of victories
as the probability of actual victory.

In the training data (most House races since 1998), the classic model
correctly predicted *96.7%* of races at the time of election.
FiveThirtyEight points out that the *vast* majority of races are
blowouts, inflating this accuracy percentage.

### Prediction Markets

As summarized [on
Wikipedia](https://en.wikipedia.org/wiki/Prediction_market "Prediction markets wiki"):

> Prediction markets (also known as predictive markets, information
> markets, decision markets, idea futures, event derivatives, or virtual
> markets) are exchange-traded markets created for the purpose of
> trading the outcome of events. The market prices can indicate what the
> crowd thinks the probability of the event is. A prediction market
> contract trades between 0 and 100%... The main purposes of prediction
> markets are eliciting aggregating beliefs over an unknown future
> outcome. Traders with different beliefs trade on contracts whose
> payoffs are related to the unknown future outcome and the market
> prices of the contracts are considered as the aggregated belief.

Prediction Data
---------------

### FiveThirtyEight Model

The team at FiveThirtyEight made public a portion of their model's
output as four separate `.csv` files on their website:

1.  [Senate national
    forecast](https://projects.fivethirtyeight.com/congress-model-2018/senate_national_forecast.csv "Sen nat model")
2.  [Senate seat
    forecast](https://projects.fivethirtyeight.com/congress-model-2018/senate_seat_forecast.csv "Sen seat model")
3.  [House national
    forecast](https://projects.fivethirtyeight.com/congress-model-2018/house_national_forecast.csv "House nat model")
4.  [House district
    forecasts](https://projects.fivethirtyeight.com/congress-model-2018/house_district_forecast.csv "House dis model")

The two national forecasts provide the FiveThirtyEight calculations for
each party's probability of winning a majority in their respective
chambers on any given day (e.g., "The Democratic party has an 85% chance
of winning a majority in the House").

The seat and district level forecasts will be used in this project. Each
observation represents one day's probability of victory for one
candidate. There are 28,353 observations in the Senate seat level file
and 302,859 for the House district level. For each observation, there
are 12 variables recorded:

1.  The date of the prediction (starting on 2018-08-01)
2.  The State the election is in
3.  The Congressional district the election is in
4.  Whether the election is a "special election"
5.  The candidate's full name
6.  The candidate's political party
7.  The model version (classic, lite, or deluxe)
8.  The candidate's probability of victory
9.  The candidate's expected share of the vote (50th percentile)
10. The candidate's ~minimum share of the vote (10th percentile)
11. The candidate's ~maximum share of the vote (90th percentile)

Below is a sample of variables to show the structure of the data as
provided by FiveThirtyEight.

    ## # A tibble: 299,760 x 7
    ##    forecastdate state district party incumbent win_probability voteshare
    ##    <date>       <chr>    <dbl> <chr> <lgl>               <dbl>     <dbl>
    ##  1 2018-08-01   AK           1 R     TRUE               0.718      49.4 
    ##  2 2018-08-01   AK           1 D     FALSE              0.282      44.1 
    ##  3 2018-08-01   AK           1 <NA>  FALSE              0           6.54
    ##  4 2018-08-01   AL           1 R     TRUE               0.999      64.9 
    ##  5 2018-08-01   AL           1 D     FALSE              0.0007     35.1 
    ##  6 2018-08-01   AL           2 R     TRUE               0.973      58.2 
    ##  7 2018-08-01   AL           2 D     FALSE              0.0271     41.8 
    ##  8 2018-08-01   AL           3 R     TRUE               0.997      62.3 
    ##  9 2018-08-01   AL           3 D     FALSE              0.0028     37.7 
    ## 10 2018-08-01   AL           4 R     TRUE               1          76.3 
    ## # ... with 299,750 more rows

### PredictIt Markets

PredictIt markets are comprised of "markets" and "contracts." As they
explain on [their
website](https://www.predictit.org/support/faq "PredictIt FAQ"):

> Every question posed by PredictIt is known as a ‘market’. Some markets
> have simple yes or no answers, while others can have multiple possible
> answers.

> Each possible answer to the question posed in a market is known as a
> ‘contract’. Markets that ask simple yes or no answers are known as
> ‘single-contract markets’, while those with multiple possible choices
> – like the winner of an election – are called ‘multiple-contract
> markets’... Single-contract markets resolve either to ‘Yes’ or ‘No’.
> In multiple-contract markets, only one contract can resolve to ‘Yes’.
> All others will resolve to ‘No’.

On [their
webstie](https://www.predictit.org/research "PredictIt research"),
PredictIt outlines their data agreement with academic researchers:

> In order to take full advantage of the research opportunities
> presented by prediction markets like PredictIt, we make our data
> available to members of the academic community at no cost. PredictIt’s
> market data offers researchers a wealth of information that can be
> used to further our understanding of a wide array of subjects in
> fields of study as diverse as microeconomics, political behavior,
> computer science and game theory.

I scraped [the PredictIt
API](https://www.predictit.org/api/marketdata/all/ "PredictIt API")
before the election and used the data to find all market ID's related to
Congressional elections. PredictIt then provided the revelant market
data as a `.csv` file.

Each observation represents one day's opening, closing, low, and high
price for a single contract from a single market. There are 44,711
observations covering 145 contracts across 118 markets. For each
observation there are 11 variables:

1.  Market ID
2.  Market name (the "question" being asked)
3.  Market symbol
4.  Contract name (the possible "answers")
5.  Contract symbol
6.  Prediction date (earliest is 201-01-27)
7.  Opening contract price
8.  Low contract price
9.  High contract price
10. Closing contract price (that day's final prediction)

Below is a random sample of observations with a selection of variables
to show the structure of the data as provided by PredictIt:

    ## # A tibble: 44,711 x 6
    ##    MarketId MarketSymbol        ContractSymbol Date       ClosePrice Volume
    ##    <chr>    <chr>               <chr>          <date>          <dbl>  <dbl>
    ##  1 4138     MN08.2018           DEM.MN08.2018  2018-09-25       0.45    282
    ##  2 3497     HEIN.NMSENATE.2018  <NA>           2018-01-31       0.92     10
    ##  3 2941     MANCHIN.WVSENATE.2… <NA>           2018-07-23       0.75     51
    ##  4 4253     PA06.2018           DEM.PA06.2018  2018-10-16       0.95      0
    ##  5 4232     CASE.PASENATE.2018  <NA>           2018-05-11       0.88    380
    ##  6 4156     FL17.2018           GOP.FL17.2018  2018-04-02       0.85      0
    ##  7 3608     HELL.NVSENATE.2018  <NA>           2017-10-13       0.13      1
    ##  8 3767     NH01.2018           DEM.NH01.2018  2018-09-15       0.81      0
    ##  9 2941     MANCHIN.WVSENATE.2… <NA>           2017-07-23       0.67     56
    ## 10 3513     HURD.TX23.2018      <NA>           2017-09-28       0.41     10
    ## # ... with 44,701 more rows

Data Wrangling
--------------

Data Exploration
----------------

Project Findings
----------------

Conclusion
----------

Biblography
-----------

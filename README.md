# predictr
Comparing the political predictive capability of markets, polling, and modeling

## Project

I will be exploring the political predictive capabilities of markets. To this end, I will be looking at the accuracy of four tools in their ability to predict 2018 midterm election results:

1. Prediction markets ([predictit.org](https://www.predictit.org/markets/detail/2704/Which-party-will-control-the-House-after-2018-midterms))
2. Forecast models ([fivethirtyeight.com](https://projects.fivethirtyeight.com/2018-midterm-election-forecast/house/?ex_cid=midterms-header#change))
3. Polling aggrigates ([realclearpolitics.com](https://www.realclearpolitics.com/epolls/2018/house/2018_elections_house_map.html)]
4. Individual polling ([Washington Post/ABC](https://apps.washingtonpost.com/g/page/politics/washington-post-abc-news-poll-oct-8-11-2018/2340/))

I hypothesize that prediction markets offer the greatest accuracy at any point further than 30 days from the election, offering a unique role in campaign resource allocation.

### Prediction Markets

> Prediction markets are exchange-traded markets created for the purpose of trading the outcome of events. The [market prices](https://en.wikipedia.org/wiki/Market_price "Market price") can indicate what the crowd thinks the [probability](https://en.wikipedia.org/wiki/Probability "Probability") of the [event](https://en.wikipedia.org/wiki/Event_(probability_theory) "Event (probability theory)") is. A prediction market contract trades between 0 and 100%. It is a [binary option](https://en.wikipedia.org/wiki/Binary_option "Binary option") that will expire at the price of 0 or 100%. Prediction markets can be thought of as belonging to the more general concept of crowdsourcing which is specially designed to aggregate information on particular topics of interest. The main purposes of prediction markets are eliciting aggregating beliefs over an unknown future outcome. Traders with different beliefs trade on contracts whose payoffs are related to the unknown future outcome and the market prices of the contracts are considered as the aggregated belief. _[source: [Wikipedia](https://en.wikipedia.org/wiki/Prediction_market)]_

### Forecast models

> (Forecasting models) take lots of polls, perform various types of adjustments to them, and then blend them with other kinds of empirically useful indicators (what we sometimes call “the fundamentals”) to forecast each race. Then they account for the uncertainty in the forecast and simulate the election thousands of times. Our models [are probabilistic in nature](https://fivethirtyeight.com/features/a-users-guide-to-fivethirtyeights-2016-general-election-forecast/); we do a _lot_ of thinking about these probabilities, and the goal is to develop probabilistic estimates that hold up well under real-world conditions. For instance, when we launched the 2018 House forecast, Democrats’ chances of winning the House were about 7 in 10 — right about what [Hillary Clinton’s chances were](https://fivethirtyeight.com/features/why-fivethirtyeight-gave-trump-a-better-chance-than-almost-anyone-else/) on election night in 2016! So [ignore those probabilities at your peril](https://fivethirtyeight.com/features/the-media-has-a-probability-problem/). _[source: [FiveThirtyEight](https://fivethirtyeight.com/methodology/how-fivethirtyeights-house-and-senate-models-work/)]_

### Polling aggregates

> A poll aggregator is a web site that predicts upcoming U.S. federal elections by gathering and averaging pre-election [polls](https://en.wikipedia.org/wiki/Opinion_poll "Opinion poll") published by others… How individual polls are averaged varies from site to site. Some aggregators weight polls in the average based on past pollster accuracy, age of the poll, or other more subjective factors. _[source: [Wikipedia](https://en.wikipedia.org/wiki/Poll_aggregator)]_ 

### Individual polls

> An opinion poll, often simply referred to as a poll or a survey, is a [human research survey](https://en.wikipedia.org/wiki/Survey_(human_research)) of [public opinion](https://en.wikipedia.org/wiki/Public_opinion "Public opinion") from a particular [sample](https://en.wikipedia.org/wiki/Sampling_(statistics) "Sampling (statistics)"). Opinion polls are usually designed to represent the opinions of a population by conducting a series of questions and then extrapolating generalities in ratio or within [confidence intervals](https://en.wikipedia.org/wiki/Confidence_intervals "Confidence intervals")… Over time, a number of theories and mechanisms have been offered to explain erroneous polling results. Some of these reflect errors on the part of the pollsters; many of them are statistical in nature. _[source: [Wikipedia](https://en.wikipedia.org/wiki/Opinion_poll)]_ 


## PredictIt

### About

> PredictIt is a unique and exciting real money site that tests your knowledge of political events by letting you trade shares on everything from the outcome of an election to a Supreme Court decision to major world events… PredictIt is run by [Victoria University](http://www.victoria.ac.nz/) of Wellington, New Zealand, a not-for-profit university, for educational purposes. _[source: [PredictIt](https://www.predictit.org/support/what-is-predictit)]_ 

Users of this site can legally trade on the exchange with real currency, winning money if their prediction comes true and their shares sell for $1. Traders can also sell their shares at any time, provided there is a corresponding buyer; as public opinion shifts, “Yes” or “No” shares may become more or less valuable. 

The site is exempt from the usual ban on both online and political betting by working with researchers to study prediction markets as a political tool. In October of 2014, the Commodity Futures Trading Commission granted the site a No-Action letter allowing them to operate in spite of such laws. The site hosts markets on nearly every conceivable political event, electoral or otherwise:

* [Will Donald Trump be president at year-end 2018?](https://www.predictit.org/markets/detail/2939/Will-Donald-Trump-be-president-at-year-end-2018)
* [Will the federal government be shut down on February 9?](https://www.predictit.org/markets/detail/4078/Will-the-federal-government-be-shut-down-on-February-9)
* [Will Ted Cruz be re-elected to the U.S. Senate in Texas in 2018?](https://www.predictit.org/markets/detail/2928/Will-Ted-Cruz-be-re-elected-to-the-US-Senate-in-Texas-in-2018)
* [Will Facebook’s Mark Zuckerberg run for president in 2020?](https://www.predictit.org/markets/detail/2992/Will-Facebook%27s-Mark-Zuckerberg-run-for-president-in-2020)
* [How many tweets will @realDonaldTrump post from noon Oct. 10 to noon Oct. 17?](https://www.predictit.org/markets/detail/4956/How-many-tweets-will-@realDonaldTrump-post-from-noon-Oct-17-to-noon-Oct-24)

### Markets

There are not markets for every midterm election. However, there _are_ markets for over 100 of the most contested congressional general elections. According to the Cook Political Report, as of October 19th, there are 105 "competitive" House races.

|Rating|Democrat|Republican|Total|
|--|--|--|--|
|Solid|182|145|327 _(75%)_|
|Likely|10|50|60 _(14%)_|
|Toss-up|3|45|48 _(11%)_|

These competitive races aren't all represented with markets, but there is significant overlap. Enough to establish a comparison between  our three (3) other predictive tools (all of which have data on the races in question).

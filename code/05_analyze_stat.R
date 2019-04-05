### Kiernan Nicholls
### Analyze the comparison between markets and models

hits <- messy %>%
        filter(race != "NC-09") %>%
        mutate(market_guess = if_else(market > 0.5, TRUE, FALSE),
               model_guess  = if_else(model  > 0.5, TRUE, FALSE)) %>%
        inner_join(results, by = "race") %>%
        select(-category) %>%
        mutate(market_hit = (market_guess == winner),
               model_hit = (model_guess == winner)) %>%
        mutate(week = lubridate::week(date),
               month = lubridate::month(date))

both_hit <- hits %>%
        filter(model_hit & market_hit) %>%
        select(date, race, market, model)

both_miss <- hits %>%
        filter(!race %in% both_hit$race)

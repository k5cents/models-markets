# Kiernan Nicholls
# Check predictions against election results
library(tidyverse)

# Some markets only have data on candidate from 1 party
# We only need probability for one candidate in each race
# I will use the democratic candidate

# Find races with data on only 1 candidate
single_party_markets <- market %>%
  group_by(race, date) %>%
  summarise(n = n()) %>%
  filter(n == 1) %>%
  select(race) %>%
  as_vector() %>%
  unique()

# Find races with data on multiple Democratic candidates
multiple_dems <- model %>%
  filter(party == "D") %>%
  group_by(race, date) %>%
  summarise(n = n()) %>%
  filter(n > 1) %>%
  select(race) %>%
  as_vector() %>%
  unique()

# Find races with data on multiple Republican candidates
multiple_gop <- model %>%
  filter(party == "R") %>%
  group_by(race, date) %>%
  summarise(n = n()) %>%
  filter(n > 1) %>%
  select(race) %>%
  as_vector() %>%
  unique()

# Combine stats for candidates of the party
model %>%
  filter(race %in% c(multiple_dems, multiple_gop)) %>%
  group_by(date, race, party) %>%
  summarise(prob = sum(prob),
            min_share = sum(min_share),
            voteshare = sum(voteshare),
            max_share = sum(max_share))

# For markets with only Republicans, take the complimentary probability
# This process assumes all races will only have Republicans or Democrats
# For the few elections with two candidates of 1 party, leading candidate used

only_gop <-
  market %>%
  filter(race %in% single_party_markets,
         party == "R")

# Invert prices from "Yes" R to "No" R (i.e., "Yes" D)
gop_only$open  <- 1 - gop_only$open
gop_only$low   <- 1 - gop_only$low
gop_only$high  <- 1 - gop_only$high
gop_only$close <- 1 - gop_only$close

# Invert party from R to D
gop_only$party <- "D"

y$open  <- 1 - y$open
y$low   <- 1 - y$low
y$high  <- 1 - y$low
y$close <- 1 - y$close
y$party <- "D"

y <- y %>% bind_rows(filter(market, party == "D"))

x <- model %>% filter(party == "D")
xy <-
  left_join(y, x, by = c("date", "race", "party")) %>%
  filter(date >= "2018-08-01",
         date <= "2018-11-05") %>%
  arrange(date) %>%
  select(date, race, incumbent, chamber, prob, close) %>%
  rename(model = prob,
         market = close) %>%
  gather(model, market,
         key = method,
         value = prob) %>%
  arrange(date) %>%
  mutate(call = if_else(prob > 0.50, TRUE, FALSE)) %>%
  left_join(results, by = "race") %>%
  mutate(hit = if_else(call == won, TRUE, FALSE))

z <-
  xy %>%
  group_by(date, method) %>%
  summarise(ratio = mean(hit, na.rm = TRUE))

ggplot(z) +
  geom_line(aes(date, ratio, color = method), size = 2) +
  scale_color_manual(values = c("#ED713A", "#6633FF"))

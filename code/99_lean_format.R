# Kiernan Nicholls
# Based on Cook Partisan Voting Index
# 538 on their partisan quantification: http://53eig.ht/1rtnTwh
library(tidyverse)
library(magrittr)

lean_states %<>%
  rename(lean = pvi_538) %>%
  separate(col = lean,
           into = c("party", "lean"),
           remove = TRUE,
           sep = "\\+") %>%
  arrange(state) %>%
  mutate(lean = if_else(party == "D",
                        as.numeric(lean) * -1,
                        as.numeric(lean)),
         state = state.abb)

lean_district %<>%
  rename(lean = pvi_538) %>%
  separate(col = lean,
           into = c("party", "lean"),
           remove = TRUE,
           sep = "\\+") %>%
  separate(col = district,
           into = c("state", "district"),
           remove = TRUE,
           sep = "\\-") %>%
  mutate(district = str_pad(district, width = 2, side = "left", pad = "0")) %>%
  unite(col = "code", state, district, sep = "-") %>%
  arrange(code) %>%
  mutate(lean = if_else(party == "D",
                        as.numeric(lean) * -1,
                        as.numeric(lean)))

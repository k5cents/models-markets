# Kiernan Nicholls
# Based on Cook Partisan Voting Index
# 538 on their partisan quantification: http://53eig.ht/1rtnTwh

lean_states2 <- lean_states %>%
  rename(lean = pvi_538,
         race = state) %>%
  separate(col = lean,
           into = c("party", "lean"),
           remove = TRUE,
           sep = "\\+") %>%
  mutate(lean = if_else(party == "D",
                        as.numeric(lean) * -1,
                        as.numeric(lean)),
         race = paste(state.abb, 99, sep = "-"))

lean_district2 <- lean_district %>%
  rename(lean = pvi_538,
         race = district) %>%
  separate(col = lean,
           into = c("party", "lean"),
           remove = TRUE,
           sep = "\\+") %>%
  separate(col = race,
           into = c("state", "race"),
           remove = TRUE,
           sep = "\\-") %>%
  mutate(race = str_pad(race, width = 2, side = "left", pad = "0")) %>%
  unite(col = "race", state, race, sep = "-") %>%
  mutate(lean = if_else(party == "D",
                        as.numeric(lean) * -1,
                        as.numeric(lean)))

race_lean <- bind_rows(lean_states2, lean_district2) %>% arrange(race)

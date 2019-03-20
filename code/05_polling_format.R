# Kiernan Nicholls
# Format polling data as provided by 538
library(lubridate)

# A key for pollster and sponsor IDs
polling_key <-
  bind_rows(house_polls, senate_polls) %>%
  select(display_name,
         pollster_id, pollster,
         sponsor_ids, sponsors) %>%
  distinct()

polling_key$pollster_id %<>% as.character()
polling_key$sponsor_ids %<>% as.character()

# Formated for relational joins and key info
polling <-
  bind_rows(house_polls, senate_polls) %>%
  select(start_date,
         end_date,
         poll_id,
         pollster_id,
         sponsor_ids,
         sample_size,
         population,
         methodology,
         office_type,
         state,
         seat_number,
         internal,
         partisan,
         tracking,
         answer,
         candidate_party,
         pct) %>%
  rename(name = answer,
         party = candidate_party,
         support = pct,
         poll = poll_id,
         pollster = pollster_id,
         sponsor = sponsor_ids,
         n = sample_size,
         pop = population,
         method = methodology,
         chamber = office_type,
         district = seat_number) %>%
  filter(party == "DEM" | party == "REP" | party == "IND") %>%
  arrange(start_date)

polling$chamber %<>% str_extract("\\w*$") %>% tolower()

polling$party %<>% recode("DEM" = "D",
                          "REP" = "R",
                          "IND" = "I")

polling$support <- polling$support * 0.01

polling$district[polling$chamber == "house"]  %<>% str_pad(width = 2, pad = "0")

polling$district[polling$chamber == "senate"] %<>%
  str_pad(width = 2, pad = "S") %>%
  recode("S0" = "S1")

polling <- polling %>%
  left_join(y = tibble(state = state.name, abb = state.abb),
            by = "state") %>%
  select(-state) %>%
  rename(state = abb) %>%
  unite(state, district,
        col = race,
        sep = "-",
        remove = TRUE) %>%
  mutate(length = end_date - start_date) %>%
  select(start_date,
         length,
         race,
         name,
         party,
         chamber,
         support,
         everything())

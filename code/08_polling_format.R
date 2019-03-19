# Kiernan Nicholls
# Format polling data as provided by 538

# A key for pollster and sponsor IDs
polling_key <-
  bind_rows(polls_house, polls_senate) %>%
  select(display_name,
         pollster_id, pollster,
         sponsor_ids, sponsors) %>%
  distinct() %>%
  mutate(pollster_id = as.character(pollster_id),
         sponsor_ids = as.character(sponsor_ids))

# Formated for relational joins and key info
polling_data <-
  bind_rows(polls_house, polls_senate) %>%
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

polling_data$start_date <-  lubridate::mdy(polling_data$start_date)
polling_data$end_date <- lubridate::mdy(polling_data$end_date)
polling_data$poll <- as.character(polling_data$poll)
polling_data$pollster <- as.character(polling_data$pollster)
polling_data$sponsor <- as.character(polling_data$sponsor)
polling_data$chamber <- if_else(polling_data$chamber == "U.S. House",
                                true = "house",
                                false = "senate")
polling_data$party <- recode(polling_data$party,
                             "DEM" = "D",
                             "REP" = "R",
                             "IND" = "I")
polling_data$support <- polling_data$support * 0.01


polling_data$district <- if_else(polling_data$chamber == "house",
                                 true = polling_data$district,
                                 false = if_else(polling_data$district == 1,
                                                 true = 99,
                                                 false = 98))

polling_data$district <- str_pad(polling_data$district,
                                 width = 2,
                                 side = "left",
                                 pad = "0")

polling_data <-
  left_join(x = polling_data,
            y = tibble(state = state.name, abb = state.abb),
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
         everything()) %>%
  select(-end_date)

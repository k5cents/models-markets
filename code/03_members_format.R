### Kiernan Nicholls
### Format members of current congress

members <- legislators_current %>%
  rename(chamber = type,
         name = last_name,
         gid = govtrack_id) %>%
  select(name,
         gid,
         birthday,
         state,
         district,
         senate_class,
         party,
         gender,
         chamber) %>%
  arrange(chamber)

# Recode, Encode, and Pad
members$name %<>% iconv(to = "ASCII//TRANSLIT")
members$chamber %<>% recode("rep" = "house", "sen" = "senate")
members$district %<>%  str_pad(width = 2, pad = "0")
members$senate_class %<>% str_pad(width = 2, pad = "S")
members$party %<>% recode("Democrat"    = "D",
                          "Independent" = "D",
                          "Republican"  = "R")

members$district <- if_else(condition = is.na(members$district),
                            true = members$senate_class,
                            false = members$district)

# Create district code as relational key
members <- members %<>%
  unite(col = race,
        state, district,
        sep = "-",
        remove = TRUE) %>%
  select(-senate_class) %>%
  arrange(name)

# Format member stats for join
members_stats <-
  bind_rows(sponsorshipanalysis_h, sponsorshipanalysis_s) %>%
  select(ID, chamber, party, ideology, leadership) %>%
  rename(gid = ID)

members_stats$party %<>% recode("Democrat" = "D", "Republican" = "R")
members_stats$gid %<>% as.character()

# Add stats to frame by GovTrack ID
members %<>% left_join(members_stats, by = c("gid", "party", "chamber"))

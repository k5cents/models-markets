# Kiernan Nicholls
# Format members of current congress

members <- members_115 %>%
  select(govtrack_id,
         last_name,
         birthday,
         party,
         gender,
         type,
         state,
         district) %>%
  rename(name    = last_name,
         chamber = type,
         gid     = govtrack_id) %>%
  # Convert the names to ASCII for compatability
  mutate(name = iconv(name, to = "ASCII//TRANSLIT"),
         chamber = recode(chamber,
                          "rep" = "H",
                          "sen" = "S") %>% as_factor(),
         party = recode(party,
                        "Democrat"  = "D",
                        "Independent" = "D",
                        "Republican"  = "R") %>% as_factor(),
         gid = as.character(gid),
         district = str_pad(string = district,
                            side = "left",
                            width = 2,
                            pad = "0"),
         gender = as_factor(gender)) %>%
  # Create district code as relational key
  unite(col = race,
        state, district,
        sep = "-",
        remove = TRUE) %>%
  arrange(name)

members$race <- str_replace(string = members$race,
                            pattern = "-NA",
                            replacement = "-99")

members_115_stats <-
  bind_rows(house_115_stats, senate_115_stats) %>%
  select(ID,
         chamber,
         party,
         ideology,
         leadership) %>%
  rename(gid = ID) %>%
  mutate(party = recode(party,
                        "Democrat" = "D",
                        "Republican" = "R"),
         gid = as.character(gid),)

# Add stats to frame by GovTrack ID
members <- left_join(members,
                     members_115_stats,
                     by = c("gid", "party", "chamber"))

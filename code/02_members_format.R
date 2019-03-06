# Kiernan Nicholls
# Format members of current congress

members <-

  # Take members of the 115th congress
  members_115 %>%
  select(last_name,
         govtrack_id,
         bioguide_id,
         birthday,
         gender,
         type,
         state,
         district,
         party) %>%
  rename(name    = last_name,
         chamber = type,
         gid     = govtrack_id,
         bid     = bioguide_id) %>%

  # Convert the names to ASCII for compatability
  mutate(name = iconv(name, to = "ASCII//TRANSLIT"),

         # Recode values to match markets and models
         chamber = recode(chamber,
                          "rep" = "house",
                          "sen" = "senate"),
         party = recode(party,
                        "Democrat"  = "D",
                        "Independent" = "D",
                        "Republican"  = "R"),
         gid = as.character(gid),
         district = str_pad(string = district,
                            side = "left",
                            width = 2,
                            pad = "0")) %>%

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
         gid = as.character(gid))

# Add stats to frame by GovTrack ID
members <- left_join(members,
                     members_115_stats,
                     by = c("gid", "party", "chamber"))

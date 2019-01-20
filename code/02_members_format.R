# Kiernan Nicholls
# Format members of current congress
library(tidyverse)
library(magrittr)

members <-

  # Take members of the 115th congress
  members_115 %>%
  select(last_name,
         govtrack_id,
         birthday,
         gender,
         type,
         state,
         district,
         party) %>%
  rename(name    = last_name,
         chamber = type,
         gid     = govtrack_id) %>%

  # Convert the names to ASCII for better cross compatability
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
  unite(col = code,
        state, district,
        sep = "-",
        remove = TRUE) %>%
  arrange(name)

members$code <- str_replace(string = members$code,
                            pattern = "-NA",
                            replacement = "-99")

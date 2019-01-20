# Kiernan Nicholls
# Collect members of current congress
library(tidyverse)
library(magrittr)

members <-
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
  mutate(name = iconv(name, to = "ASCII//TRANSLIT"),
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
  unite(col = code,
        state, district,
        sep = "-",
        remove = TRUE) %>%
  arrange(name)

members$code <- str_replace(string = members$code,
                            pattern = "-NA",
                            replacement = "-99")

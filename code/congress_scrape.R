# head --------------------------------------------------------------------
# Kiernan Nicholls
# 2018-10-20
# Collect members of current congress
library(tidyverse)

# read --------------------------------------------------------------------
congress.members <-
  read_csv("https://theunitedstates.io/congress-legislators/legislators-current.csv",
           col_types = cols()) %>%
  select(full_name,
         last_name,
         type,
         state,
         district,
         party) %>%
  rename(full.name = full_name,
         chamber = type,
         name = last_name) %>%
  arrange(name)

# recode ------------------------------------------------------------------
congress.members$district[which(is.na(congress.members$district))] <- "00"
congress.members$chamber <- recode(congress.members$chamber,
                                   "sen" = "senate",
                                   "rep" = "house")
congress.members$party <- recode(congress.members$party,
                                 "Democrat" = "D",
                                 "Republican" = "R",
                                 "Independent" = "I")

congress.members <-
  congress.members %>%
  mutate(district = str_pad(string = district,
                            side = "left",
                            width = 2,
                            pad = "0")) %>%
  unite(col = code,
        state, district,
        sep = "-",
        remove = FALSE)

# write -------------------------------------------------------------------
write_csv(congress.members, "./data/congress_members.csv")

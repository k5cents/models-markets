# head --------------------------------------------------------------------
# Kiernan Nicholls
# 2018-10-20
# Collect members of current congress
library(tidyverse)

# read --------------------------------------------------------------------
congress.members <-
  read_csv("https://theunitedstates.io/congress-legislators/legislators-current.csv",
           col_types = cols()) %>%
  unite(col = name,
        first_name,
        last_name,
        sep = " ",
        remove = FALSE) %>%
  select(name,
         last_name,
         type,
         state,
         district,
         party) %>%
  rename(chamber = type,
         last = last_name) %>%
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
        remove = TRUE)

# Force all names to ASCII to match PredictIt format
congress.members$last <- iconv(congress.members$last,
                               to = "ASCII//TRANSLIT")

# write -------------------------------------------------------------------
write_csv(congress.members, "./data/congress_members.csv")

# head --------------------------------------------------------------------
# Kiernan Nicholls
# 2018-10-20
# Collect members of current congress
library(tidyverse)

# read --------------------------------------------------------------------
congress_members <-
  read_csv("https://theunitedstates.io/congress-legislators/legislators-current.csv",
           col_types = cols()) %>%
  unite(col = name,
        first_name, last_name,
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
congress_members$district[which(is.na(congress_members$district))] <- "99"
congress_members$chamber <- recode(congress_members$chamber,
                                   "sen" = "senate",
                                   "rep" = "house")
congress_members$party <- recode(congress_members$party,
                                 "Democrat" = "D",
                                 "Republican" = "R",
                                 "Independent" = "I")

congress_members <-
  congress_members %>%
  mutate(district = str_pad(string = district,
                            side = "left",
                            width = 2,
                            pad = "0")) %>%
  unite(col = code,
        state, district,
        sep = "-",
        remove = TRUE)

# Force all names to ASCII to match PredictIt format
congress_members$last <- iconv(congress_members$last,
                               to = "ASCII//TRANSLIT")

# write -------------------------------------------------------------------
write_csv(congress_members, "./data/congress_members.csv")

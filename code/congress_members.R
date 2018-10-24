# head --------------------------------------------------------------------
# Kiernan Nicholls
# 2018-10-20
# Collect members of current congress
library(tidyverse)

# read --------------------------------------------------------------------
congress <-
  read_csv("https://theunitedstates.io/congress-legislators/legislators-current.csv",
           col_types = cols()) %>%
  select(full_name,
         last_name,
         type,
         state,
         district,
         party) %>%
  rename(member.name = full_name,
         chamber = type,
         last.name = last_name) %>%
  arrange(last.name)

# recode ------------------------------------------------------------------
congress$district[which(is.na(congress$district))] <- "00"
congress$chamber <- recode(congress$chamber,
                           "sen" = "senate",
                           "rep" = "house")
congress$party <- recode(congress$party,
                         "Democrat" = "D",
                         "Republican" = "R",
                         "Independent" = "I")

# write -------------------------------------------------------------------
write_csv(congress, "./data/congress_members.csv")
congress <- read_csv("./data/congress_members.csv",
                     col_types = cols())

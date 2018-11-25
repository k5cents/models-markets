library(tidyverse)
house_url <- "https://projects.fivethirtyeight.com/2018-midterm-election-forecast/house/new-york/15/"
house_xpath <- "/html/body/main/div[2]/div/div/div/section[7]/div/table"

test <-
  read_html(house_url) %>%
  html_node(xpath = house_xpath) %>%
  html_table() %>%
  as_tibble() %>%
  select(-Explanation)

house_url <- "https://projects.fivethirtyeight.com/2018-midterm-election-forecast/house/"
str_replace(state.name, " ", "-")

sort(partisan_lean$code)

sen_base <- "https://projects.fivethirtyeight.com/2018-midterm-election-forecast/senate/"
sen_mod <-   read_csv("https://projects.fivethirtyeight.com/congress-model-2018/senate_seat_forecast.csv")
sen_races <- c(state.name[state.abb %in% sort(unique(sen_mod$state))], "Missouri-Special")
sen_url <- paste0(sen_base, tolower(str_replace(sen_races, " ", "-")), "/")
sen_xpath <- "/html/body/main/div[2]/div/div/div/section[6]/div/table"
house_xpath <- "/html/body/main/div[2]/div/div/div/section[7]/div/table"


df <-
  read_html(sen_url[1]) %>%
  html_node("table") %>%
  html_table()

sort(unique(model$code))
separate(sort(unique(model$code)),
         into = test, sep = "-")


read_html(sen_url[1]) %>%
  html_node(xpath = "/html/body/main/div[2]/div/div/div/section[6]/div/table") %>%
  html_table()

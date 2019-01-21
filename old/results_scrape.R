library(tidyverse)
library(rvest)
# i had to download and save a copy of the webpage
# it updates javascript live, so rvest can't scrape anything static
house_results_html <- read_html("./data/results_house.html")
house_results_list <- rep(list(NA), 6)

# scrape results from all 4 cook class race tables
for (i in 1:6) {
  house_results_list[[i]] <-
    house_results_html %>%
    html_node(xpath = paste0("/html/body/div[5]/div[2]/section[1]",
                             "/div[1]/div[1]/div[9]/div/div[2]/div/div/div[",
                             i, # change the div for each of the 6 tables
                             "]/div/table")) %>%
    html_table() %>%
    rename("code" = "",
           "dem" = "D",
           "rep" = "R",
           "report" = "% report.") %>%
    as_tibble() %>%
    select(-report) %>%
    mutate(class = i)
}
# bind all 6 tables into 1
house_election_results <- bind_rows(house_results_list)
nrow(house_election_results) == 435

# repeate for senate races
senate_results_html <- read_html("./data/results_senate.html")
senate_results_list <- rep(list(NA), 6)

# scrape results from all 4 cook class race tables
for (i in 1:6) {
  senate_results_list[[i]] <-
    senate_results_html %>%
    html_node(xpath = paste0("/html/body/div[5]/div[2]/section[1]",
                             "/div[1]/div[1]/div[9]/div/div[2]/div/div/div[",
                             i, # change the div for each of the 6 tables
                             "]/div/table")) %>%
    html_table() %>%
    rename("code" = "",
           "dem" = "D",
           "rep" = "R",
           "report" = "% report.") %>%
    as_tibble() %>%
    select(-report) %>%
    mutate(class = i)
}
senate_election_results <- bind_rows(senate_results_list)

senate_election_results <- arrange(senate_election_results, code)
senate_election_results$code <- abb <- c("AZ-99", "CA-99", "CO-99", "DE-99",
                                         "FL-99", "HI-99", "IN-99", "ME-99",
                                         "MA-99", "MD-99", "MI-99", "MN-99",
                                         "MN-98", "MS-99", "MS-98", "MO-99",
                                         "MT-99", "ND-99", "NJ-99", "NM-99",
                                         "NY-99", "NE-99", "NV-99", "OH-99",
                                         "PA-99", "RI-99", "TN-99", "TX-99",
                                         "UT-99", "VA-99", "VT-99", "WV-99",
                                         "WA-99", "WI-99", "WY-99")

# combine house and senate
election_results <- bind_rows(house_election_results,
                              senate_election_results)

# fix race classifications
election_results$class <- recode(election_results$class,
                                 "1" = "safe D",
                                 "2" = "lkly D",
                                 "3" = "vul D",
                                 "4" = "vul R",
                                 "5" = "lkly R",
                                 "6" = "safe R")

election_results$class <- factor(election_results$class,
                                 levels = c("safe D",
                                            "lkly D",
                                            "vul D",
                                            "vul R",
                                            "lkly R",
                                            "safe R"))

# fix district codes
election_results <-
  election_results %>%
  mutate(code = if_else(condition = nchar(code) == 2,
                        true = paste(code, "01",sep = "-"),
                        false = code)) %>%
  separate(col = code,
           into = c("abb", "num")) %>%
  mutate(num = str_pad(string = num,
                       width = 2,
                       side = "left",
                       pad = "0")) %>%
  unite(col = code,
        abb, num,
        sep = "-")

# fix uncalled races
# wapo doesn't give numbers for race"code"s with only 1 party
# i double checked all races with ballotpedia
election_results$dem <-
  election_results$dem %>%
  str_replace(pattern = "Unc.", replacement = "100.0%") %>%
  str_replace(pattern = "\\*",  replacement = "0.00%")

election_results$rep <-
  election_results$rep %>%
  str_replace(pattern = "Unc.", replacement = "100.0%") %>%
  str_replace(pattern = "\\*",  replacement = "0.00%")

# fix percentages
election_results$dem <- as.numeric(str_replace(election_results$dem,
                                               pattern = "%",
                                               replacement = "")) / 100
election_results$rep <- as.numeric(str_replace(election_results$rep,
                                               pattern = "%",
                                               replacement = "")) / 100

election_results <- arrange(election_results, code)

# add winner
election_results <-
  election_results %>%
  mutate(winner = if_else(condition = dem > rep,
                          true  = "D",
                          false = "R"))

write_csv(election_results, "./data/election_results.csv")

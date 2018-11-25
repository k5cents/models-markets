library(tidyverse)
library(rvest)
# i had to download and save a copy of the webpage
# it updates javascript live, so rvest can't scrape anything static
download.file(url = "https://www.washingtonpost.com/election-results/house/?utm_term=.d39d3a4eab10",
              destfile = "./data/results_house.html")
results_html <- read_html("./data/results_house.html")
results_list <- rep(list(NA), 6)

# scrape results from all 4 AP race class tables
for (i in 1:6) {
  results_list[[i]] <-
    results_html %>%
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
results <- bind_rows(results_list)
nrow(results) == 435

# add variable for AP race classification
results$class <- recode(results$class,
                        "1" = "safe dem",
                        "2" = "likely dem",
                        "3" = "vul dem",
                        "4" = "vul rep",
                        "5" = "likely rep",
                        "6" = "safe rep")

# fix district codes
results <-
  results %>%
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
results$dem <-
  results$dem %>%
  str_replace(pattern = "Unc.", replacement = "100.0%") %>%
  str_replace(pattern = "\\*",  replacement = "0.00%")

results$rep <-
  results$rep %>%
  str_replace(pattern = "Unc.", replacement = "100.0%") %>%
  str_replace(pattern = "\\*",  replacement = "0.00%")

# fix percentages
results$dem <- as.numeric(str_replace(results$dem, "%", "")) / 100
results$rep <- as.numeric(str_replace(results$rep, "%", "")) / 100

# add winner
results <-
  results %>%
  mutate(winner = if_else(condition = dem > rep,
                          true  = "D",
                          false = "R"))

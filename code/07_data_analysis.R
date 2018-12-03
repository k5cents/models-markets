# Kiernan Nicholls
# load --------------------------------------------------------------------
library(tidyverse)
congress_members <- read_csv("./data/congress_members.csv")
market_names     <- read_csv("./data/market_names.csv")
market_data      <- read_csv("./data/market_data.csv")
market_history   <- read_csv("./data/market_history.csv")
model_history    <- read_csv("./data/model_history.csv")
joined           <- read_csv("./data/joined.csv",
                             col_types = cols(mid = col_character(),
                                              cid = col_character()))
election_results <- read_csv("./data/election_results.csv")
# analyze -----------------------------------------------------------------
joined$party <- recode(joined$party, "I" = "D")

final <-
  left_join(joined, election_results, by = "code")

slice2 <-
  joined %>%
  filter(date == "2018-08-10" |
         date == "2018-09-05" |
         date == "2018-10-05" |
         date == "2018-11-05") %>%
  gather(key = tool,
         value = guess,
         price, prob) %>%
  mutate(tool = recode(tool, "price" = "market", "prob" = "model"))

# volume ------------------------------------------------------------------
volume <-
  joined %>%
  filter(date < "2018-11-05") %>%
  group_by(date, party) %>%
  summarise(volume = sum(volume, na.rm = T),
            price = mean(price, na.rm = T)) %>%
  mutate(traded = volume * price)

ggplot(volume) +
  geom_bar(aes(x = date, y = traded, fill = party), stat = "identity") +
  scale_fill_manual(values = c("D" = "blue", "R" = "red")) +
  labs(title = "Sum of Daily Traded Shares by Party",
       subtitle = "Daily contract volume multiplied closing price",
       x = "Date",
       y = "Dollars Traded") +
  annotate(geom = "text",
           label = sum(joined$volume*joined$price, na.rm = TRUE),
           x = 50,
           y = 150000)

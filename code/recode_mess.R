market.history$contract <- recode(market.history$contract,
                                  "Democratic/DFL" = "Democratic")
market.history$contract <-
  if_else(condition = market.history$contract == "Democratic",
          true  = "Democratic",
          false = if_else(
            condition = market.history$contract == "Republican",
            true  = "Republican",
            false = if_else(
              condition = word(market.history$contract, 3) == "be",
              true  = word(market.history$contract, 2),
              false = word(market.history$contract, 3))))

m2 <- market.history %>% select(date, id, name, contract, price)

m2$name <- if_else(condition = nchar(m2$name) == 2,
                   true = paste(m2$name, "00", sep = "-"),
                   false = m2$name)

congress <-
  read_csv("./data/congress_members.csv",
           col_types = cols()) %>%
  mutate(district = str_pad(string = district,
                            side = "left",
                            width = 2,
                            pad = "0")) %>%
  unite(col = code,
        state, district,
        sep = "-",
        remove = FALSE) %>%
  rename(name = last.name)

m3 <- left_join(m2, congress, by = c("name" = "last.name"))
m4 <- left_join(m2, congress, by = c("name" = "code"))

m2$name[which(grepl("-", m2$name) & nchar(m2$name) == 5) ]
grepl("-", m2$name) & nchar(m2$name) == 5

test <- if_else(condition = grepl("-", m2$name) & nchar(m2$name) == 5,
                true = m2$name,
                false = NA)
m9 <- m2 %>%
  mutate(code = if_else(condition = grepl("-", m2$name) & nchar(m2$name) == 5,
                                true = m2$name,
                                false = "NA")) %>%
  mutate(name = if_else(condition = grepl("-", m2$name) & nchar(m2$name) == 5,
                                true = "NA",
                                false = m2$name))

m9$code[which(m9$code == "NA")] <- NA
m9$name[which(m9$name == "NA")] <- NA

mm1 <- left_join(m9, congress, by = "code")
mm2 <- left_join(m9, congress, by = "name")


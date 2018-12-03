library(tidyverse)
joined <-
  read_csv("./data/joined.csv",
           col_types = cols(mid = col_character(),
                            cid = col_character())) %>%
  mutate(party = recode(party, "I" = "D"))

j2 <-
  joined %>%
  gather(prob, price,
         key = tool,
         value = prob) %>%
  mutate(tool = recode(tool,
                       "price" = "market",
                       "prob" = "model"))

difference <-
  ggplot(filter(joined, party != "I"),
         aes(x = date,
             y = price - prob,
             color = party,
             linetype = incumbent)) +
  geom_smooth() +
  scale_color_manual(values = c("blue", "red")) +
  scale_linetype_manual(values = c("twodash", "solid")) +
  ggtitle("Difference in Market Pice and Model Probability Over Time") +
  xlab("Date") +
  ylab("Market Price - Model Prob") +
  geom_hline(yintercept = 0)

ggsave("./plots/difference.png",
       last_plot(),
       dpi = "retina")

ggplot(data = filter(j2, party != "I"),
       mapping = aes(x = date,
                     y = prob)) +
  geom_smooth(aes(color = party,
                  linetype = tool)) +
  scale_color_manual(values = c("blue", "red"))

ggplot(election_results) +
  geom_bar(aes(x = class)) +
  labs(title = "Cook Political Report Race Classifications",
       y = "Number of Race",
       x = "Cook Political Report Classification") +
  scale_x_discrete(labels = c("Safe Democratic",
                              "Likely Democratic",
                              "Vulnerable Democratic",
                              "Vulnerable Republican",
                              "Likely Republican",
                              "Safe Republican"))

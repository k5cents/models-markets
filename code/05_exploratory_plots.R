joined <- read_csv("./data/joined,csv")

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

# Kiernan Nicholls

# Accuracy of each method over time
p2 <-
  left_join(markets, model,
          by = c("date", "race", "party")) %>%
  filter(date >= "2018-08-01",
         date <= "2018-11-05") %>%
  select(date, race, name, chamber, party, special, incumbent, prob, close) %>%

  # Tidy data, gather by predictive method
  rename(model  = prob,
         market = close) %>%
  gather(model, market,
         key   = method,
         value = prob) %>%
  arrange(date) %>%

  # Add the binary win/loss prediction
  mutate(pick = if_else(prob > 0.50, TRUE, FALSE)) %>%

  # Join with election results
  left_join(results, by = "race") %>%

  # Compare the method prediction to actual winner
  mutate(correct = if_else(pick == winner, TRUE, FALSE)) %>%
  select(-pick, -winner)

p2_plot <-
  p2 %>%
  filter(party == "D") %>%
  group_by(date, method) %>%
  summarise(accuracy = mean(correct, na.rm = TRUE)) %>%
  ggplot() +
  geom_line(aes(date, accuracy,
                color = method), size = 2) +
  scale_color_manual(values = c("#6633FF", "#ED713A")) +
  labs(title = "Accuracy over Time by Predictive Method",
       x = "Date of Prediction",
       y = "Correct Predictions") +
  scale_y_continuous(labels = scales::percent) +
  ylim(c(0.8, 1))

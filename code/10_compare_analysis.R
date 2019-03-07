# Kiernan Nicholls

# Accuracy of each method over time
plot_accuracy_time <-
  predictions %>%
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
  coord_cartesian(ylim = c(.5, .8))

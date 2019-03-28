### Kiernan Nicholls
### Analyze the comparison between markets and models

t.test(x = hits$market_hit,
       y = hits$model_hit,
       paired = TRUE)

h8  <- hits %>% filter(month(date)  < 9)
h9  <- hits %>% filter(month(date) == 9)
h10 <- hits %>% filter(month(date)  > 9)

t.test(x = h8$market_hit,
       y = h8$model_hit,
       paired = TRUE)

t.test(x = h9$market_hit,
       y = h9$model_hit,
       paired = TRUE)

t.test(x = h10$market_hit,
       y = h10$model_hit,
       paired = TRUE)

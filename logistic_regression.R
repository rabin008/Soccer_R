#Packages
library(dplyr)
library(tidyr)
library(ggplot2)

# load data into data.frame (in this case we will be using PL 2022/23)
epl_data <- read.csv(file.choose(),header=T)

# let's model the probability of a team winning 
epl_data_result <- bind_rows(list(
  epl_data %>%
    select(team = HomeTeam, opponent = AwayTeam, result = FTR) %>%
    mutate(home = 1, win = if_else(result == "H", 1, 0)) %>%
    select(-result),
  epl_data %>%
    select(team = AwayTeam, opponent = HomeTeam, result = FTR) %>%
    mutate(home = 0, win = if_else(result == "A", 1, 0)) %>%
    select(-result)
)) %>% 
  mutate(across(c(1:4), factor)) # convert columns to factors

# Fitting the model (win ~ home + team + opponent)
logistic_model <- glm(win ~ home + team + opponent, 
                      family="binomial", data=epl_data_result)

# Print summary of the model
summary(logistic_model)

# Applying the model
# Considering matchday 1 of season 2023/24. Take Everton vs Fulham as an example

# Based on the adjusted model, get the probability of Everton winning
predict(logistic_model, 
        data.frame(home="1", team="Everton", 
                   opponent="Fulham"), type="response")

# Based on the adjusted model, get the probability of Fulham winning
predict(logistic_model, 
        data.frame(home="0", team="Fulham", 
                   opponent="Everton"), type="response")

# We can see that Fulham have slightly higher chances of winning (35% vs 32%)
# The final score was 0-1 to Fulham


# Let's create a plot to visualize the fitted model
ggplot(data=data.frame(epl_data_result, prob = logistic_model$fitted.values) %>%
                arrange(prob) %>%
                mutate(rank = 1:nrow(epl_data_result)), 
       aes(x=rank, y=prob)) +
  geom_point(aes(color=win), size=5) +
  xlab("Sex") +
  ylab("Predicted probability of getting heart disease")
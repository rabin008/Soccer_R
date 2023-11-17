#Packages
library(dplyr)
library(tidyr)
library(ggplot2)

# load data into data.frame (in this case we will be using PL 2022/23)
epl_data <- read.csv(file.choose(),header=T)

# based on the exploratory analysis, let's try to model the number of goals using Poisson regression
epl_data_goals <- bind_rows(list(
  epl_data %>%
    select(team = HomeTeam, opponent = AwayTeam, goals = FTHG) %>%
    mutate(home = 1),
  epl_data %>%
    select(team = AwayTeam, opponent = HomeTeam, goals = FTAG) %>%
    mutate(home = 0)
  
))

# Fitting the model (number of goals ~ home + team + opponent)
poisson_model <- glm(goals ~ home + team + opponent, 
                   family=poisson(link=log), data=epl_data_goals)

# Print summary of the model
summary(poisson_model)

# Applying the model
# Considering matchday 1. Take Everton vs Fulham as an example

# Based on the adjusted model, predict the expected number of goals Everton will score
predict(poisson_model, 
        data.frame(home=1, team="Everton", 
                   opponent="Fulham"), type="response")

# Based on the adjusted model, predict the expected number of goals Fulham will score
predict(poisson_model, 
        data.frame(home=0, team="Fulham", 
                   opponent="Everton"), type="response")

# Now that we have calculated lambda, we can calculate probabilities of scoring goals
dpois(0:10, predict(poisson_model, data.frame(home=1, team="Everton", 
                    opponent="Fulham"), type="response")) 
dpois(0:10, predict(poisson_model, data.frame(home=0, team="Fulham", 
                    opponent="Everton"), type="response"))


# Creating a function to wrap up the probabilities
simulate_match <- function(foot_model, homeTeam, awayTeam){
  
  home_goals_avg <- predict(foot_model,
                            data.frame(home=1, team=homeTeam, 
                                       opponent=awayTeam), type="response")
  away_goals_avg <- predict(foot_model, 
                            data.frame(home=0, team=awayTeam, 
                                       opponent=homeTeam), type="response")
  
  dpois(0:10, home_goals_avg) %o% dpois(0:10, away_goals_avg) # assuming independence
}

# Simulate goals scored in Everton vs Fulham game
simulate_match(poisson_model, "Everton", "Fulham")

# Consider scenarios where Everton score more goals than Fulham i.e. Everton win
sum(simulate_match(poisson_model, "Everton", "Fulham")[
  lower.tri(simulate_match(poisson_model, "Everton", "Fulham"))])

# Consider scenarios where Everton score the same number goals than Fulham i.e. draw
sum(diag(simulate_match(poisson_model, "Everton", "Fulham")))

# Consider scenarios where Everton score fewer goals than Fulham i.e. Fulham win
sum(simulate_match(poisson_model, "Everton", "Fulham")[
  upper.tri(simulate_match(poisson_model, "Everton", "Fulham"))])

# As can be seen Fulham are favorites
# The final score was 0-1 to Fulham








# Let's adjust a Poisson regression model to the number of corners

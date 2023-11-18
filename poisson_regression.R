#Packages
library(dplyr)
library(tidyr)

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
)) %>% 
  mutate(across(4, factor)) # convert columns to factors

# Fitting the model (number of goals ~ home + team + opponent)
poisson_model <- glm(goals ~ home + team + opponent, 
                   family=poisson(link=log), data=epl_data_goals)

# Print summary of the model
summary(poisson_model)

# Applying the model
# Considering matchday 1 of season 2023/24. Take Everton vs Fulham as an example

# Based on the adjusted model, predict the expected number of goals Everton will score
predict(poisson_model, 
        data.frame(home="1", team="Everton", 
                   opponent="Fulham"), type="response")

# Based on the adjusted model, predict the expected number of goals Fulham will score
predict(poisson_model, 
        data.frame(home="0", team="Fulham", 
                   opponent="Everton"), type="response")

# Now that we have calculated lambda, we can calculate probabilities of scoring goals
dpois(0:10, predict(poisson_model, data.frame(home="1", team="Everton", 
                    opponent="Fulham"), type="response")) 
dpois(0:10, predict(poisson_model, data.frame(home="0", team="Fulham", 
                    opponent="Everton"), type="response"))


# Creating a function to wrap up the probabilities
simulate_match <- function(foot_model, homeTeam, awayTeam){
  
  home_goals_avg <- predict(foot_model,
                            data.frame(home="1", team=homeTeam, 
                                       opponent=awayTeam), type="response")
  away_goals_avg <- predict(foot_model, 
                            data.frame(home="0", team=awayTeam, 
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
epl_data_corners <- bind_rows(list(
  epl_data %>%
    select(team = HomeTeam, opponent = AwayTeam, corners = HC) %>%
    mutate(home = 1),
  epl_data %>%
    select(team = AwayTeam, opponent = HomeTeam, corners = AC) %>%
    mutate(home = 0)
)) %>% 
  mutate(across(4, factor)) # convert columns to factors

# Fitting the model (number of corners ~ home + team + opponent)
poisson_model <- glm(corners ~ home + team + opponent, 
                     family=poisson(link=log), data=epl_data_corners)

# Print summary of the model
summary(poisson_model)

# Applying the model
# Considering matchday 1 of season 2023/24. Take Everton vs Fulham as an example

# Based on the adjusted model, predict the expected number of corners for Everton
predict(poisson_model, 
        data.frame(home="1", team="Everton", 
                   opponent="Fulham"), type="response")

# Based on the adjusted model, predict the expected number of goals for Fulham
predict(poisson_model, 
        data.frame(home="0", team="Fulham", 
                   opponent="Everton"), type="response")

# Calculate probabilities for different outcomes 
dpois(0:20, predict(poisson_model, data.frame(home="1", team="Everton", 
                                              opponent="Fulham"), type="response")) 

dpois(0:20, predict(poisson_model, data.frame(home="0", team="Fulham", 
                                              opponent="Everton"), type="response"))

# Creating a function to wrap up the probabilities
simulate_match <- function(foot_model, homeTeam, awayTeam, max){
  
  home_corners_avg <- predict(foot_model,
                            data.frame(home="1", team=homeTeam, 
                                       opponent=awayTeam), type="response")
  away_corners_avg <- predict(foot_model, 
                            data.frame(home="0", team=awayTeam, 
                                       opponent=homeTeam), type="response")
  
  dpois(0:max, home_corners_avg) %o% dpois(0:max, away_corners_avg) # assuming independence
}

# Calculating probability of having less than 5 corners in the match
sum(simulate_match(poisson_model, "Everton", "Fulham", 5)[
  col(simulate_match(poisson_model, "Everton", "Fulham", 5)) +
  row(simulate_match(poisson_model, "Everton", "Fulham", 5)) <= 7
])

# Calculating probability of having less than 10 corners in the match
sum(simulate_match(poisson_model, "Everton", "Fulham", 10)[
  col(simulate_match(poisson_model, "Everton", "Fulham", 10)) +
    row(simulate_match(poisson_model, "Everton", "Fulham", 10)) <= 12
])

# Calculating probability of having less than 15 corners in the match
sum(simulate_match(poisson_model, "Everton", "Fulham", 15)[
  col(simulate_match(poisson_model, "Everton", "Fulham", 15)) +
    row(simulate_match(poisson_model, "Everton", "Fulham", 15)) <= 17
])

# As can be seen, it's likely that the match will have less than 15 corners
# The number of corners in the match was 14 (10 for Everton and 4 for Fulham)
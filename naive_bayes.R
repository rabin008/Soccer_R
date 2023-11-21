#Packages
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(e1071)

# load data into data.frame (in this case we will be using the final_dataset_with_odds.csv)
final_data <- read.csv(file.choose(),header=T) 

# let's just keep the last five matches form and bookies info
final_data_reduced <- final_data %>%
  select(
    id =X, home = HomeTeam, away = AwayTeam, homeGoals = FTHG, awayGoals = FTAG, # information about the actual match
    HM1, HM2, HM3, AM1, AM2, AM3, # last three match result for home and away team 
    B365H, B365D, B365A, IWH, IWD, IWA, LBH, LBD, LBA, WHH, WHD, WHA # bookies info
  ) %>%
  # mutate(across(c(6:15), str_replace, 'M', NA_character_)) %>% # M means actually NA
  mutate(across(c(2:3, 6:11), factor)) %>% # convert columns to factors
  mutate(FTR = case_when(homeGoals < awayGoals ~ as.factor("L"),
                         homeGoals > awayGoals ~ as.factor("W"),
                         homeGoals == awayGoals ~ as.factor("D"))) %>%
  select(-homeGoals,-awayGoals)

# Based on the team form and the bookies, we will try to predict the result of a match
set.seed(12) # make results reproducible

# First let's split the data into train and test
train <- final_data_reduced %>%
  sample_frac(0.75) # take 75% of the observations

test <- final_data_reduced %>%
  anti_join(train, by = "id") # take the rest of the observations

# Now let's fit the model
train <- train %>%
  select(-id) # remove the id column from the train dataset

test <- test %>%
  select(-id) # remove the id column from the test dataset

naive_bayes_model <- naiveBayes(FTR~., data=train)

naive_bayes_model # Print summary of the model

# let's create a confusion matrix for the train dataset
train %>%
  mutate(pred = predict(naive_bayes_model, train)) %>%
  select(FTR, pred) %>%
  table() 

# let's create a confusion matrix for the test dataset
test %>%
  mutate(pred = predict(naive_bayes_model, test)) %>%
  select(FTR, pred) %>%
  table() 

# We can see that the model is not really good at predicting draws
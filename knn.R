#Packages
library(dplyr)
library(tidyr)
library(stringr)
library(class)

# load data into data.frame (in this case we will be using the final_dataset_with_odds.csv)
final_data <- read.csv(file.choose(),header=T) 

# let's just keep numeric info (the bookies)
final_data_reduced <- final_data %>%
  select(
    id =X, home = HomeTeam, away = AwayTeam, homeGoals = FTHG, awayGoals = FTAG, # information about the actual match
    B365H, B365D, B365A, IWH, IWD, IWA, LBH, LBD, LBA, WHH, WHD, WHA # bookies info
  ) %>%
  mutate(across(c(2:3), factor)) %>% # convert columns to factors
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

# Scale the numeric observations to use them to fit the model
train_scale <- scale(train[, 4:15]) 
test_scale <- scale(test[, 4:15])

# Fit the model
knn_model <- knn(train = train_scale, 
                      test = test_scale, 
                      cl = train$FTR, 
                      k = 1) 

# Print the model
knn_model

# Create the confusion matrix
table(test$FTR, knn_model)

# Model evaluation for choosing k
mean(knn_model==test$FTR)

# K = 3

knn_model <- knn(train = train_scale, 
                 test = test_scale, 
                 cl = train$FTR, 
                 k = 3) 

# Print the model
knn_model

# Create the confusion matrix
table(test$FTR, knn_model)

# Model evaluation for choosing k i.e. accuracy
mean(knn_model==test$FTR)

# K = 5

knn_model <- knn(train = train_scale, 
                 test = test_scale, 
                 cl = train$FTR, 
                 k = 5) 

# Print the model
knn_model

# Create the confusion matrix
table(test$FTR, knn_model)

# Model evaluation for choosing k i.e. accuracy
mean(knn_model==test$FTR)

# K = 7

knn_model <- knn(train = train_scale, 
                 test = test_scale, 
                 cl = train$FTR, 
                 k = 7) 

# Print the model
knn_model

# Create the confusion matrix
table(test$FTR, knn_model)

# Model evaluation for choosing k i.e. accuracy
mean(knn_model==test$FTR)

# K = 15

knn_model <- knn(train = train_scale, 
                 test = test_scale, 
                 cl = train$FTR, 
                 k = 15) 

# Print the model
knn_model

# Create the confusion matrix
table(test$FTR, knn_model)

# Model evaluation for choosing k i.e. accuracy
mean(knn_model==test$FTR)

# K = 19

knn_model <- knn(train = train_scale, 
                 test = test_scale, 
                 cl = train$FTR, 
                 k = 19) 

# Print the model
knn_model

# Create the confusion matrix
table(test$FTR, knn_model)

# Model evaluation for choosing k i.e. accuracy
mean(knn_model==test$FTR)

# In this case, the accuracy is maximized when k = 19
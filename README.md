# Predicting soccer outcomes with R

This repo aims to provide practical examples of how some statistical models can be applied to predicting soccer outcomes. That being stated, this repo does not contain formal proof or evidence of why the models can be implemented or if they could be accurate at predicting said soccer outcomes.

## Data sources

The datasets were obtained from the following links:

PL-2022-23: https://www.football-data.co.uk/englandm.php

Notes for Football Data: https://www.football-data.co.uk/notes.txt

final_dataset_with_odds: https://www.kaggle.com/datasets/louischen7/football-results-and-betting-odds-data-of-epl/?select=final_dataset_with_odds.csv

## Exploratory analysis

Before even thinking about adjusting any model, let's try to create some simple graphs to get familiar with the datasets. All code relevant to these graphs can be found in the `explanatory_analysis.R` file. The data considered for this section is from the 2022/23 season of the English Premier League.

### Goals analysis

Mean goals scored per home team:

![Mean goals scored per home team](pictures/mean_goals_scored_per_home_team.png)

Mean goals scored per away team:

![Mean goals scored per away team](pictures/mean_goals_scored_per_away_team.png)

Proportion of matches with different number of home goals:

![Goals scored per home team](pictures/home_goals_per_match.png)

Proportion of matches with different number of away goals:

![Goals scored per away team](pictures/away_goals_per_match.png)

### Corner analysis

Proportion of matches with different number of corners:

![Corners per home team](pictures/home_corners_per_match.png)

Proportion of matches with different number of corners:

![Corners per away team](pictures/away_corners_per_match.png)

## Models

### Logistic regression

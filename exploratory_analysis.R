#Packages
library(dplyr)
library(tidyr)
library(ggplot2)

# load data into data.frame (in this case we will be using PL 2022/23)
epl_data <- read.csv(file.choose(),header=T)

# ggplot theme used for plots
my_post_theme <- 
  theme_minimal() +
  theme(axis.text.x = element_text(face="bold", color="#666666", 
                                   size=10, margin = margin(t = -5)),
        axis.title = element_text(color="black", face="bold",size=12),
        plot.title = element_text(color="black", face="bold", size=14),
        axis.text.y = element_text(face="bold", color="#666666", 
                                   size=10),
        legend.text=element_text(size=12),
        legend.title=element_text(size=13),
        legend.key=element_blank(),
        axis.ticks.length=unit(0, "cm"))

# let's make an exploratory analysis of the goals
epl_data_goals <- epl_data %>%
                    select(home = HomeTeam, away = AwayTeam, homeGoals = FTHG, awayGoals = FTAG)


# mean goals scored per team
bind_rows(list(
epl_data_goals, 
epl_data_goals %>%
  rename(home = away, away = home, homeGoals = awayGoals, awayGoals = homeGoals)
)) %>%
  group_by(home) %>% 
  summarize(actual=sum(homeGoals)/n()) %>%
  ggplot(aes(x=as.factor(home))) + 
  geom_bar(aes(y=actual, x=as.factor(home)),stat="identity",position="dodge", fill = "#20B2AA") +
  ggtitle("Mean goals scored per team (EPL 2022/23 Season)")  + 
  xlab("Goals per Match") + 
  ylab("Proportion of Matches") +
  my_post_theme

# mean goals scored per home team
epl_data_goals %>% 
  group_by(home) %>% 
  summarize(actual=sum(homeGoals)/n()) %>%
  ggplot(aes(x=as.factor(home))) + 
  geom_bar(aes(y=actual, x=as.factor(home)),stat="identity",position="dodge", fill = "#FFA07A") +
  ggtitle("Mean goals scored per home team (EPL 2022/23 Season)")  + 
  xlab("Goals per Match") + 
  ylab("Proportion of Matches") +
  my_post_theme

# mean goals received as home team
epl_data_goals %>% 
  group_by(home) %>% 
  summarize(actual=sum(awayGoals)/n()) %>%
  ggplot(aes(x=as.factor(home))) + 
  geom_bar(aes(y=actual, x=as.factor(home)),stat="identity",position="dodge", fill = "#006400") +
  ggtitle("Mean goals received per home team (EPL 2022/23 Season)")  + 
  xlab("Goals per Match") + 
  ylab("Proportion of Matches") +
  my_post_theme

# mean goals scored per away team
epl_data_goals %>% 
  group_by(away) %>% 
  summarize(actual=sum(awayGoals)/n()) %>%
  ggplot(aes(x=as.factor(away))) + 
  geom_bar(aes(y=actual, x=as.factor(away)),stat="identity",position="dodge", fill = "#FFA07A") +
  ggtitle("Mean goals per away team (EPL 2022/23 Season)")  + 
  xlab("Goals per Match") + 
  ylab("Proportion of Matches") +
  my_post_theme

# mean goals received as away team
epl_data_goals %>% 
  group_by(away) %>% 
  summarize(actual=sum(homeGoals)/n()) %>%
  ggplot(aes(x=as.factor(away))) + 
  geom_bar(aes(y=actual, x=as.factor(away)),stat="identity",position="dodge", fill = "#006400") +
  ggtitle("Mean goals received per away team (EPL 2022/23 Season)")  + 
  xlab("Goals per Match") + 
  ylab("Proportion of Matches") +
  my_post_theme

# actual observed results for home goals scored
epl_data_goals %>% 
  group_by(homeGoals) %>% 
  summarize(actual=n()/nrow(.)) %>%
  ggplot(aes(x=as.factor(homeGoals))) + 
  geom_bar(aes(y=actual, x=as.factor(homeGoals)),stat="identity",position="dodge", fill = "#006400") +
  ggtitle("Number of home goals per Match (EPL 2022/23 Season)")  + 
  xlab("Goals per Match") + 
  ylab("Proportion of Matches") +
  my_post_theme


# actual observed results for away goals scored
epl_data_goals %>% 
  group_by(awayGoals) %>% 
  summarize(actual=n()/nrow(.)) %>%
  ggplot(aes(x=as.factor(awayGoals))) + 
  geom_bar(aes(y=actual, x=as.factor(awayGoals)),stat="identity",position="dodge", fill = "#20B2AA") +
  ggtitle("Number of away goals per Match (EPL 2022/23 Season)")  + 
  xlab("Goals per Match") + 
  ylab("Proportion of Matches") +
  my_post_theme

# Distribution of the goals compared to a Poisson distribution

bind_rows(list(
  epl_data_goals %>% group_by(homeGoals) %>% summarize(actual=n()/nrow(.)) %>% ungroup() %>% 
    complete(data.frame(homeGoals = 0:max(max(epl_data_goals$homeGoals),max(epl_data_goals$awayGoals))), fill = list(actual = 0)) %>% # to fill out when there are no matches with 8 goals but there are with 9
    mutate(pred=dpois(0:max(max(epl_data_goals$homeGoals),max(epl_data_goals$awayGoals)), 
                      mean(epl_data_goals$homeGoals)), type="home") %>% rename(goals=homeGoals),
  epl_data_goals %>% group_by(awayGoals) %>% summarize(actual=n()/nrow(.)) %>% ungroup() %>% 
    complete(data.frame(awayGoals = 0:max(max(epl_data_goals$homeGoals),max(epl_data_goals$awayGoals))), fill = list(actual = 0)) %>% # to fill out when there are no matches with 8 goals but there are with 9
    mutate(pred=dpois(0:max(max(epl_data_goals$homeGoals),max(epl_data_goals$awayGoals)),
                      mean(epl_data_goals$awayGoals)), type="away") %>% rename(goals=awayGoals)
  )) %>%
  mutate(type=factor(type, levels=c("home", "away"), labels = c("Home", "Away"))) %>%
  ggplot(aes(x=as.factor(goals))) + 
  geom_bar(aes(y=actual,fill=type),stat="identity",position="dodge") +
  geom_line(aes(group=type, y = pred,color=type),linewidth=1.25)  +
  #  scale_fill_manual(values=c("#FFA07A", "#20B2AA"))  +
  scale_fill_manual(values=c("#FFA07A", "#20B2AA"), 
                    name = "Actual",
                    guide = guide_legend(override.aes = list(linetype = c(0,1)))) +
  scale_color_manual(values=c("#CD5C5C", "#006400"),
                     name="Poisson")  +
  ggtitle("Number of Goals per Match (EPL 2022/23 Season)")  + xlab("Goals per Match") + ylab("Proportion of Matches") +
  my_post_theme

# The Poisson distribution is a good approximation to the amount of goals scored







# let's make an exploratory analysis of the corners
epl_data_corners <- epl_data %>%
  select(home = HomeTeam, away = AwayTeam, homeCorners = HC, awayCorners = AC)

# mean number of corners per team
bind_rows(list(
  epl_data_corners, 
  epl_data_corners %>%
    rename(home = away, away = home, homeCorners = awayCorners, awayCorners = homeCorners)
)) %>%
  group_by(home) %>% 
  summarize(actual=sum(homeCorners)/n()) %>%
  ggplot(aes(x=as.factor(home))) + 
  geom_bar(aes(y=actual, x=as.factor(home)),stat="identity",position="dodge", fill = "#20B2AA") +
  ggtitle("Mean number of corners per team (EPL 2022/23 Season)")  + 
  xlab("Corners per Match") + 
  ylab("Proportion of Matches") +
  my_post_theme

# mean number of corners per home team
epl_data_corners %>% 
  group_by(home) %>% 
  summarize(actual=sum(homeCorners)/n()) %>%
  ggplot(aes(x=as.factor(home))) + 
  geom_bar(aes(y=actual, x=as.factor(home)),stat="identity",position="dodge", fill = "#FFA07A") +
  ggtitle("Mean number of corners per home team (EPL 2022/23 Season)")  + 
  xlab("Corners per Match") + 
  ylab("Proportion of Matches") +
  my_post_theme

# mean number of corners per away team
epl_data_corners %>% 
  group_by(away) %>% 
  summarize(actual=sum(awayCorners)/n()) %>%
  ggplot(aes(x=as.factor(away))) + 
  geom_bar(aes(y=actual, x=as.factor(away)),stat="identity",position="dodge", fill = "#006400") +
  ggtitle("Mean number of corners per away team (EPL 2022/23 Season)")  + 
  xlab("Corners per Match") + 
  ylab("Proportion of Matches") +
  my_post_theme

# actual observed proportions for home corners
epl_data_corners %>% 
  group_by(homeCorners) %>% 
  summarize(actual=n()/nrow(.)) %>%
  ggplot(aes(x=as.factor(homeCorners))) + 
  geom_bar(aes(y=actual, x=as.factor(homeCorners)),stat="identity",position="dodge", fill = "#006400") +
  ggtitle("Number of home corners per Match (EPL 2022/23 Season)")  + 
  xlab("Corners per Match") + 
  ylab("Proportion of Matches") +
  my_post_theme


# actual observed proportions for away goals scored
epl_data_corners %>% 
  group_by(awayCorners) %>% 
  summarize(actual=n()/nrow(.)) %>%
  ggplot(aes(x=as.factor(awayCorners))) + 
  geom_bar(aes(y=actual, x=as.factor(awayCorners)),stat="identity",position="dodge", fill = "#20B2AA") +
  ggtitle("Number of away corners per Match (EPL 2022/23 Season)")  + 
  xlab("Corners per Match") + 
  ylab("Proportion of Matches") +
  my_post_theme

# Distribution of the corners compared to a Poisson distribution

bind_rows(list(
  epl_data_corners %>% group_by(homeCorners) %>% summarize(actual=n()/nrow(.)) %>% ungroup() %>% 
    complete(data.frame(homeCorners = 0:max(max(epl_data_corners$homeCorners),max(epl_data_corners$awayCorners))), fill = list(actual = 0)) %>% # to fill out when there are no matches with 8 goals but there are with 9
    mutate(pred=dpois(0:max(max(epl_data_corners$homeCorners),max(epl_data_corners$awayCorners)), 
                      mean(epl_data_corners$homeCorners)), type="home") %>% rename(corners=homeCorners),
  epl_data_corners %>% group_by(awayCorners) %>% summarize(actual=n()/nrow(.)) %>% ungroup() %>% 
    complete(data.frame(awayCorners = 0:max(max(epl_data_corners$homeCorners),max(epl_data_corners$awayCorners))), fill = list(actual = 0)) %>% # to fill out when there are no matches with 8 goals but there are with 9
    mutate(pred=dpois(0:max(max(epl_data_corners$homeCorners),max(epl_data_corners$awayCorners)),
                      mean(epl_data_corners$awayCorners)), type="away") %>% rename(corners=awayCorners)
)) %>%
  mutate(type=factor(type, levels=c("home", "away"), labels = c("Home", "Away"))) %>%
  ggplot(aes(x=as.factor(corners))) + 
  geom_bar(aes(y=actual,fill=type),stat="identity",position="dodge") +
  geom_line(aes(group=type, y = pred,color=type),linewidth=1.25)  +
  #  scale_fill_manual(values=c("#FFA07A", "#20B2AA"))  +
  scale_fill_manual(values=c("#FFA07A", "#20B2AA"), 
                    name = "Actual",
                    guide = guide_legend(override.aes = list(linetype = c(0,1)))) +
  scale_color_manual(values=c("#CD5C5C", "#006400"),
                     name="Poisson")  +
  ggtitle("Number of Corners per Match (EPL 2022/23 Season)")  + xlab("Corners per Match") + ylab("Proportion of Matches") +
  my_post_theme
############################################################
# 04_clean_esports_team_performance.R
#
# Goal (MY part of project):
#   - Clean the Kaggle Esports_data.xlsx file
#   - Make variable names clear and useful for analysis
#   - Save a clean CSV to:
#       data/esports_team_performance_clean.csv
############################################################
pacman::p_load(tidyverse,readxl)

esports_team_raw <- read_excel("data/Esports_data.xlsx")

glimpse(esports_team_raw)

esports_team_clean <- esports_team_raw %>%
  rename(
    team_id= ID,  
    season_index = Y,    
    training_hours_per_week = TN_H,
    experience_years = EXP,
    age_years = AGE,
    budget_usd= BUD,
    tournaments_played = TOU,
    win_rate= WIN,  
    performance_score = PER
  ) %>%
  mutate(
    season_index    = as.integer(season_index),
    team_id         = as.integer(team_id),
    win_rate_pct    = win_rate * 100,              
    budget_k_usd    = budget_usd / 1000            
  ) %>%
  arrange(team_id, season_index)

glimpse(esports_team_clean)

write_csv(esports_team_clean, "data/esports_team_performance_clean.csv")

message("Saved clean team performance data to: data/esports_team_performance_clean.csv")

read_csv("data/esports_team_performance_clean.csv") %>% glimpse()


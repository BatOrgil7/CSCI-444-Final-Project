############################################################
# 05_clean_general_esport_games.R
#
# Goal (MY part of project):
#   - Clean the Kaggle GeneralEsportData.csv file
#   - Standardize column names and create helper variables
#   - Save a clean CSV to:
#       data/general_esport_games_clean.csv
############################################################

pacman::p_load(tidyverse)

games_raw <- read_csv("data/GeneralEsportData.csv")

glimpse(games_raw)

games_clean <- games_raw %>%
  rename(
    game                = Game,
    release_year        = ReleaseDate,
    genre               = Genre,
    total_earnings_usd  = TotalEarnings,
    offline_earnings_usd = OfflineEarnings,
    percent_offline     = PercentOffline,  
    total_players       = TotalPlayers,
    total_tournaments   = TotalTournaments
  ) %>%
  mutate(
    online_earnings_usd = total_earnings_usd - offline_earnings_usd,
    offline_share       = offline_earnings_usd / total_earnings_usd,  # 0-1
    game_age_years      = 2025 - release_year   # adjust year if you want
  ) %>%
  arrange(desc(total_earnings_usd))

glimpse(games_clean)


write_csv(games_clean, "data/general_esport_games_clean.csv")

message("Saved clean game-level data to: data/general_esport_games_clean.csv")

############################################################
# 02_clean_esports_players.R
#
# Goal for MY part of the project:
#   - Take the raw scraped table of Top 1000 players
#   - Clean column names and convert money / percentages
#   - Save a clean version to:
#       data/esports_players_top1000_clean.csv
############################################################
pacman::p_load(tidyverse)

players_raw <- read_csv("data/esports_players_top1000_raw.csv")

glimpse(players_raw)

#clean column names and convert types

players_clean <- players_raw %>%
  #rename columns to clear, consistent names
  rename(
    rank = `Â`,           
    player_id = `Player ID`,
    player_name = `Player Name`,
    total_overall = `Total (Overall)`,
    highest_paying_game = `Highest Paying Game`,
    total_game = `Total (Game)`,
    pct_of_total = `% of Total`
  ) %>%
  #convert strings with $, commas, % into numeric
  mutate(
    rank= as.integer(rank),
    total_overall_usd = parse_number(total_overall),
    total_game_usd= parse_number(total_game),
    pct_of_total_num = parse_number(pct_of_total)  # 0–100 scale
  ) %>%
  #keep only the columns we really need for analysis
  select(
    rank,
    player_id,
    player_name,
    highest_paying_game,
    total_overall_usd,
    total_game_usd,
    pct_of_total_num,
    source_url
  ) %>%
  arrange(rank)

glimpse(players_clean)

write_csv(players_clean, "data/esports_players_top1000_clean.csv")

message("Saved clean Top 1000 players data to: data/esports_players_top1000_clean.csv")


clean_players <- read_csv("data/esports_players_top1000_clean.csv")
glimpse(clean_players)

############################################################
# Goal for MY part of the project:
#   - Scrape the "Highest Overall Earnings" player rankings
#     from EsportsEarnings.
#   - Collect all players from rank 1 to 1000.
#   - Save the raw (uncleaned) table to:
#       data/esports_players_top1000_raw.csv
############################################################

pacman::p_load(tidyverse,rvest)

#create data/ folder if it does not exist
if (!dir.exists("data")) {
  dir.create("data")
}

output_file <- "data/esports_players_top1000_raw.csv"

player_urls <- c(
  "https://www.esportsearnings.com/players/highest-earnings",
  "https://www.esportsearnings.com/players/highest-earnings-top-200",
  "https://www.esportsearnings.com/players/highest-earnings-top-300",
  "https://www.esportsearnings.com/players/highest-earnings-top-400",
  "https://www.esportsearnings.com/players/highest-earnings-top-500",
  "https://www.esportsearnings.com/players/highest-earnings-top-600",
  "https://www.esportsearnings.com/players/highest-earnings-top-700",
  "https://www.esportsearnings.com/players/highest-earnings-top-800",
  "https://www.esportsearnings.com/players/highest-earnings-top-900",
  "https://www.esportsearnings.com/players/highest-earnings-top-1000"
)


#read_html() -> html_elements("table") -> html_table()

scrape_players_page <- function(url) {
  message("Scraping: ", url)
  
  page <- read_html(url)
  
  # get all tables on the page
  all_tables <- page %>%
    html_elements("table") %>%
    html_table(fill = TRUE)
  
  # choose the table with the largest number of rows.
  # on these pages, that is the big rankings table.
  n_rows <- sapply(all_tables, nrow)
  
  # check:if there are no tables, return empty tibble
  if (length(n_rows) == 0) {
    warning("No tables found on page: ", url)
    return(tibble())
  }
  
  players_tbl <- all_tables[[which.max(n_rows)]]

  players_tbl <- players_tbl %>%
    mutate(source_url = url)
  
  return(players_tbl)
}

# scrape all pages (1–1000) and combine 

players_top1000_raw <- player_urls %>%
  map_dfr(scrape_players_page)

glimpse(players_top1000_raw)

write_csv(players_top1000_raw, output_file)

message("Saved raw Top 1000 players data to: ", output_file)

players_top1000_raw
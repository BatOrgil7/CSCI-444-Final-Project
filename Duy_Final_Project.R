if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman", repos = "https://cloud.r-project.org")
pacman::p_load(tidyverse,rvest,xml2,dplyr,stringr,readr)

get_page_urls <- function(base_url) {
  page <- read_html(base_url)
  a <- html_elements(page, "a")
  txt <- html_text2(a)
  href <- html_attr(a, "href")
  # Collect the "Top 100, 200, ..., 1000" links if present
  wanted <- as.character(seq(100, 1000, by = 100))
  idx <- which(txt %in% wanted)
  urls <- if (length(idx)) xml2::url_absolute(href[idx], base_url) else character()
  unique(c(base_url, urls))
}

normalize_quotes <- function(x) {
  # Normalize smart quotes and dashes to ASCII counterparts
  x %>%
    str_replace_all("[\u2018\u2019]", "'") %>%
    str_replace_all("[\u201C\u201D]", '"') %>%
    str_replace_all("\u2013|\u2014", "-")
}

scrape_top1000_css <- function() {
  base_url <- "https://www.esportsearnings.com/players/highest-earnings"
  urls <- get_page_urls(base_url)
  message("Fetching ", length(urls), " page(s)...")
  
  scrape_one <- function(url) {
    message("  -> ", url)
    doc <- read_html(url)
    rows <- html_elements(doc, "table.detail_list_table tbody tr")
    res <- lapply(rows, function(r) {
      rank_txt <- html_text2(html_element(r, "td:nth-child(1)"))
      player_id_txt <- html_text2(html_element(r, "td:nth-child(2) a[href*='/players/']"))
      player_name_txt <- html_text2(html_element(r, "td:nth-child(3) a"))
      total_overall_txt <- html_text2(html_element(r, "td:nth-child(4)"))
      highest_game_txt <- html_text2(html_element(r, "td:nth-child(5) a"))
      total_game_txt <- html_text2(html_element(r, "td:nth-child(6)"))
      percent_txt <- html_text2(html_element(r, "td:nth-child(7)"))
      
      rank_val <- parse_number(rank_txt)
      if (is.na(rank_val)) return(NULL)
      
      tibble::tibble(
        rank = rank_val,
        player_id = normalize_quotes(player_id_txt),
        player_name = normalize_quotes(player_name_txt),
        highest_paying_game = normalize_quotes(highest_game_txt),
        total_overall_usd = parse_number(total_overall_txt, locale = locale(grouping_mark = ",")),
        total_in_game_usd = parse_number(total_game_txt, locale = locale(grouping_mark = ",")),
        percent_of_total = parse_number(percent_txt)
      )
    })
    dplyr::bind_rows(res)
  }
  
  bind_rows(lapply(urls, scrape_one)) %>%
    arrange(rank) %>%
    distinct(rank, .keep_all = TRUE) %>%
    filter(!is.na(rank))
}

dir.create("data", showWarnings = FALSE, recursive = TRUE)
esports_top1000 <- scrape_top1000_css()
output_path <- file.path("data", "esports_highest_earnings_top1000.csv")
write_csv(esports_top1000, output_path)
message("Wrote ", nrow(esports_top1000), " rows to ", output_path)



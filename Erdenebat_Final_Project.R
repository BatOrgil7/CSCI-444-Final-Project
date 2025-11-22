library(rvest)
library(dplyr)
library(purrr)
library(stringr)

scrape_state_table <- function(state_abbr = "AL") {
  tryCatch({
    url <- paste0("https://www.onetonline.org/link/localwages/15-1252.00?st=", state_abbr)
    
    cat("Scraping", state_abbr, "\n")
    
    page <- read_html(url)
    
    table_node <- page %>%
      html_node("table.tablesorter.tablesorter-bootstrap.table-responsive-md.w-100.table-fluid")
    
    if (!is.null(table_node)) {
      salary_table <- html_table(table_node, fill = TRUE)
      salary_table$State <- state_abbr
      salary_table$State_Name <- state.name[match(state_abbr, state.abb)]
      
      return(salary_table)
    } else {
      cat("Table not found for", state_abbr, "\n")
      return(NULL)
    }
    
  }, error = function(e) {
    cat("Error scraping", state_abbr, ":", e$message, "\n")
    return(NULL)
  })
}

all_states <- c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
                "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
                "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", 
                "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
                "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY")

html_tables <- list()

for (i in seq_along(all_states)) {
  state <- all_states[i]
  cat("Processing", i, "of", length(all_states), "-", state, "\n")
  
  table_data <- scrape_state_table(state)
  if (!is.null(table_data) && nrow(table_data) > 0) {
    html_tables[[state]] <- table_data
  }
  
  Sys.sleep(1)
}

if (length(html_tables) > 0) {
  combined_html_data <- bind_rows(html_tables)
  
  cat("Successfully scraped", length(html_tables), "states\n")
  cat("Total records:", nrow(combined_html_data), "\n")
  
  cat("\nData structure:\n")
  print(str(combined_html_data))
  
  write_csv(combined_html_data, "data/software_salaries_html_tables.csv")
  cat("Data saved to 'data/software_salaries_html_tables.csv'\n")
  
} else {
  cat("No HTML tables were successfully scraped\n")
}

### DATA CLEANING ###

library(dplyr)
library(tidyr)
library(stringr)
library(knitr)

salaries <- read.csv("data/software_salaries_html_tables.csv", stringsAsFactors = FALSE)

cleaned_salaries <- salaries %>%

  mutate(
    P10 = as.numeric(gsub("[$,]", "", Annual.Low..10..)),
    P25 = as.numeric(gsub("[$,]", "", Annual.QL..25..)),
    Median = as.numeric(gsub("[$,]", "", Annual.Median..50..)),
    P75 = as.numeric(gsub("[$,]", "", Annual.QU..75..)),
    P90 = as.numeric(gsub("[$,]", "", Annual.High..90..)),
    Location = str_trim(Location),
    Location_Type = case_when(
      Location == "United States" ~ "National",
      Location == State_Name ~ "Statewide",
      grepl("nonmetropolitan", Location, ignore.case = TRUE) ~ "Non-metropolitan",
      TRUE ~ "Metropolitan"
    )
  ) %>%
  
  select(Location, Location_Type, State, State_Name, P10, P25, Median, P75, P90)

cat("Cleaned Data Structure:\n")
str(cleaned_salaries)

cat("\nFirst 10 rows of cleaned data:\n")
head(cleaned_salaries, 10) %>% kable(digits = 0)

statewide_summary <- cleaned_salaries %>%
  filter(Location_Type == "Statewide") %>%
  select(State, State_Name, P10, P25, Median, P75, P90) %>%
  mutate(state = State) %>%       
  arrange(desc(Median))

cat("Table 1: Statewide Software Engineering Salaries (Ordered by Median)\n")
kable(statewide_summary, digits = 0)

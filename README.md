# CSCI 444 – Final Project (Group 9)
**Topic:** Esports Professionals vs. Software Engineers  

This repository contains the code and data for Group 9’s final project in CSCI 444.  
The project compares career patterns and earnings of **esports professionals** and **software engineers**.

---

## Duy Nguyen – Esports Section

This part of the project focuses on **esports players and games**:

- Scraped the **Top 1000 highest-earning players** from  
  `https://www.esportsearnings.com/players/highest-earnings`.
- Combined this with two Kaggle-based esports datasets:
  - Player / team age and experience  
    - *(Kaggle)*: [Esports team performance dataset](PASTE_KAGGLE_LINK_HERE_1)
  - Game-level earnings and release years  
    - *(Kaggle)*: [General esports games dataset](PASTE_KAGGLE_LINK_HERE_2)
- Cleaned all data using **tidyverse** and saved to `data/` as:
  - `esports_players_top1000_clean.csv`
  - `esports_team_performance_clean.csv`
  - `general_esport_games_clean.csv`

Main questions answered in the Quarto report:

1. **Age & experience** – What does the age and experience distribution of esports professionals look like?  
2. **Game age & prize money** – Do older esports titles tend to generate more total prize money?  
3. **Concentration of earnings** – Which games dominate the income of the top 1000 players?

All analysis, visualisations, and narrative for the esports section are in:

- `Duy_Quarto_Esports.qmd`  
  - Renders to **HTML** and **PDF**  
  - Uses `code-fold`, `ggplot2`, `plotly`, and `kableExtra`

---

## How to Run (Esports Section)

1. Open the project in **RStudio**.  
2. Install required packages (once):

   ```r
   install.packages(c("pacman", "tidyverse", "rvest", "kableExtra", "plotly"))

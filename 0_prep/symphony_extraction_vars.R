# Symphony extraction - inputs
# msahu

# ------------------------------------------------------------------------------

# Setup

pacman::p_load(data.table, dplyr, readxl)

user_name = 'MS3390'

# Directory
if (Sys.info()["sysname"] == "Darwin") {
  # Mac
  dir <- paste0("/Users/", user_name, "/Library/CloudStorage/Dropbox/Partners HealthCare Dropbox/Maitreyi Sahu/projects/generic_entry/data/")
} else {
  # Windows
  dir <- paste0("C:/Users/", user_name, "/Partners HealthCare Dropbox/Maitreyi Sahu/projects/generic_entry/data/")
}

atc_names <- fread(paste0(dir, 'processed/atc/WHO_ATC_hierarchy_2024.csv'))
setnames(atc_names, "atc_code", "atc")

first_generic_agg <- read_excel(paste0(dir, 'First Generic Dates - New Ingredients Aggregated_9.19.2025.xlsx')) %>% 
  left_join(atc_names, by = 'atc')

# ------------------------------------------------------------------------------

# Time selection

start_date <- as.Date("2014-01-01")
end_date <- Sys.Date()
month_seq <- seq.Date(from = start_date, to = end_date, by = "month") - 1
month_list <- format(month_seq, "%Y-%m")

month_list

# ------------------------------------------------------------------------------

# Drug selection


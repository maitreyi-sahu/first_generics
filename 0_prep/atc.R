# Read and aggregate ATC
# msahu

# ------------------------------------------------------------------------------

# Setup

pacman::p_load(readxl, data.table, dplyr)

user_name = 'ms3390'

# Directory
if (Sys.info()["sysname"] == "Darwin") {
  # Mac
  dir <- paste0("/Users/", user_name, "/Library/CloudStorage/Dropbox/Partners HealthCare Dropbox/Maitreyi Sahu/projects/first_generics/data/")
} else {
  # Windows
  dir <- paste0("C:/Users/", user_name, "/Partners HealthCare Dropbox/Maitreyi Sahu/projects/first_generics/data/")
}

# Load ATC
dt <- fread(paste0(dir, "raw/atc/WHO ATC-DDD 2024-07-31.csv"))

# ------------------------------------------------------------------------------

# REFORMAT

# Add level
dt[, level := fcase(
  nchar(atc_code) == 1, 1L,
  nchar(atc_code) == 3, 2L,
  nchar(atc_code) == 4, 3L,
  nchar(atc_code) == 5, 4L,
  nchar(atc_code) == 7, 5L
)]

# Keep only level 5 rows
final <- dt[level == 5]

# Add parent codes
final[, `:=`(
  L1_code = substr(atc_code, 1, 1),
  L2_code = substr(atc_code, 1, 3),
  L3_code = substr(atc_code, 1, 4),
  L4_code = substr(atc_code, 1, 5)
)]

# Add parent names
final[, L1_name := dt[J(L1_code), on = .(atc_code), x.atc_name]]
final[, L2_name := dt[J(L2_code), on = .(atc_code), x.atc_name]]
final[, L3_name := dt[J(L3_code), on = .(atc_code), x.atc_name]]
final[, L4_name := dt[J(L4_code), on = .(atc_code), x.atc_name]]

# Title-case function
cap_first <- function(x) {
  ifelse(is.na(x), NA_character_,
         paste0(toupper(substr(x, 1, 1)), tolower(substr(x, 2, nchar(x)))))
}

# Apply to all names
cols <- c("atc_name", "L1_name", "L2_name", "L3_name", "L4_name")
final[, (cols) := lapply(.SD, cap_first), .SDcols = cols]

# Drop level column
final[, level := NULL]

# Reorder columns: hierarchy first, then level-5 code/name, then other vars
setcolorder(final, c("atc_code", "atc_name", "ddd", "uom", "adm_r", "note",
                     "L1_code", "L1_name",
                     "L2_code", "L2_name",
                     "L3_code", "L3_name",
                     "L4_code", "L4_name"
                     ))

# ------------------------------------------------------------------------------

# Save and clean up
write.csv(final, paste0(dir, 'processed/atc/WHO_ATC_hierarchy_2024.csv'), row.names = F)
rm(dt, final)

# Load required library
library(dplyr)

# Read the claims data
claims_data <- read.csv("claims_data.csv")

# Step 1: Categorize DxCodes
# Add a new column `DxCodes`
claims_data <- claims_data %>%
  mutate(
    DxCodes = case_when(
      # Diabetes
      grepl("^E08|^E09|^E10|^E11|^E13|^O24|^O99.81|", ICDDxCode) ~ "Diabetes",
      ICDDxCode %in% c("E89.1") ~ "Diabetes",
      
      # High Blood Pressure
      ICDDxCode %in% c("G93.2", "H40.05", "I20.89", "I21.B") ~ "High Blood Pressure",
      grepl("^I10|^I11|^I12|^I13|^I15|^I27.0|^I27.2|^I87.3|^I97.3|^K76.6|^O10|^O11|^O13|^O16|^P29.2|^R03.0", ICDDxCode) ~ "High Blood Pressure",
      
      # COPD and Asthma
      grepl("^J41|^J42|^J43|^J44|^J45|^J47", ICDDxCode) ~ "COPD and Asthma",
      
      # Default
      TRUE ~ "Other"
    )
  )

# View the first few rows of the cleaned data
head(claims_data)

# Step 2: Check for "Other"
# Filter rows where DxCodes is "Other"
other_rows <- claims_data %>% filter(DxCodes == "Other")

# Print the number of rows categorized as "Other"
cat("Number of rows categorized as 'Other':", nrow(other_rows), "\n")

# View the first few rows of "Other" entries
head(other_rows)

# Step 3: Deduplicate Based on Min Sequence
# Remove duplicate ClaimIDs by keeping the row with the lowest ICDDxCodeSeq
claims_data_duplicate <- claims_data %>%
  group_by(ClaimID) %>%                           # Group by ClaimID
  filter(ICDDXCodeSeq == min(ICDDXCodeSeq)) %>%   # Keep rows with the minimum sequence
  ungroup()                                       # Ungroup the data

# Write results to a new CSV file (optional)
write.csv(claims_data_duplicate, "claims_data_cleaned.csv", row.names = FALSE)

# Install and load the openxlsx package
install.packages("openxlsx")
library(openxlsx)

# Export the deduplicated data to an Excel file
write.xlsx(claims_data_duplicate, "processed_claims_data.xlsx")




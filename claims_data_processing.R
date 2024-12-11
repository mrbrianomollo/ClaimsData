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
      str_detect(ICDDxCode, "^E08") ~ "Diabetes",
      str_detect(ICDDxCode, "^E09") ~ "Diabetes",
      str_detect(ICDDxCode, "^E10") ~ "Diabetes",
      str_detect(ICDDxCode, "^E11") ~ "Diabetes",
      str_detect(ICDDxCode, "^E13") ~ "Diabetes",
      ICDDxCode == "E89.1" ~ "Diabetes",
      str_detect(ICDDxCode, "^O24") ~ "Diabetes",
      str_detect(ICDDxCode, "^O99.81") ~ "Diabetes",
      
      # High Blood Pressure
      ICDDxCode == "G93.2" ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^H40.05") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^I10") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^I11") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^I12") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^I13") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^I15") ~ "High Blood Pressure",
      ICDDxCode == "I20.89" ~ "High Blood Pressure",
      ICDDxCode == "I21.B" ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^I27.0") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^I27.2") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^I87.3") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^I97.3") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^K76.6") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^O10") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^O11") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^O13") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^O16") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^P29.2") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^P29.30") ~ "High Blood Pressure",
      str_detect(ICDDxCode, "^R03.0") ~ "High Blood Pressure",
      
      # COPD and Asthma
      str_detect(ICDDxCode, "^J41") ~ "COPD and Asthma",
      str_detect(ICDDxCode, "^J42") ~ "COPD and Asthma",
      str_detect(ICDDxCode, "^J43") ~ "COPD and Asthma",
      str_detect(ICDDxCode, "^J44") ~ "COPD and Asthma",
      str_detect(ICDDxCode, "^J45") ~ "COPD and Asthma",
      str_detect(ICDDxCode, "^J47") ~ "COPD and Asthma",
      
      # Default
      TRUE ~ "Other"
    )
  )

# Check for DxCodes 'Other'
unmatched_codes <- claims_data %>%
  filter(DxCodes == "Other") %>%
  select(ICDDxCode) %>%
  distinct()

head(unmatched_codes)

# Step 2: Convert Columns
# List of currency columns
currency_columns <- c(
  "CheckAmt", "TotalAllowedAmt", "TotalChargeAmt", "TotalCOBAmt", 
  "TotalCoPayAmt", "TotalDeductibleAmt", "TotalPaidAllowedAmt", 
  "TotalPaidCOBAmt", "TotalPlanPaidAmt", "TotalMemPayAmt"
)

# Clean and convert currency columns to numeric
claims_data <- claims_data %>%
  mutate(across(all_of(currency_columns), ~ as.numeric(gsub("[$,]", "", .))))

# List of date columns
date_columns <- c(
  "ClaimReceivedDate", "IpAdmitDate", "IPDischargeDate", 
  "MaxLineThruDate", "MinLineFromDate", "OriginalEOBDate", 
  "PayDate", "ServiceDate"
)

# Convert date columns to Date type
claims_data <- claims_data %>%
  mutate(across(all_of(date_columns), ~ as.Date(., format = "%m/%d/%y")))

# List of month-year columns
month_year_columns <- c("PayMonth", "ServiceMonth")

# Remove NULL values and convert month-year columns to numeric
claims_data <- claims_data %>%
  mutate(across(all_of(month_year_columns), ~ ifelse(is.null(.), NA, .))) %>%
  mutate(across(all_of(month_year_columns), ~ as.numeric(.)))

# Convert CheckNumber to numeric
claims_data <- claims_data %>%
  mutate(
    CheckNumber = as.numeric(CheckNumber)
  )

# Step 3: Remove duplicate Based on Min Sequence
# Remove duplicate ClaimIDs by keeping the row with the lowest ICDDxCodeSeq
claims_data_duplicate <- claims_data %>%
  group_by(ClaimID) %>%                           # Group by ClaimID
  filter(ICDDXCodeSeq == min(ICDDXCodeSeq)) %>%   # Keep rows with the minimum sequence
  ungroup()                                       # Ungroup the data

# Write results to a new CSV file
write.csv(claims_data_duplicate, "claims_data_cleaned.csv", row.names = FALSE)

# Install and load the writexl package
install.packages("writexl")
library(writexl)

# Export the duplicate data to an Excel file
write_xlsx(claims_data_duplicate, "processed_claims_data.xlsx")


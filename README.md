# Healthcare Claims Analysis: Insights for a Healthcare Insurance Payer
## Project Overview
This project focuses on analyzing healthcare claims data to provide actionable insights into cost distribution, claim counts, and patterns in diagnoses. It aims to help healthcare insurance payers better understand claims trends, enabling data-driven decisions to optimize resource allocation and improve coverage efficiency.
## Dataset
The dataset consists of:
- **Claim Details**: Unique Claim IDs, Claim Types (Inpatient, Outpatient, ER), and associated statuses.
- **Diagnosis Codes**: ICDDxCodes with sequence information.
- **Financial Metrics**: Costs, allowed amounts, co-payments, plan-paid amounts, and member payments.
- **Categorization Variables**: FileSource (Medical and Behavioral Health).
## Objectives
1. Categorize claims by diagnosis:
   - **Diabetes**
   - **High Blood Pressure**
   - **COPD and Asthma**
   - **Other**
2. Deduplicate claims using ICDDxCodeSeq.
3. Analyze:
   - Total costs and claims count.
   - Diagnosis percentages by Medical and Behavioral Health claims.
   - Inpatient, Outpatient, and ER claim trends.
## Processing Steps
### Data Cleaning and Categorization in R
1. **Categorization of Diagnoses**:
   Diagnosis codes were grouped into predefined categories using regular expressions.
   ```r
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
2. **Convert Currency Columns**
   Remove non-numeric characters (like $ or,) and convert them to numeric.
   ```r
   # List of currency columns
   currency_columns <- c(
     "CheckAmt", "TotalAllowedAmt", "TotalChargeAmt", "TotalCOBAmt", "TotalCoPayAmt", "TotalDeductibleAmt", "TotalPaidAllowedAmt", "TotalPaidCOBAmt", "TotalPlanPaidAmt", "TotalMemPayAmt"
   )

   # Clean and convert currency columns to numeric
   claims_data <- claims_data %>%
     mutate(across(all_of(currency_columns), ~ as.numeric(gsub("[$,]", "", .))))      
   
3. **Convert Date Columns**
   Ensure all date columns are converted to Date type.
   ```r
   # List of date columns
   date_columns <- c(
     "ClaimReceivedDate", "IpAdmitDate", "IPDischargeDate", "MaxLineThruDate", "MinLineFromDate", "OriginalEOBDate", "PayDate", "ServiceDate"
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

4. **Convert CheckNumber column to numeric
   ```r
   # Convert CheckNumber to numeric
   claims_data <- claims_data %>%
     mutate(
       CheckNumber = as.numeric(CheckNumber)
     )
5. **Remove Duplicates**
   Duplicate Claim IDs were removed, retaining only the record with the lowest sequence number.
   ```r
    # Remove duplicate ClaimIDs by keeping the row with the lowest ICDDxCodeSeq
   claims_data_duplicate <- claims_data %>%
     group_by(ClaimID) %>%                           # Group by ClaimID
     filter(ICDDXCodeSeq == min(ICDDXCodeSeq)) %>%   # Keep rows with the minimum sequence
     ungroup()                                       # Ungroup the data

6. **Export data to CSV and Excel**
   Processed data was exported to Excel for pivot table analysis and visualization.
   ```r
   # Write results to a new CSV file
   write.csv(claims_data_duplicate, "claims_data_cleaned.csv", row.names = FALSE)

   # Install and load the writexl package
   install.packages("writexl")
   library(writexl)

   # Export the duplicate data to an Excel file
   write_xlsx(claims_data_duplicate, "processed_claims_data.xlsx")

## Key Analysis
1. **Claims Cost**:
   - Distribution of costs across diagnoses and categories (Medical vs. Behavioral Health).
   - Insights into cost patterns by Inpatient, Outpatient, and ER claims.

2. **Claims Count**:
   - Total claims count for each diagnosis.
   - Percentages relative to total claims.

3. **Conclusion**
   
## Technologies Used
- **R**: Data cleaning and preparation.
- **Excel**: Pivot table creation and visualization.






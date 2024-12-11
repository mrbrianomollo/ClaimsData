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

4. **Remove Duplicates**
   Duplicate Claim IDs were removed, retaining only the record with the lowest sequence number.
   ```r
    # Remove duplicate ClaimIDs by keeping the row with the lowest ICDDxCodeSeq
   claims_data_duplicate <- claims_data %>%
     group_by(ClaimID) %>%                           # Group by ClaimID
     filter(ICDDXCodeSeq == min(ICDDXCodeSeq)) %>%   # Keep rows with the minimum sequence
     ungroup()                                       # Ungroup the data

5. **Export data to CSV and Excel**
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






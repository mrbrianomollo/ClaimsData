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
   claims_data <- claims_data %>%
     mutate(
       DxCodes = case_when(
         grepl("^E08|^E09|^E10|^E11|^E13|^O24|^O99.81", ICDDxCode) ~ "Diabetes",
         grepl("^I10|^I11|^I12|^I13|^I15|^I27.0|^I27.2|^I87.3|^I97.3|^K76.6|^O10|^O11|^O13|^O16|^P29.2|^R03.0", ICDDxCode) ~ "High Blood Pressure",
         grepl("^J41|^J42|^J43|^J44|^J45|^J47", ICDDxCode) ~ "COPD and Asthma",
         TRUE ~ "Other"
       )
     )
2. **Remove Duplicates**
   Duplicate Claim IDs were removed, retaining only the record with the lowest sequence number.
   ```r
   claims_data_duplicate <- claims_data %>%
    group_by(ClaimID) %>%
    filter(ICDDXCodeSeq == min(ICDDXCodeSeq)) %>%
    ungroup()
3. **Export data to Excel**
   Processed data was exported to Excel for pivot table analysis and visualization.
   ```r
   write.xlsx(claims_data_duplicate, "processed_claims_data.xlsx")

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






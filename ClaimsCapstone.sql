ALTER TABLE claims_data
ADD DxCodes VARCHAR(50);

UPDATE claims_data
SET DxCodes = CASE
-- Diabetes
    WHEN ICDDxCode LIKE 'E08%' THEN 'Diabetes'
    WHEN ICDDxCode LIKE 'E09%' THEN 'Diabetes'
    WHEN ICDDxCode LIKE 'E10%' THEN 'Diabetes'
    WHEN ICDDxCode LIKE 'E11%' THEN 'Diabetes'
    WHEN ICDDxCode LIKE 'E13%' THEN 'Diabetes'
	WHEN ICDDxCode = 'E89.1' THEN 'Diabetes'
    WHEN ICDDxCode LIKE 'O24%' THEN 'Diabetes'
    WHEN ICDDxCode LIKE 'O99.81%' THEN 'Diabetes'

-- High Blood Pressure
    WHEN ICDDxCode = 'G93.2' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'H40.05%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'I10%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'I11%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'I12%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'I13%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'I15%' THEN 'High Blood Pressure'
    WHEN ICDDxCode = 'I20.89' THEN 'High Blood Pressure'
    WHEN ICDDxCode = 'I21.B' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'I27.0%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'I27.2%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'I87.3%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'I97.3%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'K76.6%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'O10%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'O11%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'O13%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'O16%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'P29.2%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'P29.30%' THEN 'High Blood Pressure'
    WHEN ICDDxCode LIKE 'R03.0%' THEN 'High Blood Pressure'

-- COPD and Asthma
    WHEN ICDDxCode LIKE 'J41%' THEN 'COPD and Asthma'
    WHEN ICDDxCode LIKE 'J42%' THEN 'COPD and Asthma'
    WHEN ICDDxCode LIKE 'J43%' THEN 'COPD and Asthma'
    WHEN ICDDxCode LIKE 'J44%' THEN 'COPD and Asthma'
    WHEN ICDDxCode LIKE 'J45%' THEN 'COPD and Asthma'
    WHEN ICDDxCode LIKE 'J47%' THEN 'COPD and Asthma'

-- Other for uncategorized codes
    ELSE 'Other'
END;

--Total cost for each diagnosis
SELECT 
    DxCodes,
    FileSource AS MedOrBH,
    SUM(DistinctCost) AS Cost
FROM (
    SELECT 
        DxCodes,
        FileSource,
        ClaimID,
        CAST(REPLACE(REPLACE(TotalPlanPaidAmt, '$', ''), ',', '') AS REAL) AS DistinctCost
    FROM claims_data
    GROUP BY DxCodes, FileSource, ClaimID
) AS DistinctClaims
GROUP BY DxCodes, FileSource;


-- Total claims count
SELECT 
    DxCodes,
    FileSource AS MedOrBH,
    COUNT(DISTINCT ClaimID) AS ClaimsCount
FROM claims_data
GROUP BY DxCodes, FileSource;

--Percentage of each diagnosis
WITH TotalCostBySource AS (
    SELECT 
        FileSource AS MedOrBH,
        SUM(CAST(REPLACE(REPLACE(TotalPlanPaidAmt, '$', ''), ',', '') AS REAL)) AS TotalCost
    FROM claims_data
    GROUP BY FileSource
)
SELECT 
    c.DxCodes,
    c.FileSource AS MedOrBH,
    SUM(CAST(REPLACE(REPLACE(c.TotalPlanPaidAmt, '$', ''), ',', '') AS REAL)) AS ClaimCost,
    ROUND((SUM(CAST(REPLACE(REPLACE(c.TotalPlanPaidAmt, '$', ''), ',', '') AS REAL)) * 100.0) / t.TotalCost, 2) AS PercentageOfTotal
FROM claims_data c
JOIN TotalCostBySource t
    ON c.FileSource = t.MedOrBH
GROUP BY c.DxCodes, c.FileSource;

--Number of Inpatients/ Outpatients/ ER Stays
SELECT 
    ClaimTypeID AS ClaimType,
    FileSource AS MedOrBH,
    COUNT(DISTINCT ClaimID) AS ClaimsCount,
    SUM(CAST(REPLACE(REPLACE(TotalPlanPaidAmt, '$', ''), ',', '') AS REAL)) AS Cost
FROM claims_data
WHERE ClaimTypeID IN ('I', 'O', 'ER')
GROUP BY ClaimTypeID, FileSource;

--GroupSubID Percentage and Claim Cost
WITH TotalClaimsByGroupAndSource AS (
    SELECT 
        GroupSubID,
        FileSource AS MedOrBH,
        COUNT(DISTINCT ClaimID) AS TotalDistinctClaims
    FROM claims_data
    GROUP BY GroupSubID, FileSource
)
SELECT 
    c.GroupSubID,
    c.DxCodes,
    c.FileSource AS MedOrBH,
    COUNT(DISTINCT c.ClaimID) AS ClaimsCount
FROM claims_data c
JOIN TotalClaimsByGroupAndSource t
    ON c.GroupSubID = t.GroupSubID AND c.FileSource = t.MedOrBH
GROUP BY c.GroupSubID, c.DxCodes, c.FileSource;



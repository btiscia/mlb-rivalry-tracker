SELECT 
CASE 
    WHEN LastItemType  = 'NO/Uncertain' THEN 'Uncertain'
    WHEN LastItemType  Like '%YES%'  AND MedRvwSupportedThroughDate IN( '2008-08-08','2010-10-10','2011-11-11') THEN 'Extended Duration' 
    WHEN LastItemType  Like '%YES%'  AND CalendarDaysPastTAT<= 0  THEN 'Active Supported'
    WHEN LastItemType  Like '%YES%' AND  CalendarDaysPastTAT>0   THEN 'Past Supported'
    ELSE 'No Review'  
END AS "Supported Risk Type"
,CalendarDaysPastTAT AS "Calendar Days Past TAT"
,LastItemType 
,CASE 
	WHEN ClaimStatusCategory  = 'Active Pending' THEN 'Pending'
    WHEN ClaimStatusCategory  = 'Approved'  THEN 'Approved'
    ELSE 'N/A'  
END as "Claim Status"
,ShortClaimNumber AS "Short Claim Number"
,ClaimNumber AS "Claim Number"
,ClaimCategory AS "Claim Category"
,ExaminerManagerName AS "Manager"
,ExaminerName AS "Examiner"
,ClaimantName AS "Claimant Name" 
,MedRvwSupportedThroughDate AS "Supported Through Date"
,LastItemDate  AS "Date of Medical Review"
,ICD1Code AS "Diagnosis Group"
,ICD1GroupName  AS "Diagnosis"
,ClaimantAge AS "Claimant Age" 
,MonthsSinceDateofDisability
,CAST(TransDate AS TIMESTAMP) AS "Trans Date"
,LoadDate AS "Load Date" 
FROM    PROD_DMA_VW.DIC_RISK_INVENTORY_RPT_VW
WHERE RiskTypeGroup ='SUPPORTED THROUGH'
AND (CalendarDaysPastTAT >=-60 OR CalendarDaysPastTAT IS NULL)
AND (RestrictedClaimIndicator = 0 OR RestrictedClaimIndicator IS NULL)
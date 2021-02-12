SELECT 
CASE 
    WHEN LastItemType  = 'NO/Uncertain' THEN 'Uncertain'
    WHEN LastItemType  LIKE '%YES%'  AND MedRvwSupportedThroughDate IN( '2008-08-08','2010-10-10','2011-11-11') THEN 'Extended Duration' 
    WHEN LastItemType  LIKE '%YES%'  AND CalendarDaysPastTAT<= 0  THEN 'Active Supported'
    WHEN LastItemType  LIKE '%YES%' AND  CalendarDaysPastTAT>0   THEN 'Past Supported'
    ELSE 'No Review'  
END AS "Supported Risk Type"
,CalendarDaysPastTAT AS "Calendar Days Past TAT"
,LastItemType 
,CASE 
    WHEN ClaimStatusCategory  = 'Active Pending' THEN 'Pending'
    WHEN ClaimStatusCategory  = 'Approved'  THEN 'Approved'
    ELSE 'N/A'  
END AS "Claim Status"
,ShortClaimNumber AS "Short Claim Number"
,ClaimNumber AS "Claim Number"
,ClaimCategory AS "Claim Category"
,ExaminerManagerName AS "Manager"
,ExaminerName AS "Examiner"
,T1.RoleGradeName
,T1.RoleGradeID
,ClaimantName AS "Claimant Name" 
,MedRvwSupportedThroughDate AS "Supported Through Date"
,LastItemDate  AS "Date of Medical Review"
,ICD1Code AS "Diagnosis Group"
,ICD1GroupName  AS "Diagnosis"
,ClaimantAge AS "Claimant Age" 
,MonthsSinceDateofDisability
,CAST(T1.TransDate AS TIMESTAMP) AS "Trans Date"
,LoadDate AS "Load Date" 
FROM    PROD_DMA_VW.DIC_RISK_INVENTORY_RPT_VW T1
LEFT JOIN PROD_DMA_VW.EMPLOYEE_CURR_DIM_VW T2 ON T1.EXAMINERPARTYEMPLOYEEID = T2.PARTYEMPLOYEEID
WHERE RiskTypeGroup ='SUPPORTED THROUGH'
AND (CalendarDaysPastTAT >=-60 OR CalendarDaysPastTAT IS NULL)
AND (RestrictedClaimIndicator = 0 OR RestrictedClaimIndicator IS NULL)
AND T1.RoleGradeID <> 12
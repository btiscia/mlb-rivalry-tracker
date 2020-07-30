SELECT DISTINCT 
T1.ClaimDimensionUniqueID
,T1.ClaimNumber AS "Claim Number"
 ,T1.ShortClaimNumber AS "Short Claim Number"
 --,T1.LastItemID AS PaymentID
 -- ,T1.LastItemType AS "Base Payment Type"
,CASE 
	WHEN T1.LastItemType = 'Payment Transaction - TD' THEN 'Total' 
	WHEN T1.LastItemType = 'Payment Transaction - PD' THEN 'Partial'
END AS "Base Payment Type"
,T1.LoadDate AS "Load Date"
,T1.ClaimCurrentStatus AS "Claim Current Status"
,T1.ClaimCurrentSubstatus AS "Claim Current Substatus" 
,T1.ClaimCategory AS "Claim Category"
,T1.ClaimStatusCategory AS "Claim Status Category"
,T1.ClaimantName AS "Claimant Name" 
,T1.ClaimantAge AS "Claimant Age"
,T1.MonthsSinceDateofDisability
,T1.ExaminerName AS "Examiner"
,T1.ExaminerManagerName AS "Manager"
,T1.ExaminerTeam AS "Team"
,T1.MedRvwSupportedThroughDate AS "Supported Through Date"
,T1.TransDate AS "Trans Date" 
,T2.LastItemDate AS "Past Due Check Date"
,COALESCE(NoPaymentIndicator, 0) AS "No Payment Indicator"
,COALESCE(NoThroughIndicator, 0) AS "No Through Indicator"
,T3.LastItemDate AS "Past Due Through Date"
--,CASE WHEN T1.LastItemID IS NULL THEN 'Missing' ELSE 'Past Due' END AS "Status"
FROM    PROD_DMA_VW.DIC_RISK_INVENTORY_RPT_VW T1

-- Left  Join to No Payment Data
LEFT JOIN (SELECT LastItemID, LoadDate,ClaimNumber, LastItemDate, RiskTypeID, 1 NoPaymentIndicator
						FROM PROD_DMA_VW.DIC_RISK_INVENTORY_RPT_VW 
						WHERE RiskTypeID = 1 
						AND (CalendarDaysPastTAT > 0 OR CalendarDaysPastTAT IS NULL)) T2 ON T1.ClaimNumber = T2.ClaimNumber AND T1.LoadDate = T2.LoadDate 

-- Left Join to No Through Payment Data
LEFT JOIN  (SELECT LastItemID, LoadDate, ClaimNumber, LastItemDate, RiskTypeID, 1 NoThroughIndicator
						FROM PROD_DMA_VW.DIC_RISK_INVENTORY_RPT_VW 
						WHERE RiskTypeID = 8 
						AND (CalendarDaysPastTAT > 0 OR CalendarDaysPastTAT IS NULL)) T3 ON T1.ClaimNumber = T3.ClaimNumber AND T1.LoadDate = T3.LoadDate 
WHERE T1.RiskTypeID IN (1,8)
AND (CalendarDaysPastTAT > 0 OR CalendarDaysPastTAT IS NULL)
AND (RestrictedClaimIndicator = 0 OR RestrictedClaimIndicator IS NULL)
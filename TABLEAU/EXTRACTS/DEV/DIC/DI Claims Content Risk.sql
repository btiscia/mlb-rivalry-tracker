SELECT RiskInventoryID AS "Risk Inventory ID"  
,ShortClaimNumber AS "Short Claim Number"
,ClaimNumber AS "Claim Number"
,ClaimCurrentStatus AS "Claim Current Status"
,ClaimCurrentSubstatus AS "Claim Current Substatus" 
,ClaimCategory AS "Claim Category"
,ClaimStatusCategory AS "Claim Status Category"
,ClaimantName AS "Claimant Name" 
,ClaimantAge AS "Claimant Age"
,MonthsSinceDateofDisability
,ExaminerName AS "Examiner"
,ExaminerManagerName AS "Manager"
,ExaminerTeam AS "Team"           
,RiskTypeName AS "Risk Type"
,RiskTypeID
,RoleGradeID
,RiskCalendarTATGoal AS "Risk Calendar TAT Goal" 
,LoadDate AS "Load Date" 
,LastItemType AS "Last Item Type"
,LastItemDate AS "Last Item Date"
,MedRvwSupportedThroughDate AS "Supported Through Date"
,CalendarDaysPending AS "Calendar Days Pending" 
,CalendarDaysPastTAT AS "Calendar Days Past TAT"
,ExpectedCompletedDate AS "Expected Completed Date"
,CASE WHEN CalendarDaysPastTAT > 0 THEN 'Past Due' 
        WHEN CalendarDaysPastTAT BETWEEN -30 AND 0 THEN 'Due'
        ELSE 'Missing' 
  END AS "Status"
, CASE WHEN RISKTYPEID = 9 AND ROLEGRADEID = 11 THEN 0
    WHEN RISKTYPEID <> 9 AND ROLEGRADEID = 11 THEN 1
    ELSE 0 END AS "Suppression Indicator"
,CAST(TransDate AS TIMESTAMP) AS "Trans Date"
FROM   DEV_DMA_VW.DIC_RISK_INVENTORY_RPT_VW
WHERE RiskTypeGroup ='Content Reports'
AND (CalendarDaysPastTAT >=-30 OR CalendarDaysPastTAT IS NULL)
AND (RestrictedClaimIndicator = 0 OR RestrictedClaimIndicator IS NULL)
AND "Suppression Indicator" = 0
ORDER BY LoadDate DESC
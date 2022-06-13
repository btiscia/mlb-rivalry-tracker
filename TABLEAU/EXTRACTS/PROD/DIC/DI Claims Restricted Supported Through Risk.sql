--Tableau Data Source: DI Claims Restricted Supported Through Risk

/*
*  Peer Review & Change Log:
*  Peer Review Date: 
*  Source for this routine is  
*  Author: John Avgoustakis
*  Created: 12/12/2019
* Revision: 1/5/2022 - Bill Trombley - Removed Restricted Claim filter.
======================================================================
*/



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
,RestrictedClaimIndicator
FROM   PROD_DMA_VW.DIC_RISK_INVENTORY_RPT_VW
WHERE RiskTypeGroup ='Content Reports'
AND (CalendarDaysPastTAT >=-30 OR CalendarDaysPastTAT IS NULL)
AND "Suppression Indicator" = 0


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
,RestrictedClaimIndicator
FROM    PROD_DMA_VW.DIC_RISK_INVENTORY_RPT_VW T1
WHERE RiskTypeGroup ='SUPPORTED THROUGH'
AND (CalendarDaysPastTAT >=-60 OR CalendarDaysPastTAT IS NULL)
AND COALESCE(T1.RoleGradeID, -99) <> 12
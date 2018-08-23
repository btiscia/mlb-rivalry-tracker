SELECT TransactionTypeName AS "Transaction Type"
,SourceActivityID AS "ActivityID"
,T1.SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,Count(SourceActivityID) AS "Transaction Count"
,CASE 
     WHEN TRANSACTIONTYPEID = 1 THEN  Cast(ReceivedDate AS TIMESTAMP(6))
     WHEN TRANSACTIONTYPEID = 2 THEN Cast(LoadDate AS TIMESTAMP(6))
     WHEN TRANSACTIONTYPEID = 3 THEN LongCompletedDate
END AS "Date"    
,LoggedDate AS "Logged Date"
,Coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"    
/*,Coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"*/
,EmployeeRoleName AS "Employee Role Name"
,EmployeeTeamName    AS "Team Name"
,WorkEventFunctionName    AS "Function Name"
,WorkEventSegmentName    AS "Segment Name"
,WorkEventWorkEventName    AS "Work Event Name"
/*,Priority    */
,AdminSystemCode AS "Admin System"    
,SystemName AS "System Name"
,ServiceChannelCode    AS "Service Channel Code"
,EmployeePartyTypeName    AS "Party Type Name"
,EmployeeSiteName AS "Site Name"
,WorkEventNumber    AS "Work Event Number"
,T1.ExpectedCompletedDate AS "Expected Completed Date"
, Count(IsHoliday) AS "Holidays"
,TAT
,DaysPastTAT AS "Days Past TAT"
/*,MetExpectedIndicator AS "Met Expected Indicator"*/
,MetExpected AS "Met Expected"
,ProductivityCredit AS "Productivity Credits" -- Using Prod Credits instead of Current Prod Credits?
/*,NIGODescription*/
,NIGOCode AS "NIGO Code"
/*,IGOIndicator AS "IGO Indicator"*/
/*,FlexIndicator AS "Flex Indicator"
,ActionableIndicator AS "Actionable Indicator"*/
,CASE WHEN SourceTransactionID IS NULL THEN 0
    ELSE 1
END AS "Completed Flag"
/*,ShortComment AS "Comments"*/
,T1.TransDate AS "Trans Date"
FROM PROD_DMA_VW.ACT_DIC_CURR_INTEGRATED_VW T1 
LEFT JOIN PROD_DMA_VW.DATE_DIM_VW T2 ON T2.ShortDate BETWEEN "Date" AND T1.ExpectedCompletedDate AND IsHoliday = 1
WHERE (WorkEventDepartmentID = 6 OR EmployeeDepartmentID = 6)
AND "Date" >= Add_Months(Current_Date, -3)
GROUP BY 1,2,3,4,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24,25,26,27,28
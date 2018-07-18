SELECT TransactionTypeName As "Transaction Type"
,SourceActivityID As "ActivityID"
,T1.SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,ItemCount AS "Transaction Count"
,CASE 
     WHEN TRANSACTIONTYPEID = 1 THEN  cast(ReceivedDate as TIMESTAMP(6))
     WHEN TRANSACTIONTYPEID = 2 THEN cast(LoadDate as TIMESTAMP(6))
     WHEN TRANSACTIONTYPEID = 3 THEN LongCompletedDate
END AS "Date"    
,LoggedDate AS "Logged Date"
,TransDate AS "Transaction Date"
,Coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"    
,Coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
,EmployeeRoleName AS "Employee Role Name"
,TeamName    AS "Team Name"
,FunctionName    AS "Function Name"
,SegmentName    AS "Segment Name"
,WorkEventName    AS "Work Event Name"
,Priority    
,AdminSystem AS "Admin System"    
,SystemName AS "System Name"
,ServiceChannelName    AS "Service Channel Code"
,PartyTypeName    AS "Party Type Name"
,SiteName AS "Site Name"
,WorkEventNumber    AS "Work Event Number"
,T1.ExpectedCompletedDate AS "Expected Completed Date"
,(SELECT Count(*) FROM PROD_DMA_VW.DATE_DIM_VW 
    WHERE IsHoliday = 1 AND ShortDate BETWEEN Cast("Date" AS DATE) 
    AND Cast(T1.ExpectedCompletedDate AS DATE)) AS "Holidays"    
,TAT
,DaysPastTAT AS "Days Past TAT"
,MetExpectedIndicator AS "Met Expected Indicator"
,MetExpected AS "Met Expected"
,CurrentProdCredit AS "Productivity Credits"
,NIGODescription
,NIGOCode AS "NIGO Code"
,IGOIndicator AS "IGO Indicator"
,FlexIndicator AS "Flex Indicator"
,ActionableIndicator AS "Actionable Indicator"
,CASE WHEN SourceTransactionID IS NULL THEN 0
    ELSE 1
END AS "Completed Flag"
,ShortComment AS "Comments"
,T1.TransDate AS "Trans Date"
FROM PROD_DMA_VW.PSC_MART_CURR_IVW T1 
WHERE (WorkEventDepartmentID = 4 OR DepartmentID = 4)
AND "Date" >= Add_Months(Current_Date, -3)

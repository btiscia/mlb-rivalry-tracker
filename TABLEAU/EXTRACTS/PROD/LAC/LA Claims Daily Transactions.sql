SELECT 
CASE 
	WHEN CompletedIndicator = 1 THEN 'Completed'
	WHEN SequenceNumber = 1 THEN 'Received'
	ELSE 'Pending'
END AS "Transaction Type"
,ActivityID
,Main.SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,CASE
	WHEN CompletedIndicator = 1 THEN Main.LongCompletedDate 
	WHEN SequenceNumber = 1 THEN CAST(ReceivedDate AS TIMESTAMP(6))
	ELSE CAST(LoadDate AS TIMESTAMP(6))
END AS "Date"
,LoggedDate AS "Logged Date"
,COALESCE(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"	
,COALESCE(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
,EmployeeRoleName AS "Employee Role Name"
,TeamName	AS "Team Name"
,FunctionName	AS "Function Name"
,SegmentName	AS "Segment Name"
,WorkEventName	AS "Work Event Name"
,Priority	
,AdminSystem AS "Admin System"	
,ServiceChannelName	AS "Service Channel Code"
,PartyTypeName	AS "Party Type Name"
,SiteName AS "Site Name"
,WorkEventNumber	AS "Work Event Number"
,ExpectedCompletedDate AS "Expected Completed Date"
,(SELECT COUNT(*) FROM PROD_DMA_VW.DATE_DIM_VW WHERE IsHoliday = 1 AND ShortDate BETWEEN DateDimDate.ShortDate AND DateDimExpected.ShortDate) AS "Holidays"	
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
,CASE
	WHEN Completed.SourceTransactionID IS NULL THEN 0
	ELSE 1
END AS "Completed Flag"
,ShortComment AS "Comments"
,Main.TransDate AS "Trans Date"
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW Main 
LEFT JOIN
(SELECT DISTINCT
SourceTransactionID
,CompletedDate
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW
WHERE CompletedIndicator = 1
AND (WorkEventDepartmentID IN (7,8)
OR DepartmentID IN (7,8))
AND CompletedDate >= ADD_MONTHS(CURRENT_DATE, -3)) Completed
ON Main.SourceTransactionID = Completed.SourceTransactionID
LEFT JOIN PROD_DMA_VW.DATE_DIM_VW DateDimExpected
ON Main.ExpectedCompletedDate = DateDimExpected.ShortDate
LEFT JOIN PROD_DMA_VW.DATE_DIM_VW DateDimDate
ON "Date" = DateDimDate.ShortDate
WHERE (WorkEventDepartmentID IN (7,8)
OR DepartmentID IN (7,8))
AND "Date" >= ADD_MONTHS(CURRENT_DATE, -3)

UNION ALL

SELECT 
'Received' AS "Transaction Type"
,ActivityID
,Main.SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,CAST(ReceivedDate AS TIMESTAMP(6)) AS "Date"
,LoggedDate AS "Logged Date"
,COALESCE(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"	
,COALESCE(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
,EmployeeRoleName AS "Employee Role Name"
,TeamName	AS "Team Name"
,FunctionName	AS "Function Name"
,SegmentName	AS "Segment Name"
,WorkEventName	AS "Work Event Name"
,Priority	
,AdminSystem AS "Admin System"	
,ServiceChannelName	AS "Service Channel Code"
,PartyTypeName	AS "Party Type Name"
,SiteName AS "Site Name"
,WorkEventNumber	AS "Work Event Number"
,ExpectedCompletedDate AS "Expected Completed Date"
,(SELECT COUNT(*) FROM PROD_DMA_VW.DATE_DIM_VW WHERE IsHoliday = 1 AND ShortDate BETWEEN DateDimDate.ShortDate AND DateDimExpected.ShortDate) AS "Holidays"	
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
,CASE
	WHEN Completed.SourceTransactionID IS NULL THEN 0
	ELSE 1
END AS "Completed Flag"
,ShortComment AS "Comments"
,Main.TransDate AS "Trans Date"
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW Main 
LEFT JOIN
(SELECT DISTINCT
SourceTransactionID
,CompletedDate
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW
WHERE CompletedIndicator = 1
AND (WorkEventDepartmentID IN (7,8)
OR DepartmentID IN (7,8))
AND CompletedDate >= ADD_MONTHS(CURRENT_DATE, -3)) Completed
ON Main.SourceTransactionID = Completed.SourceTransactionID
LEFT JOIN PROD_DMA_VW.DATE_DIM_VW DateDimExpected
ON Main.ExpectedCompletedDate = DateDimExpected.ShortDate
LEFT JOIN PROD_DMA_VW.DATE_DIM_VW DateDimDate
ON "Date" = DateDimDate.ShortDate
WHERE (WorkEventDepartmentID IN (7,8)
OR DepartmentID IN (7,8))
AND CompletedIndicator = 1
AND SequenceNumber = 1
AND "Date" >= ADD_MONTHS(CURRENT_DATE, -3)
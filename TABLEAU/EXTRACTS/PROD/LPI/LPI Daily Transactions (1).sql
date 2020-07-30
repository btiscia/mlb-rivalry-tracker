/*Updated 7/15/20 removed holidays to improve query efficiency -KC */

SELECT 
CASE 
	WHEN CompletedIndicator = 1 THEN 'Completed'
	WHEN SequenceNumber = 1 THEN 'Received'
	ELSE 'Pending'
END as "Transaction Type"
,ActivityID
,Main.SourceTransactionID as "Source Transaction ID"
,HoldingKey as "Policy Number"
,CASE
	WHEN CompletedIndicator = 1 THEN Main.LongCompletedDate 
	WHEN SequenceNumber = 1 THEN cast(ReceivedDate as TIMESTAMP(6))
	ELSE cast(LoadDate as TIMESTAMP(6))
END as "Date"
,LoggedDate as "Logged Date"
,coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') as "Employee"	
,coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') as "Manager"
,EmployeeRoleName AS "Employee Role Name"
,TeamName	as "Team Name"
,FunctionName	as "Function Name"
,SegmentName	as "Segment Name"
,WorkEventName	as "Work Event Name"
,Priority	
,AdminSystem as "Admin System"	
,ServiceChannelName	as "Service Channel Code"
,PartyTypeName	as "Party Type Name"
,SiteName as "Site Name"
,WorkEventNumber	as "Work Event Number"
,ExpectedCompletedDate as "Expected Completed Date"
--,(SELECT COUNT(*) FROM PROD_DMA_VW.DATE_DIM_VW WHERE IsHoliday = 1 AND ShortDate BETWEEN DateDimDate.ShortDate AND DateDimExpected.ShortDate) as "Holidays"	
,TAT
,DaysPastTAT as "Days Past TAT"
,MetExpectedIndicator as "Met Expected Indicator"
,MetExpected as "Met Expected"
,CurrentProdCredit as "Productivity Credits"
,NIGODescription
,NIGOCode as "NIGO Code"
,IGOIndicator as "IGO Indicator"
,FlexIndicator as "Flex Indicator"
,ActionableIndicator as "Actionable Indicator"
,CASE
	WHEN Completed.SourceTransactionID IS NULL THEN 0
	ELSE 1
END as "Completed Flag"
,ShortComment as "Comments"
,Main.TransDate as "Trans Date"
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW Main 
LEFT JOIN
(SELECT distinct
SourceTransactionID
,CompletedDate
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW
WHERE CompletedIndicator = 1
AND (WorkEventDepartmentID = 5
OR DepartmentID = 5)
AND CompletedDate >= ADD_MONTHS(CURRENT_DATE, -3)) Completed
ON Main.SourceTransactionID = Completed.SourceTransactionID
LEFT JOIN PROD_DMA_VW.DATE_DIM_VW DateDimExpected
ON Main.ExpectedCompletedDate = DateDimExpected.ShortDate
LEFT JOIN PROD_DMA_VW.DATE_DIM_VW DateDimDate
ON "Date" = DateDimDate.ShortDate
WHERE (WorkEventDepartmentID = 5
OR DepartmentID = 5)
AND "Date" >= ADD_MONTHS(CURRENT_DATE, -3)

UNION ALL

SELECT 
'Received' as "Transaction Type"
,ActivityID
,Main.SourceTransactionID as "Source Transaction ID"
,HoldingKey as "Policy Number"
,cast(ReceivedDate as TIMESTAMP(6)) as "Date"
,LoggedDate as "Logged Date"
,coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') as "Employee"	
,coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') as "Manager"
,EmployeeRoleName AS "Employee Role Name"
,TeamName	as "Team Name"
,FunctionName	as "Function Name"
,SegmentName	as "Segment Name"
,WorkEventName	as "Work Event Name"
,Priority	
,AdminSystem as "Admin System"	
,ServiceChannelName	as "Service Channel Code"
,PartyTypeName	as "Party Type Name"
,SiteName as "Site Name"
,WorkEventNumber	as "Work Event Number"
,ExpectedCompletedDate as "Expected Completed Date"
--,(SELECT COUNT(*) FROM PROD_DMA_VW.DATE_DIM_VW WHERE IsHoliday = 1 AND ShortDate BETWEEN DateDimDate.ShortDate AND DateDimExpected.ShortDate) as "Holidays"	
,TAT
,DaysPastTAT as "Days Past TAT"
,MetExpectedIndicator as "Met Expected Indicator"
,MetExpected as "Met Expected"
,CurrentProdCredit as "Productivity Credits"
,NIGODescription
,NIGOCode as "NIGO Code"
,IGOIndicator as "IGO Indicator"
,FlexIndicator as "Flex Indicator"
,ActionableIndicator as "Actionable Indicator"
,CASE
	WHEN Completed.SourceTransactionID IS NULL THEN 0
	ELSE 1
END as "Completed Flag"
,ShortComment as "Comments"
,Main.TransDate as "Trans Date"
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW Main 
LEFT JOIN
(SELECT distinct
SourceTransactionID
,CompletedDate
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW
WHERE CompletedIndicator = 1
AND (WorkEventDepartmentID = 5
OR DepartmentID = 5)
AND CompletedDate >= ADD_MONTHS(CURRENT_DATE, -3)) Completed
ON Main.SourceTransactionID = Completed.SourceTransactionID
LEFT JOIN PROD_DMA_VW.DATE_DIM_VW DateDimExpected
ON Main.ExpectedCompletedDate = DateDimExpected.ShortDate
LEFT JOIN PROD_DMA_VW.DATE_DIM_VW DateDimDate
ON "Date" = DateDimDate.ShortDate
WHERE (WorkEventDepartmentID = 5
OR DepartmentID = 5)
AND CompletedIndicator = 1
AND SequenceNumber = 1
AND "Date" >= ADD_MONTHS(CURRENT_DATE, -3)
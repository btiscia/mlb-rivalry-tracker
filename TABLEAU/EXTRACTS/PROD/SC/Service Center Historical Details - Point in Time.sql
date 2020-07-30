SELECT 
'Completed' as "Transaction Type"
,SourceTransactionID as "Source Transaction ID"
,HoldingKey as "Policy Number"
,CASE WHEN BCCIndicator = 0
	THEN 'N'
	ELSE 'Y'
END AS "Society 1851"
,CompletedDate as "Date"
,EmployeeRoleName as "Employee Role Name"
,coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') as "Employee"	
,coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') as "Manager"
,TeamName	as "Team Name"
,FunctionName	as "Function Name"
,SegmentName	as "Segment Name"
,WorkEventName	as "Work Event Name"
,Priority	
,AdminSystem as "Admin System"	
,ProcessName "Process Name"	
,ProcessID as "Process ID"
,ProcessOrder	as "Process Order"	
,ServiceChannelName	as "Service Channel Code"
,PartyTypeName	as "Party Type Name"
,EmployeeOrganizationName as "Employee Organization Name"
,EmployeeDepartmentName as "Employee Department Name"
,SiteName as "Site Name"
,WorkEventOranizationName	as "Work Event Organization Name"
,WorkEventDepartmentName	as "Work Event Department Name"
,PrimaryRoleName	as "Primary Role Name"
,SystemName	as "System Name"
,WorkEventNumber	as "Work Event Number"
,DepartmentCode	 as "Department Code"
,DivisionCode	as "Division Code"
,TAT
,NIGODescription
,ShortComment
,MAX(TransDate)	as "Max Trans Date"
,COUNT(distinct ActivityID) as "Transaction Count"
,TAT * "Transaction Count" as "Total TAT Days"
,SUM(CASE WHEN MetExpectedIndicator = 1 AND MetExpected = 1 THEN 1 ELSE 0 END) as "Met Expected Count"
,SUM(MetExpectedIndicator) as "Met Expected Ind Count"
,SUM(CurrentProdCredit) as "Productivity Credits"
,SUM(CASE WHEN IGOIndicator = 1 AND NIGOCode IS NULL THEN 1 ELSE 0 END) as "NIGO Count"
,SUM(CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END) as "IGO Count"
,SUM(IGOIndicator) as "IGO NIGO Count"
,SUM(FlexIndicator)  as "Flex Count"
,SUM(CASE WHEN DaysPastTAT <= 0 THEN 1 ELSE 0 END) as "Met TAT Count"
,SUM(CASE WHEN DaysPastTAT = 1 THEN 1 ELSE 0 END) as "Past TAT 1"
,SUM(CASE WHEN DaysPastTAT = 2 THEN 1 ELSE 0 END) as "Past TAT 2"
,SUM(CASE WHEN DaysPastTAT = 3 THEN 1 ELSE 0 END) as "Past TAT 3"
,SUM(CASE WHEN DaysPastTAT >= 4 THEN 1 ELSE 0 END) as "Past TAT 4+"
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW
WHERE (WorkEventDepartmentID IN (2,29,30,31,32,33,34)
OR DepartmentID IN (2,29,30,31,32,33,34))
AND CompletedIndicator = 1
AND "Date" >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32

UNION

SELECT 
'Pending' as "Transaction Type"
,NULL as "Source Transaction ID"
,cast(NULL as varchar(40)) as "Policy Number"
,CASE WHEN BCCIndicator = 0
	THEN 'N'
	ELSE 'Y'
END AS "Society 1851"
,LoadDate as "Date"
,EmployeeRoleName as "Employee Role Name"
,coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') as "Employee"	
,coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') as "Manager"
,TeamName	as "Team Name"
,FunctionName	as "Function Name"
,SegmentName	as "Segment Name"
,WorkEventName	as "Work Event Name"
,Priority	
,AdminSystem as "Admin System"	
,ProcessName "Process Name"	
,ProcessID as "Process ID"
,ProcessOrder	as "Process Order"	
,ServiceChannelName	as "Service Channel Code"
,PartyTypeName	as "Party Type Name"
,EmployeeOrganizationName as "Employee Organization Name"
,EmployeeDepartmentName as "Employee Department Name"
,SiteName as "Site Name"
,WorkEventOranizationName	as "Work Event Organization Name"
,WorkEventDepartmentName	as "Work Event Department Name"
,PrimaryRoleName	as "Primary Role Name"
,SystemName	as "System Name"
,WorkEventNumber	as "Work Event Number"
,DepartmentCode	 as "Department Code"
,DivisionCode	as "Division Code"
,NULL as TAT
,cast(NULL as varchar(5)) as NIGODescription
,cast(NULL as varchar(100)) as ShortComment
,MAX(TransDate)	as "Max Trans Date"
,COUNT(distinct ActivityID) as "Transaction Count"
,NULL as "Total TAT Days"
,SUM(CASE WHEN MetExpectedIndicator = 1 AND DaysPastTAT <= 0 THEN 1 ELSE 0 END) as "Met Expected Count"
,SUM(MetExpectedIndicator) as "Met Expected Ind Count"
,SUM(CurrentProdCredit) as "Productivity Credits"
,NULL as "NIGO Count"
,NULL as "IGO Count"
,NULL as "IGO NIGO Count"
,NULL as "Flex Count"
,SUM(MetTAT) as "Met TAT Count"
,SUM(PastTAT1) / "Transaction Count" as "Past TAT 1"
,SUM(PastTAT2) / "Transaction Count" as "Past TAT 2"
,SUM(PastTAT3)  / "Transaction Count" as "Past TAT 3"
,SUM(PastTAT4) / "Transaction Count" as "Past TAT 4+"
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW LPI
LEFT JOIN
(SELECT
SourceTransactionID, 
MAX(DaysPastTAT) MaxTAT
,CASE WHEN MaxTAT  <= 0 THEN 1 ELSE 0 END as MetTAT
,CASE WHEN MaxTAT  = 1 THEN 1 ELSE 0 END as PastTAT1
,CASE WHEN MaxTAT  = 2 THEN 1 ELSE 0 END as PastTAT2
,CASE WHEN MaxTAT  = 3 THEN 1 ELSE 0 END as PastTAT3
,CASE WHEN MaxTAT  >= 4 THEN 1 ELSE 0 END as PastTAT4
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW
WHERE (WorkEventDepartmentID IN (2,29,30,31,32,33,34)
OR DepartmentID IN (2,29,30,31,32,33,34))
AND PendingIndicator = 1
AND LoadDate >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1) MaxSub
ON LPI.SourceTransactionID = MaxSub.SourceTransactionID
AND LPI.DaysPastTAT = MaxSub.MaxTAT
WHERE (WorkEventDepartmentID IN (2,29,30,31,32,33,34)
OR DepartmentID IN (2,29,30,31,32,33,34))
AND PendingIndicator = 1
AND "Date" >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32

UNION

SELECT 
'Received' as "Transaction Type"
,SourceTransactionID as "Source Transaction ID"
,HoldingKey as "Policy Number"
,CASE WHEN BCCIndicator = 0
	THEN 'N'
	ELSE 'Y'
END AS "Society 1851"
,ReceivedDate as "Date"
,EmployeeRoleName as "Employee Role Name"
,coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') as "Employee"	
,coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unkonwn') as "Manager"
,TeamName	as "Team Name"
,FunctionName	as "Function Name"
,SegmentName	as "Segment Name"
,WorkEventName	as "Work Event Name"
,Priority	
,AdminSystem as "Admin System"	
,ProcessName "Process Name"	
,ProcessID as "Process ID"
,ProcessOrder	as "Process Order"	
,ServiceChannelName	as "Service Channel Code"
,PartyTypeName	as "Party Type Name"
,EmployeeOrganizationName as "Employee Organization Name"
,EmployeeDepartmentName as "Employee Department Name"
,SiteName as "Site Name"
,WorkEventOranizationName	as "Work Event Organization Name"
,WorkEventDepartmentName	as "Work Event Department Name"
,PrimaryRoleName	as "Primary Role Name"
,SystemName	as "System Name"
,WorkEventNumber	as "Work Event Number"
,DepartmentCode	 as "Department Code"
,DivisionCode	as "Division Code"
,TAT
,cast(NULL as varchar(5)) as NIGODescription
,ShortComment
,MAX(TransDate)	as "Max Trans Date"
,COUNT(distinct ActivityID) as "Transaction Count"
,NULL as "Total TAT Days"
,NULL as "Met Expected Count"
,NULL as "Met Expected Ind Count"
,SUM(CurrentProdCredit) as "Productivity Credits"
,NULL as "NIGO Count"
,NULL as "IGO Count"
,NULL as "IGO NIGO Count"
,NULL as "Flex Count"
,NULL as "Met TAT Count"
,NULL as "Past TAT 1"
,NULL as "Past TAT 2"
,NULL as "Past TAT 3"
,NULL as "Past TAT 4+"
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW
WHERE (WorkEventDepartmentID IN (2,29,30,31,32,33,34)
OR DepartmentID IN (2,29,30,31,32,33,34))
AND SequenceNumber = 1
AND "Date" >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
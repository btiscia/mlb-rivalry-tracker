SELECT 
CASE 
	WHEN CompletedIndicator = 1 THEN 'Completed'
	WHEN SequenceNumber = 1 THEN 'Received'
END as "Transaction Type"
,CASE
	WHEN CompletedIndicator = 1 THEN CompletedDate 
	WHEN SequenceNumber = 1 THEN ReceivedDate
END as "Date"
,coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') as "Employee"	
,coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') as "Manager"
,DepartmentID as "Department ID"
,WorkEventDepartmentID as "Work Event Department ID"
,TeamName	as "Team Name"
,PrimaryRoleName as "Role Name"
,FunctionName	as "Function Name"
,SegmentName	as "Segment Name"
,MetExpectedIndicator
,(SELECT GoalValue FROM PROD_DMA_VW.GOAL_DIM_VW WHERE GoalTypeID = 5 AND DepartmentID = 5 AND EndDate = '9999-12-31' AND FunctionName = TransView.FunctionName) as "IGO Goal"
,999 as "TAT Goal"
,COUNT(distinct ActivityID) as "Transaction Count"
,SUM(TAT) as "Total TAT Days"
,SUM(CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END) as "IGO Count"
,SUM(IGOIndicator) as "IGO NIGO Count"
,MAX(TransDate) as "Trans Date"
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW TransView
WHERE (WorkEventDepartmentID = 5
OR DepartmentID = 5)
AND (CompletedIndicator = 1
OR SequenceNumber = 1)
AND "Date" >= ADD_MONTHS(CURRENT_DATE, -36)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13

UNION

SELECT 
'Received' as "Transaction Type"
,CASE
	WHEN CompletedIndicator = 1 THEN CompletedDate 
	WHEN SequenceNumber = 1 THEN ReceivedDate
END as "Date"
,coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') as "Employee"	
,coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') as "Manager"
,DepartmentID as "Department ID"
,WorkEventDepartmentID as "Work Event Department ID"
,TeamName	as "Team Name"
,PrimaryRoleName as "Role Name"
,FunctionName	as "Function Name"
,SegmentName	as "Segment Name"
,MetExpectedIndicator
,(SELECT GoalValue FROM PROD_DMA_VW.GOAL_DIM_VW WHERE GoalTypeID = 5 AND DepartmentID = 5 AND EndDate = '9999-12-31' AND FunctionName = TransView.FunctionName) as "IGO Goal"
,999 as "TAT Goal"
,COUNT(distinct ActivityID) as "Transaction Count"
,SUM(TAT) as "Total TAT Days"
,SUM(CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END) as "IGO Count"
,SUM(IGOIndicator) as "IGO NIGO Count"
,MAX(TransDate) as "Trans Date"
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW TransView
WHERE (WorkEventDepartmentID = 5
OR DepartmentID = 5)
AND CompletedIndicator = 1
AND SequenceNumber = 1
AND "Date" >= ADD_MONTHS(CURRENT_DATE, -36)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
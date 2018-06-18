SELECT TransactionTypeName
,CASE
	WHEN TransactionTypeID = 3 THEN CompletedDate 
	WHEN TransactionTypeID = 1 THEN ReceivedDate
END AS "Date"
,Coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"	
,Coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
,T1.DepartmentID AS "Department ID"
,WorkEventDepartmentID AS "Work Event Department ID"
,TeamName	AS "Team Name"
,PrimaryRoleName AS "Role Name"
,T1.FunctionName	AS "Function Name"
,T1.SegmentName	AS "Segment Name"
,MetExpectedIndicator
,GoalValue
,999 AS "TAT Goal"
,Count(DISTINCT SourceActivityID) AS "Transaction Count"
,Sum(TAT) AS "Total TAT Days"
,Sum(CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END) AS "IGO Count"
,Sum(IGOIndicator) AS "IGO NIGO Count"
,Max(TransDate) AS "Trans Date"
FROM PROD_DMA_VW.PSC_MART_CURR_IVW T1

LEFT JOIN (SELECT GoalValue, DepartmentID, FunctionID FROM PROD_DMA_VW.GOAL_DIM_VW WHERE GoalTypeID = 5 AND EndDate = '9999-12-31') T2 
	ON T1.DepartmentID = T2.DepartmentID AND T1.FunctionID = T2.FunctionID
	
WHERE (WorkEventDepartmentID = 4 OR T1.DepartmentID = 4)
AND TransactionTypeID <> 2
AND "Date" >= Add_Months(Current_Date, -36)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
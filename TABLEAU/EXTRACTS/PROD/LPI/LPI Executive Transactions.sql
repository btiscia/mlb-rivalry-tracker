SELECT T1.*
	, GoalValue AS "IGO Goal"
FROM (SELECT
		CASE WHEN CompletedIndicator = 1 THEN 'Completed'
			WHEN SequenceNumber = 1 THEN 'Received'
		END as "Transaction Type"
		,CASE WHEN CompletedIndicator = 1 THEN CompletedDate 
			WHEN SequenceNumber = 1 THEN ReceivedDate
		END as "Date"
		,coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') as "Employee"	
		,coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') as "Manager"
		,T1.DepartmentID as "DepartmentID"
		,WorkEventDepartmentID
		,T1.TeamName	as "Team Name"
		,T1.PrimaryRoleName as "Role Name"
		,T1.FunctionName	as "Function Name"
		,T1.FunctionID
		,T1.SegmentName	as "Segment Name"
		,MetExpectedIndicator
		,999 as "TAT Goal"
		,COUNT(distinct ActivityID) as "Transaction Count"
		,SUM(TAT) as "Total TAT Days"
		,SUM(CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END) as "IGO Count"
		,SUM(IGOIndicator) as "IGO NIGO Count"
		,MAX(TransDate) as "Trans Date"
		FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW T1
		WHERE (T1.WorkEventDepartmentID = 5 OR T1.DepartmentID = 5)
		AND (CompletedIndicator = 1 OR SequenceNumber = 1)
		AND "Date" >= ADD_MONTHS(CURRENT_DATE, -36)
		GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
		
		UNION
		
		SELECT 
		'Received' as "Transaction Type"
		,CASE WHEN CompletedIndicator = 1 THEN CompletedDate 
			WHEN SequenceNumber = 1 THEN ReceivedDate
		END as "Date"
		,coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') as "Employee"	
		,coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') as "Manager"
		,T1.DepartmentID as "DepartmentID"
		,T1.WorkEventDepartmentID
		,T1.TeamName	as "Team Name"
		,T1.PrimaryRoleName as "Role Name"
		,T1.FunctionName	as "Function Name"
		,T1.FunctionID
		,T1.SegmentName	as "Segment Name"
		,MetExpectedIndicator
		,999 as "TAT Goal"
		,COUNT(distinct ActivityID) as "Transaction Count"
		,SUM(TAT) as "Total TAT Days"
		,SUM(CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END) as "IGO Count"
		,SUM(IGOIndicator) as "IGO NIGO Count"
		,MAX(TransDate) as "Trans Date"
		FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW T1
		WHERE (WorkEventDepartmentID = 5 OR T1.DepartmentID = 5)
		AND CompletedIndicator = 1
		AND SequenceNumber = 1
		AND "Date" >= ADD_MONTHS(CURRENT_DATE, -36)
		GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13) T1
LEFT JOIN (SELECT * FROM PROD_DMA_VW.GOAL_DIM_VW WHERE GoalTypeID = 5 AND EndDate = '9999-12-31') T3 ON T1.FunctionID = T3.FunctionID AND T1.DepartmentID = T3.DepartmentID
--) After Release the Current Dimension will be used
/*LEFT JOIN (SELECT * FROM PROD_DMA_VW.GOAL_CURR_DIM_VW WHERE GoalTypeID = 5) T3 ON T1.FunctionID = T3.FunctionID AND T1.DepartmentID = T3.DepartmentID*/


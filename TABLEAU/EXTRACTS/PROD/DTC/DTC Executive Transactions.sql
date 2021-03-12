/* This routine provides RMM info for Executive dash
*  Peer Review & Change Log:  
*  Peer Review Date: 
*  Source for this routine is PROD_DMA_VW.CURR_PEND_VW
*  Author: David Washburn
*  Created: 11/14/2017
*  Revised:  7/19/2018
*  Revision Made:  7/19/2018 - Department ID changed from 5 (LPI) to 20 (RMM).  Revision made by Lorraine Christian/Patrick McHugh.
*/

SELECT 
CASE 
	WHEN CompletedIndicator = 1 THEN 'Completed'
	WHEN SequenceNumber = 1 THEN 'Received'
END AS "Transaction Type"
,CASE
	WHEN CompletedIndicator = 1 THEN CompletedDate 
	WHEN SequenceNumber = 1 THEN ReceivedDate
END AS "Date"
,COALESCE(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"	
,COALESCE(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
,DepartmentID AS "Department ID"
,WorkEventDepartmentID AS "Work Event Department ID"
,TeamName	AS "Team Name"
,PrimaryRoleName AS "Role Name"
,FunctionName	AS "Function Name"
,SegmentName	AS "Segment Name"
,MetExpectedIndicator
,(SELECT GoalValue FROM PROD_DMA_VW.GOAL_DIM_VW WHERE GoalTypeID = 5 AND DepartmentID = 20 AND EndDate = '9999-12-31' AND FunctionName = TransView.FunctionName) AS "IGO Goal"
,999 AS "TAT Goal"
,COUNT(DISTINCT ActivityID) AS "Transaction Count"
,SUM(TAT) AS "Total TAT Days"
,SUM(CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END) AS "IGO Count"
,SUM(IGOIndicator) AS "IGO NIGO Count"
,MAX(TransDate) AS "Trans Date"
FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW TransView
WHERE (WorkEventDepartmentID =20
OR DepartmentID = 20)
AND (CompletedIndicator = 1
OR SequenceNumber = 1)
AND "Date" >= ADD_MONTHS(CURRENT_DATE, -36)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13

UNION

SELECT 
'Received' AS "Transaction Type"
,CASE
	WHEN CompletedIndicator = 1 THEN CompletedDate 
	WHEN SequenceNumber = 1 THEN ReceivedDate
END AS "Date"
,COALESCE(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"	
,COALESCE(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
,DepartmentID AS "Department ID"
,WorkEventDepartmentID AS "Work Event Department ID"
,TeamName	AS "Team Name"
,PrimaryRoleName AS "Role Name"
,FunctionName	AS "Function Name"
,SegmentName	AS "Segment Name"
,MetExpectedIndicator
,(SELECT GoalValue FROM PROD_DMA_VW.GOAL_DIM_VW WHERE GoalTypeID = 5 AND DepartmentID = 20 AND EndDate = '9999-12-31' AND FunctionName = TransView.FunctionName) AS "IGO Goal"
,999 AS "TAT Goal"
,COUNT(DISTINCT ActivityID) AS "Transaction Count"
,SUM(TAT) AS "Total TAT Days"
,SUM(CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END) AS "IGO Count"
,SUM(IGOIndicator) AS "IGO NIGO Count"
,MAX(TransDate) AS "Trans Date"
FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW TransView
WHERE (WorkEventDepartmentID = 20
OR DepartmentID = 20)
AND CompletedIndicator = 1
AND SequenceNumber = 1
AND "Date" >= ADD_MONTHS(CURRENT_DATE, -36)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
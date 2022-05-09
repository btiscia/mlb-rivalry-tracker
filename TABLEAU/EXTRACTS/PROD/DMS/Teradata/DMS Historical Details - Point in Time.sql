/* This routine provides Historical Point In Time  for DMS
*  Peer Review & Change Log:  
*  Peer Review Date: 
*  Source for this routine is  PROD_DMA_VW.ACT_DMS_PIT_INTEGRATED_VW
*  Author: Christina Valenti, Lorraine Christian, Kristin Carlile
*  Created: NA
*  Revised:  7/8/2019
*  Revision Made:  7/8/2019 - Pending removed entirely .  GoalValue field removed along with the left join to the goal table, CompletedLongDate added.  
* Revised: 6/7/21 - Added dept 51 for Hyderabad - KC
*/

SELECT 
TransactionTypeName AS "Transaction Type"
,SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"

,CASE WHEN BCCIndicator = 0
	THEN 'N'
	ELSE 'Y'
END AS "Society 1851"

,systemDivisionname AS "Line of Business"
        
,CASE 
     WHEN TRANSACTIONTYPEID = 1 THEN ReceivedDate
--     WHEN TRANSACTIONTYPEID = 2 THEN LoadDate
     WHEN TRANSACTIONTYPEID = 3 THEN CompletedDate
END AS "Date"    
     
,EmployeeRoleName AS "Employee Role Name"
,Coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"    
,Coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
,TeamName AS "Team Name"
,FunctionName AS "Function Name"
,SegmentName AS "Segment Name"
,WorkEventName AS "Work Event Name"
,Priority
,AdminSystem AS "Admin System"
,ProcessName AS "Process Name"
,ProcessID AS "Process ID"
,ProcessOrder AS "Process Order"
,ServiceChannelName AS "Service Channel Code"
,PartyTypeName AS "Party Type Name"
,EmployeeOrganizationName AS "Employee Organization Name"
,EmployeeDepartmentName AS "Employee Department Name"             
,SiteName AS "Site Name"
,WorkEventOranizationName AS "Work Event Organization Name"
,WorkEventDepartmentName AS "Work Event Department Name"
,PrimaryRoleName AS "Primary Role Name"
,SystemName AS "System Name"
,WorkEventNumber AS "Work Event Number"
,DepartmentCode AS "Department Code"
,DivisionCode AS "Division Code"
,CompletedIndicator AS "Completed Indicator"
,TAT
,NIGODescription
,TransDate AS "Transaction Date"
,LongCompletedDate AS "Completed Time Stamp"
,ShortComment AS "Short Comments"
,ItemCount AS "Transaction Count"
,DaysPastTAT AS "Total TAT Days"
,CASE WHEN MetExpectedIndicator = 1 AND DaysPastTAT <= 0 THEN 1 ELSE 0 END AS "Met Expected Count"
,MetExpectedIndicator AS "Met Expected Ind Count"
,CurrentProdCredit AS "Productivity Credits"
,CASE WHEN IGOIndicator = 1 AND NIGOCode = '-99' THEN 1 ELSE 0 END AS "NIGO Count"
,CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END AS "IGO Count" 
,IGOIndicator AS "IGO NIGO Count"
--,GoalValue AS "IGO Goal"
,FlexIndicator AS "Flex Count"
,CASE WHEN DaysPastTAT <= 0 THEN 1 ELSE 0 END AS "Met TAT Count"
,CASE WHEN DaysPastTAT = 1 THEN 1 ELSE 0 END AS "Past TAT 1"
,CASE WHEN DaysPastTAT = 2 THEN 1 ELSE 0 END AS "Past TAT 2"
,CASE WHEN DaysPastTAT = 3 THEN 1 ELSE 0 END AS "Past TAT 3"
,CASE WHEN DaysPastTAT >= 4 THEN 1 ELSE 0 END AS "Past TAT 4+"
,DocumentCount AS "Document Count" 
FROM PROD_DMA_VW.ACT_DMS_PIT_INTEGRATED_VW T1

--LEFT OUTER JOIN (SELECT GoalValue, DepartmentID, FunctionID FROM PROD_DMA_VW.GOAL_DIM_VW WHERE EndDate = '9999-12-31' AND GoalTypeID = 5) T2 
--ON T1.FunctionID = T2.FunctionID AND T1.DepartmentID = T2.DepartmentID

WHERE (WorkEventDepartmentID = 13
OR T1. DepartmentID in (13, 51))

AND TransactionTypeId IN (1,3)
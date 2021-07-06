/* This routine provides Historical Point In Time  for Advisor Operations  PIT
*  Peer Review & Change Log:  
*  Peer Review Date: 
*  Source for this routine is  PROD_DMA_VW.ACT_ADO_PIT_INTEGRATED_VW  and PROD_DMA_VW.GOAL_DIM_VW
*  Author: Christina Valenti, Lorraine Christian, Kristin Carlile
*  Created: NA
*  Revised:  7/8/2019
*  Revision Made:  7/8/2019 - Pending removed entirely .  GoalValue field removed along with the left join to the goal table, CompletedLongDate added. 
*  Goal information added back in the query 
* Revision Made: 11/2/2020 - Removed case statement for productivity credits as it was fixed on data side and is no longer necessary - KC
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
,FirmDisplayName  AS "Firm"
,FirmSalesRegion AS "Region"
,AdminSystemID AS "Admin System ID"
,AdminSystemCode AS "Admin System"
,ProcessName AS "Process Name"
,ProcessID AS "Process ID"
,ProcessOrder AS "Process Order"
,ServiceChannelName AS "Service Channel Code"
,PartyTypeName AS "Party Type Name"
,EmployeeOrganizationName AS "Employee Organization Name"
,EmployeeDepartmentName AS "Employee Department Name"             
,SiteName AS "Site Name"
--,WorkEventOranizationName AS "Work Event Organization Name"
--,WorkEventDepartmentName AS "Work Event Department Name"
,PrimaryRoleName AS "Primary Role Name"
,SystemName AS "System Name"
,WorkEventNumber AS "Work Event Number"
,DepartmentCode AS "Department Code"
,DivisionCode AS "Division Code"
,CompletedIndicator AS "Completed Indicator"
,RequestorTypeName AS "Requestor Type Name" 
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
--  , CASE
--           WHEN SrcSysID = 24 THEN ProdCredit
--          ELSE CurrentProdCredit
--        END AS "Productivity Credits" removed 11/2 as original issue was resolved on data side
,CASE WHEN IGOIndicator = 1 AND NIGOCode = '-99' THEN 1 ELSE 0 END AS "NIGO Count"
,CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END AS "IGO Count" 
,IGOIndicator AS "IGO NIGO Count"
,GoalValue AS "IGO Goal"---added 4/13/2020
,FlexIndicator AS "Flex Count"
,CASE WHEN DaysPastTAT <= 0 THEN 1 ELSE 0 END AS "Met TAT Count"
,CASE WHEN DaysPastTAT = 1 THEN 1 ELSE 0 END AS "Past TAT 1"
,CASE WHEN DaysPastTAT = 2 THEN 1 ELSE 0 END AS "Past TAT 2"
,CASE WHEN DaysPastTAT = 3 THEN 1 ELSE 0 END AS "Past TAT 3"
,CASE WHEN DaysPastTAT >= 4 THEN 1 ELSE 0 END AS "Past TAT 4+"
,CATSExpectedCompletedDate AS "Follow Up Date"

FROM PROD_DMA_VW.ACT_ADO_PIT_INTEGRATED_VW T1

LEFT OUTER JOIN (SELECT GoalValue, DepartmentID, FunctionID FROM PROD_DMA_VW.GOAL_DIM_VW WHERE EndDate = '9999-12-31' AND GoalTypeID = 5) T2  --added 4/13/2020
ON T1.FunctionID = T2.FunctionID AND T1.DepartmentID = T2.DepartmentID --added 4/13/2020

WHERE (WorkEventDepartmentID = 48
OR T1. DepartmentID = 48)

AND TransactionTypeId IN (1,3)
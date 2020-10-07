/* This routine provides Historical Point In Time  for Annuity Operations

*  Peer Review & Change Log:  
*  Peer Review Date: 
*  Source for this routine is  PROD_DMA_VW.ANO_ADO_PIT_INTEGRATED_FCT_VW
*  Author: Christina Valenti, Lorraine Christian, Kristin Carlile
*  Created: NA
*  Revised:  7/8/2019
*  Revision Made:  7/8/2019 - Pending removed entirely .  GoalValue field removed along with the left join to the goal table, CompletedLongDate added.  
 * Goals added back in 4/16/2020
 * 7/14/2020 Added an addition NIGO Code of '361'.  This is applicable for Annuity Only.  Refer to IGO Count.  - LC
====================================================================== */


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
,TAT
,NIGODescription
,TransDate AS "Transaction Date"
,LongCompletedDate AS "Completed Time Stamp"
,CATSexpectedcompleteddate AS "Follow Up Date" 
,ShortComment AS "Short Comments"
,ItemCount AS "Transaction Count"
,DaysPastTAT AS "Total TAT Days"
,CASE WHEN MetExpectedIndicator = 1 AND DaysPastTAT <= 0 THEN 1 ELSE 0 END AS "Met Expected Count"
,MetExpectedIndicator AS "Met Expected Ind Count"
--,CurrentProdCredit AS "Productivity Credits"  Removed 4/29 and added case statement below
 , CASE
            WHEN SrcSysID = 24 THEN ProdCredit
            ELSE CurrentProdCredit
            END AS "Productivity Credits"
,CASE WHEN IGOIndicator = 1 AND NIGOCode = '-99' THEN 1 ELSE 0 END AS "NIGO Count"
,CASE WHEN IGOIndicator = 1 AND NIGOCode IN ('090','361') THEN 1 ELSE 0 END AS "IGO Count"  -- REPLACES LINE BELOW '361' is applicable for Annuity Only. 
--,CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END AS "IGO Count"   REMOVED THIS LINE 7/14/2020 
,IGOIndicator AS "IGO NIGO Count"
,GoalValue AS "IGO Goal" --added 4/16
,FlexIndicator AS "Flex Count"
--,MajorProductName AS "Contract Type" REMOVED 4/6/2020
, CASE 
 		WHEN T1.MajorProductName IS NULL AND PrimaryLogID IN (6, 10) THEN 'Unknown' 
 		WHEN T1.MajorProductName IS NULL AND PrimaryLogID NOT IN (6, 10) THEN NULL 
 		ELSE T1.MajorProductName 
 		END AS "Contract Type"
,CASE WHEN DaysPastTAT <= 0 THEN 1 ELSE 0 END AS "Met TAT Count"
,CASE WHEN DaysPastTAT = 1 THEN 1 ELSE 0 END AS "Past TAT 1"
,CASE WHEN DaysPastTAT = 2 THEN 1 ELSE 0 END AS "Past TAT 2"
,CASE WHEN DaysPastTAT = 3 THEN 1 ELSE 0 END AS "Past TAT 3"
,CASE WHEN DaysPastTAT >= 4 THEN 1 ELSE 0 END AS "Past TAT 4+"
FROM PROD_DMA_VW.ACT_ANO_PIT_INTEGRATED_VW T1

LEFT OUTER JOIN (SELECT GoalValue, DepartmentID, FunctionID FROM PROD_DMA_VW.GOAL_DIM_VW WHERE EndDate = '9999-12-31' AND GoalTypeID = 5) T2 --added 4/16/20
ON T1.FunctionID = T2.FunctionID AND T1.DepartmentID = T2.DepartmentID --added 4/16/20

WHERE (WorkEventDepartmentID in (9,11)
OR T1. DepartmentID in (9, 11))

AND TransactionTypeId IN (1,3)
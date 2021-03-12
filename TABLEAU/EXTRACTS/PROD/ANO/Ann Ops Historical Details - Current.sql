/*
* This routine pulls current transaction history
*  Peer Review & Change Log:
*  Peer Review Date: 
*  Source for this routine is  PROD_DMA_VW_ACT_ANO_CURR_INTEGRATED_FCT_VW
*  Author: Lorraine Christian
*  Created: 3/4/2020
*  Revisions:  7/14/2020 Added an addition NIGO Code of '361'.  This is applicable for Annuity Only.  Refer to IGO Count.  - LC
====================================================================== 
======================================================================
                
======================================================================*/

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
     WHEN TRANSACTIONTYPEID = 1   THEN ReceivedDate
     WHEN TRANSACTIONTYPEID = 2 THEN LoadDate
     WHEN TRANSACTIONTYPEID = 3 THEN CompletedDate
END AS "Date"    
     
,EmployeeRoleName AS "Employee Role Name"
,COALESCE(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"    
,COALESCE(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
,TeamName AS "Team Name"
,FunctionName AS "Function Name"
,SegmentName AS "Segment Name"
,WorkEventName AS "Work Event Name"
,PriorityID AS "Priority"
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
,WorkEventOrganizationName AS "Work Event Organization Name"
--,WorkEventOranizationName 
,WorkEventDepartmentName AS "Work Event Department Name"
,PrimaryRoleName AS "Primary Role Name"
,SystemName AS "System Name"
,WorkEventNumber AS "Work Event Number"
,DepartmentCode AS "Department Code"
,DivisionCode AS "Division Code"
,TAT
,TransactionTypeId
,CompletedIndicator
,LongCompletedDate AS "Completed Time Stamp" --Added completed time stamp
,CATSexpectedcompleteddate AS "Follow Up Date"
,NIGODescription
,TransDate AS "Transaction Date"
,ShortComments AS "Short Comments"
,ItemCount AS "Transaction Count"
,DaysPastTAT AS "Total TAT Days"
,CASE WHEN MetExpectedIndicator = 1 AND DaysPastTAT <= 0 THEN 1 ELSE 0 END AS "Met Expected Count"
,MetExpectedIndicator AS "Met Expected Ind Count"
--,CurrentProdCredit AS "Productivity Credits" removed 4/29/2020 replaced with case statement below
 , CASE
            WHEN SrcSysID = 24 THEN ProdCredit
            ELSE CurrentProdCredit
            END AS "Productivity Credits"
,CASE WHEN IGOIndicator = 1 AND NIGOCode = '-99' THEN 1 ELSE 0 END AS "NIGO Count"
,CASE WHEN IGOIndicator = 1 AND NIGOCode IN ('090','361') THEN 1 ELSE 0 END AS "IGO Count"  -- REPLACES LINE BELOW '361' is applicable for Annuity Only. 
--,CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END AS "IGO Count"   REMOVED THIS LINE 7/14/2020
,IGOIndicator AS "IGO NIGO Count"
--,GoalValue AS "IGO Goal"
,FlexIndicator AS "Flex Count"
,CASE WHEN DaysPastTAT <= 0 THEN 1 ELSE 0 END AS "Met TAT Count"
,CASE WHEN DaysPastTAT = 1 THEN 1 ELSE 0 END AS "Past TAT 1"
,CASE WHEN DaysPastTAT = 2 THEN 1 ELSE 0 END AS "Past TAT 2"
,CASE WHEN DaysPastTAT = 3 THEN 1 ELSE 0 END AS "Past TAT 3"
,CASE WHEN DaysPastTAT >= 4 THEN 1 ELSE 0 END AS "Past TAT 4+"
--,DocumentCount AS "Document Count"
, CASE 
 		WHEN MajorProductName IS NULL AND PrimaryLogID IN (6, 10) THEN 'Unknown' 
 		WHEN MajorProductName IS NULL AND PrimaryLogID NOT IN (6, 10) THEN NULL 
 		ELSE MajorProductName 
 		END AS "Contract Type"
--,MajorProductName AS "Contract Type"  REMOVED 4/6/20220

-- Added for EOD Pending
,CASE WHEN T1.transactiontypeid = 2 --this is a pending record
                  AND T1.LoggedDate < CURRENT_DATE  --that was logged prior to today
				  AND (CompRec.CompDate > T1.LoadDate OR CompRec.CompDate IS NULL) --that was completed after the load date of this pending record or hasn't been completed yet
				  THEN 1 ELSE 0 END AS "EOD Pending Indicator" 
-- End of change


FROM PROD_DMA_VW.ACT_ANO_CURR_INTEGRATED_VW T1  --Removed this mart PSC_MART_CURR_IVW T1
--LEFT OUTER JOIN (SELECT GoalValue, DepartmentID, FunctionID FROM PROD_DMA_VW.GOAL_DIM_VW WHERE EndDate = '9999-12-31' AND GoalTypeID = 5) T2 
--ON T1.FunctionID = T2.FunctionID AND T1.DepartmentID = T2.DepartmentID

-- Added for EOD Pending
LEFT 
JOIN (SELECT DISTINCT
                              a.sourcetransactionid AS SourceTrans,
                              First_Value( a.CompletedDate) OVER (PARTITION BY a.sourcetransactionid
							  ORDER BY a.SequenceNumber DESC, LoadDate DESC) AS CompDate  
                FROM PROD_dma_vw.act_ano_integrated_fct_vw AS a
	         WHERE a.completedindicator = 1 --completed
				    AND a.transactiontypeid = 3 --completed
					AND a.completeddate < CURRENT_DATE) AS CompRec --exclude completed today bc today isn't over yet
   ON CompRec.SourceTrans = T1.SourceTransactionId
-- end of change 

WHERE (WorkEventDepartmentID IN (9,11)
OR T1. DepartmentID IN (9,11))
AND (TransactionTypeId IN (1,3) OR CAST(loggeddate AS DATE) >=  (ADD_MONTHS(CURRENT_DATE, -36))) --Added to limit pending records to rolling 3 years
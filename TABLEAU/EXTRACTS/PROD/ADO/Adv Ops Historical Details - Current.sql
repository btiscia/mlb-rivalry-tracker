/*
* This routine pulls current transaction history
*  Peer Review & Change Log:
*  Peer Review Date: 
*  Source for this routine is  PROD_DMA_VW_ACT_ADO_CURR_INTEGRATED_VW
*  Author: Lorraine Christian
*  Created: 3/4/2020
* Add goal information back in this query
Revised - 11/2/2020 Removed case statement on productivity credits as it was fixed on data side and is no longer needed
Revised 6/2/2021 Added requestor type name field - KC
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
,Coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"    
,Coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
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
,NIGODescription
,TransDate AS "Transaction Date"
,ShortComment AS "Short Comments"
,ItemCount AS "Transaction Count"
,DaysPastTAT AS "Total TAT Days"
,RequestorTypeName as "Requestor Type Name" 
,CASE WHEN MetExpectedIndicator = 1 AND DaysPastTAT <= 0 THEN 1 ELSE 0 END AS "Met Expected Count"
,MetExpectedIndicator AS "Met Expected Ind Count"
,CurrentProdCredit AS "Productivity Credits"  --Removed 4/28 and replaced with case statement below
/*, CASE
            WHEN SrcSysID = 24 THEN ProdCredit
            ELSE CurrentProdCredit
            END AS "Productivity Credits"
	Fixed on data side, case statement is  no longer needed */
,CASE WHEN IGOIndicator = 1 AND NIGOCode = '-99' THEN 1 ELSE 0 END AS "NIGO Count"
,CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END AS "IGO Count" 
,IGOIndicator AS "IGO NIGO Count"
,GoalValue AS "IGO Goal"  --added 4/13/2020
,FlexIndicator AS "Flex Count"
,CASE WHEN DaysPastTAT <= 0 THEN 1 ELSE 0 END AS "Met TAT Count"
,CASE WHEN DaysPastTAT = 1 THEN 1 ELSE 0 END AS "Past TAT 1"
,CASE WHEN DaysPastTAT = 2 THEN 1 ELSE 0 END AS "Past TAT 2"
,CASE WHEN DaysPastTAT = 3 THEN 1 ELSE 0 END AS "Past TAT 3"
,CASE WHEN DaysPastTAT >= 4 THEN 1 ELSE 0 END AS "Past TAT 4+"
--,DocumentCount AS "Document Count"
,FirmDisplayName AS "Firm"
,FirmSalesRegion AS "Region"

-- Added for EOD Pending
,CASE WHEN T1.transactiontypeid = 2 --this is a pending record
                  AND T1.LoggedDate < Current_Date  --that was logged prior to today
				  AND (CompRec.CompDate > T1.LoadDate OR CompRec.CompDate IS NULL) --that was completed after the load date of this pending record or hasn't been completed yet
				  THEN 1 ELSE 0 END AS "EOD Pending Indicator" 
-- End of change
,CATSExpectedCompletedDate AS "Follow Up Date"
,CompletedIndicator AS "Completed Indicator"


FROM PROD_DMA_VW.ACT_ADO_CURR_INTEGRATED_VW T1  --Removed this mart PSC_MART_CURR_IVW T1
LEFT OUTER JOIN (SELECT GoalValue, DepartmentID, FunctionID FROM PROD_DMA_VW.GOAL_DIM_VW WHERE EndDate = '9999-12-31' AND GoalTypeID = 5) T2  --added 4/13/2020
ON T1.FunctionID = T2.FunctionID AND T1.DepartmentID = T2.DepartmentID --added 4/13/2020

-- Added for EOD Pending
LEFT 
JOIN (SELECT DISTINCT
                              a.sourcetransactionid AS SourceTrans,
                              First_Value( a.CompletedDate) Over (PARTITION BY a.sourcetransactionid
							  ORDER BY a.SequenceNumber DESC, LoadDate DESC) AS CompDate  
                FROM PROD_dma_vw.act_ado_integrated_fct_vw AS a
	         WHERE a.completedindicator = 1 --completed
				    AND a.transactiontypeid = 3 --completed
					AND a.completeddate < Current_Date) AS CompRec --exclude completed today bc today isn't over yet
   ON CompRec.SourceTrans = T1.SourceTransactionId
-- end of change 

WHERE (WorkEventDepartmentID = 48
OR T1. DepartmentID = 48)
AND (TransactionTypeId IN (1,3) OR Cast(loggeddate AS DATE) >=  (Add_Months(Current_Date, -36))) --Added to limit pending records to rolling 3 years
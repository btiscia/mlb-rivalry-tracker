/*
* This routine pulls daily transactions 

*  Peer Review & Change Log:
*  Peer Review : 
*  Source for this routine is DEV_DMA_VW.ACT_DMS_CURR_INTEGRATED_VW  and  DEV_DMA_VW.DATE_DIM_VW
*  Author: Lorraine Christian
*  Created: 3/4/2019
*  Revised:  10/2 Trex and Work Tracking added to view.          11/8/2019 removed the DATE_DIM_VW     
*  Revised:  11/13/2019 Pointed to QA

======================================================================
                
======================================================================
*/


SELECT TransactionTypeName AS "Transaction Type"
,SourceActivityID AS "ActivityID"
,T1.SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,ItemCount AS "Transaction Count"
,CASE 
     WHEN TRANSACTIONTYPEID =1 THEN  Cast(ReceivedDate AS TIMESTAMP(6))
     WHEN TRANSACTIONTYPEID = 2 THEN Cast(LoadDate AS TIMESTAMP(6))
     WHEN TRANSACTIONTYPEID = 3 THEN LongCompletedDate
END AS "Date"    
,LoggedDate AS "Logged Date"
,Coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"    
,Coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
,EmployeeRoleName AS "Employee Role Name"
,TeamName    AS "Team Name"
,FunctionName    AS "Function Name"
,SegmentName    AS "Segment Name"
,WorkEventName    AS "Work Event Name"
,Priority    
,AdminSystem AS "Admin System"    
,SystemName AS "System Name"
,ServiceChannelName    AS "Service Channel Code"
,PartyTypeName    AS "Party Type Name"
,SiteName AS "Site Name"
,WorkEventNumber    AS "Work Event Number"
,T1.ExpectedCompletedDate AS "Expected Completed Date"
,TAT
,DaysPastTAT AS "Days Past TAT"
,MetExpectedIndicator AS "Met Expected Indicator"
,MetExpected AS "Met Expected"
,CurrentProdCredit AS "Productivity Credits"
,NIGODescription
,NIGOCode AS "NIGO Code"
,IGOIndicator AS "IGO Indicator"
,FlexIndicator AS "Flex Indicator"
,ActionableIndicator AS "Actionable Indicator"
,CASE WHEN SourceTransactionID IS NULL THEN 0
    ELSE 1
END AS "Completed Flag"
,ShortComment AS "Comments"
,T1.TransDate AS "Trans Date"
,TransactionTypeID AS "Transaction Type ID" 
,DocumentCount AS "Document Count"
FROM PROD_DMA_VW.ACT_DMS_PIT_INTEGRATED_VW T1 
WHERE (WorkEventDepartmentID = 13 OR DepartmentID in (13, 51))
AND "Date" >= Add_Months(Current_Date, -3)
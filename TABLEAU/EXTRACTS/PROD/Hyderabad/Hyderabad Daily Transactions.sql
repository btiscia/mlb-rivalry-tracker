/*
* This routine pulls daily transactions for Hyderabad

*  Peer Review & Change Log:
*  Peer Review : 
*  Source for this routine is PROD_DMA_VW.ACT_DMS_CURR_INTEGRATED_VW  and  PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW and PROD_DMA_VW.DATE_DIM_VW
*  Author: Kristin Carlile
*  Created: 8/4/2021
*/

SELECT 'Received' AS "Transaction Type"
,ActivityID AS "ActivityID"
,cast(SourceTransactionID AS VARCHAR(50)) AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,Cast(ReceivedDate AS TIMESTAMP(6)) AS "Date"    
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
,ExpectedCompletedDate AS "Expected Completed Date"
,TAT
,DaysPastTAT AS "Days Past TAT"
,MetExpectedIndicator AS "Met Expected Indicator"
,MetExpected AS "Met Expected"
,CurrentProdCredit AS "Productivity Credits"
,NIGODescription
,cast(NIGOCode AS INTEGER) AS "NIGO Code"
,IGOIndicator AS "IGO Indicator"
,FlexIndicator AS "Flex Indicator"
,ActionableIndicator AS "Actionable Indicator"
,CASE WHEN SourceTransactionID IS NULL THEN 0
    ELSE 1
END AS "Completed Flag"
,ShortComment AS "Comments"
,TransDate AS "Trans Date"
,WorkEventDepartmentName as "Department Name"
,DepartmentCode as "Department Code"
,DivisionCode as "Division"
,COUNT(distinct ActivityID) as "Transaction Count"
--,TransactionTypeID AS "Transaction Type ID" 
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW 
WHERE (DepartmentID =51)
AND "Date" >= Add_Months(Current_Date, -3)
AND "Team Name" not in ('Business Content Management & Communications', 'Learning & Performance')
AND sequencenumber =1
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34, 35,36,37

UNION ALL

SELECT 'Pending' AS "Transaction Type"
,ActivityID AS "ActivityID"
,cast(iv.SourceTransactionID AS VARCHAR(50)) AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,Cast(TransDate AS TIMESTAMP(6)) AS "Date"    
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
,ExpectedCompletedDate AS "Expected Completed Date"
,TAT
,DaysPastTAT AS "Days Past TAT"
,MetExpectedIndicator AS "Met Expected Indicator"
,MetExpected AS "Met Expected"
,CurrentProdCredit AS "Productivity Credits"
,NIGODescription
,cast(NIGOCode AS INTEGER) AS "NIGO Code"
,IGOIndicator AS "IGO Indicator"
,FlexIndicator AS "Flex Indicator"
,ActionableIndicator AS "Actionable Indicator"
,CASE WHEN iv.SourceTransactionID IS NULL THEN 0
    ELSE 1
END AS "Completed Flag"
,ShortComment AS "Comments"
,TransDate AS "Trans Date"
,WorkEventDepartmentName as "Department Name"
,DepartmentCode as "Department Code"
,DivisionCode as "Division"
,COUNT(distinct activityid) as "Transaction Count"
--,TransactionTypeID AS "Transaction Type ID" 
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW as IV
 JOIN ( SELECT DISTINCT SourceTransactionID
                                ,Max(SequenceNumber) AS MAXSEQ
                   FROM PROD_DMA_VW.ACTIVITY_FCT_VW
                   GROUP BY 1 ) AS MAXTRANS 
           ON IV.SourceTransactionID = MAXTRANS.SourceTransactionID 
          AND IV.SequenceNumber = MAXTRANS.MAXSEQ
WHERE (DepartmentID =51)
AND "Date" >= Add_Months(Current_Date, -3)
AND "Team Name" not in ('Business Content Management & Communications', 'Learning & Performance')
AND completedindicator = 0
AND workeventdepartmentname is not null
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34, 35,36,37

UNION ALL

SELECT 'Completed' AS "Transaction Type"
,ActivityID AS "ActivityID"
,cast(SourceTransactionID AS VARCHAR(50)) AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,LongCompletedDate AS "Date"    
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
,ExpectedCompletedDate AS "Expected Completed Date"
,TAT
,DaysPastTAT AS "Days Past TAT"
,MetExpectedIndicator AS "Met Expected Indicator"
,MetExpected AS "Met Expected"
,CurrentProdCredit AS "Productivity Credits"
,NIGODescription
,cast(NIGOCode AS INTEGER) AS "NIGO Code"
,IGOIndicator AS "IGO Indicator"
,FlexIndicator AS "Flex Indicator"
,ActionableIndicator AS "Actionable Indicator"
,CASE WHEN SourceTransactionID IS NULL THEN 0
    ELSE 1
END AS "Completed Flag"
,ShortComment AS "Comments"
,TransDate AS "Trans Date"
,WorkEventDepartmentName as "Department Name"
,DepartmentCode as "Department Code"
,DivisionCode as "Division"
,COUNT(distinct ActivityID) as "Transaction Count"
FROM PROD_DMA_VW.TRANS_PIT_INTEGRATED_VW
WHERE (DepartmentID =51)
AND "Date" >= Add_Months(Current_Date, -3)
AND "Team Name" not in ('Business Content Management & Communications', 'Learning & Performance')
AND completedindicator = 1
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34, 35,36,37

UNION ALL

SELECT 'Completed' AS "Transaction Type"
,SourceActivityID AS "ActivityID"
,SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,LongCompletedDate AS "Date"    
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
,ExpectedCompletedDate AS "Expected Completed Date"
,TAT
,DaysPastTAT AS "Days Past TAT"
,MetExpectedIndicator AS "Met Expected Indicator"
,MetExpected AS "Met Expected"
,CurrentProdCredit AS "Productivity Credits"
,NIGODescription
,cast(NIGOCode AS INTEGER) AS "NIGO Code"
,IGOIndicator AS "IGO Indicator"
,FlexIndicator AS "Flex Indicator"
,ActionableIndicator AS "Actionable Indicator"
,CASE WHEN SourceTransactionID IS NULL THEN 0
    ELSE 1
END AS "Completed Flag"
,ShortComment AS "Comments"
,TransDate AS "Trans Date"
,WorkEventDepartmentName as "Department Name"
,DepartmentCode as "Department Code"
,DivisionCode as "Division"
,SUM(itemcount) as "Transaction Count"
FROM PROD_DMA_VW.ACT_DMS_PIT_INTEGRATED_VW
WHERE (DepartmentID =51)
AND "Date" >= Add_Months(Current_Date, -3)
AND "Team Name" not in ('Business Content Management & Communications', 'Learning & Performance')
AND "System Name" not in ('CATS')
AND transactiontypeid = 3
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34, 35,36,37

UNION ALL

SELECT 'Received' AS "Transaction Type"
,SourceActivityID AS "ActivityID"
,SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,Cast(ReceivedDate AS TIMESTAMP(6)) AS "Date"     
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
,ExpectedCompletedDate AS "Expected Completed Date"
,TAT
,DaysPastTAT AS "Days Past TAT"
,MetExpectedIndicator AS "Met Expected Indicator"
,MetExpected AS "Met Expected"
,CurrentProdCredit AS "Productivity Credits"
,NIGODescription
,cast(NIGOCode AS INTEGER) AS "NIGO Code"
,IGOIndicator AS "IGO Indicator"
,FlexIndicator AS "Flex Indicator"
,ActionableIndicator AS "Actionable Indicator"
,CASE WHEN SourceTransactionID IS NULL THEN 0
    ELSE 1
END AS "Completed Flag"
,ShortComment AS "Comments"
,TransDate AS "Trans Date"
,WorkEventDepartmentName as "Department Name"
,DepartmentCode as "Department Code"
,DivisionCode as "Division"
,SUM(itemcount) as "Transaction Count"
FROM PROD_DMA_VW.ACT_DMS_PIT_INTEGRATED_VW
WHERE (DepartmentID =51)
AND "Date" >= Add_Months(Current_Date, -3)
AND "Team Name" not in ('Business Content Management & Communications', 'Learning & Performance')
AND "System Name" not in ('CATS')
AND transactiontypeid = 1
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34, 35,36,37
UNION ALL

SELECT 'Pending' AS "Transaction Type"
,SourceActivityID AS "ActivityID"
,SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,Cast(ReceivedDate AS TIMESTAMP(6)) AS "Date"     
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
,ExpectedCompletedDate AS "Expected Completed Date"
,TAT
,DaysPastTAT AS "Days Past TAT"
,MetExpectedIndicator AS "Met Expected Indicator"
,MetExpected AS "Met Expected"
,CurrentProdCredit AS "Productivity Credits"
,NIGODescription
,cast(NIGOCode AS INTEGER) AS "NIGO Code"
,IGOIndicator AS "IGO Indicator"
,FlexIndicator AS "Flex Indicator"
,ActionableIndicator AS "Actionable Indicator"
,CASE WHEN SourceTransactionID IS NULL THEN 0
    ELSE 1
END AS "Completed Flag"
,ShortComment AS "Comments"
,TransDate AS "Trans Date"
,WorkEventDepartmentName as "Department Name"
,DepartmentCode as "Department Code"
,DivisionCode as "Division"
,SUM(itemcount) as "Transaction Count"
FROM PROD_DMA_VW.ACT_DMS_PIT_INTEGRATED_VW
WHERE (DepartmentID =51)
AND "Date" >= Add_Months(Current_Date, -3)
AND "Team Name" not in ('Business Content Management & Communications', 'Learning & Performance')
AND transactiontypeid = 2
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37
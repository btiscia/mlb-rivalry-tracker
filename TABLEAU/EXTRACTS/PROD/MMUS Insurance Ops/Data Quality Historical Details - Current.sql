---Current Historical -----For Data Quality
/* This routine provides Historical Current for Data Quality
* Peer Review & Change Log: 
* Peer Review Date: 
* Source for this routine is PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
*Revision Made: 7/9/2019 
*Revisions: Pending removed entirely and added Long Completed Date Revision by Kristin Carlile */


SELECT 
'Completed' AS "Transaction Type"
,SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,CompletedDate AS "Date"
,EmployeeRoleName AS "Employee Role Name"
,COALESCE(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"	
,COALESCE(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
,TeamName	AS "Team Name"
,FunctionName	AS "Function Name"
,SegmentName	AS "Segment Name"
,WorkEventName	AS "Work Event"
,Priority	
,AdminSystem AS "Admin System"	
,ProcessName "Process Name"	
,ProcessID AS "Process ID"
,ProcessOrder	AS "Process Order"	
,ServiceChannelName	AS "Service Channel Code"
,PartyTypeName	AS "Party Type Name"
,EmployeeOrganizationName AS "Employee Organization Name"
,EmployeeDepartmentName AS "Employee Department Name"
,SiteName AS "Site Name"
,WorkEventOranizationName	AS "Work Event Organization Name"
,WorkEventDepartmentName	AS "Work Event Department Name"
,PrimaryRoleName	AS "Primary Role Name"
,SystemName	AS "System Name"
,WorkEventNumber	AS "Work Event Number"
,DepartmentCode	 AS "Department Code"
,DivisionCode	AS "Division Code"
,TAT
,LongCompletedDate AS "Completed Time Stamp"
,NIGODescription
,ShortComment AS "Short Comments"
,MAX(TransDate)	AS "Max Trans Date"
,COUNT(DISTINCT ActivityID) AS "Transaction Count"
,TAT * "Transaction Count" AS "Total TAT Days"
,SUM(CASE WHEN MetExpectedIndicator = 1 AND MetExpected = 1 THEN 1 ELSE 0 END) AS "Met Expected Count"
,SUM(MetExpectedIndicator) AS "Met Expected Ind Count"
,SUM(CurrentProdCredit) AS "Productivity Credits"
,SUM(CASE WHEN IGOIndicator = 1 AND NIGOCode = '-99' THEN 1 ELSE 0 END) AS "NIGO Count"
,SUM(CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END) AS "IGO Count"
,SUM(IGOIndicator) AS "IGO NIGO Count"
,SUM(FlexIndicator)  AS "Flex Count"
,SUM(CASE WHEN DaysPastTAT <= 0 THEN 1 ELSE 0 END) AS "Met TAT Count"
,SUM(CASE WHEN DaysPastTAT = 1 THEN 1 ELSE 0 END) AS "Past TAT 1"
,SUM(CASE WHEN DaysPastTAT = 2 THEN 1 ELSE 0 END) AS "Past TAT 2"
,SUM(CASE WHEN DaysPastTAT = 3 THEN 1 ELSE 0 END) AS "Past TAT 3"
,SUM(CASE WHEN DaysPastTAT >= 4 THEN 1 ELSE 0 END) AS "Past TAT 4+"
FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
WHERE (WorkEventDepartmentID =17
OR DepartmentID = 17)
AND CompletedIndicator = 1
AND "Date" >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31, 32

/* UNION

SELECT 
'Pending' AS "Transaction Type"
,NULL AS "Source Transaction ID"
,CAST(NULL AS VARCHAR(40)) AS "Policy Number"
,LoadDate AS "Date"
,EmployeeRoleName AS "Employee Role Name"
,COALESCE(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"	
,COALESCE(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
,TeamName	AS "Team Name"
,FunctionName	AS "Function Name"
,SegmentName	AS "Segment Name"
,WorkEventName	AS "Work Event"
,Priority	
,AdminSystem AS "Admin System"	
,ProcessName "Process Name"	
,ProcessID AS "Process ID"
,ProcessOrder	AS "Process Order"	
,ServiceChannelName	AS "Service Channel Code"
,PartyTypeName	AS "Party Type Name"
,EmployeeOrganizationName AS "Employee Organization Name"
,EmployeeDepartmentName AS "Employee Department Name"
,SiteName AS "Site Name"
,WorkEventOranizationName	AS "Work Event Organization Name"
,WorkEventDepartmentName	AS "Work Event Department Name"
,PrimaryRoleName	AS "Primary Role Name"
,SystemName	AS "System Name"
,WorkEventNumber	AS "Work Event Number"
,DepartmentCode	 AS "Department Code"
,DivisionCode	AS "Division Code"
,NULL AS TAT
,CAST(NULL AS VARCHAR(5))  AS NIGODescription
,CAST(NULL AS VARCHAR(5))  AS  "Short Comments"
,MAX(TransDate)	AS "Max Trans Date"
,COUNT(DISTINCT ActivityID) AS "Transaction Count"
,NULL AS "Total TAT Days"
,SUM(CASE WHEN MetExpectedIndicator = 1 AND DaysPastTAT <= 0 THEN 1 ELSE 0 END) AS "Met Expected Count"
,SUM(MetExpectedIndicator) AS "Met Expected Ind Count"
,SUM(CurrentProdCredit) AS "Productivity Credits"
,NULL AS "NIGO Count"
,NULL AS "IGO Count"
,NULL AS "IGO NIGO Count"
,NULL AS "Flex Count"
,SUM(MetTAT) AS "Met TAT Count"
,SUM(PastTAT1) / "Transaction Count" AS "Past TAT 1"
,SUM(PastTAT2) / "Transaction Count" AS "Past TAT 2"
,SUM(PastTAT3)  / "Transaction Count" AS "Past TAT 3"
,SUM(PastTAT4) / "Transaction Count" AS "Past TAT 4+"
FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW LPI
LEFT JOIN
(SELECT
SourceTransactionID, 
MAX(DaysPastTAT) MaxTAT
,CASE WHEN MaxTAT  <= 0 THEN 1 ELSE 0 END AS MetTAT
,CASE WHEN MaxTAT  = 1 THEN 1 ELSE 0 END AS PastTAT1
,CASE WHEN MaxTAT  = 2 THEN 1 ELSE 0 END AS PastTAT2
,CASE WHEN MaxTAT  = 3 THEN 1 ELSE 0 END AS PastTAT3
,CASE WHEN MaxTAT  >= 4 THEN 1 ELSE 0 END AS PastTAT4
FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
WHERE  (WorkEventDepartmentID = 17
OR DepartmentID = 17)
AND PendingIndicator = 1
AND LoadDate >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1) MaxSub
ON LPI.SourceTransactionID = MaxSub.SourceTransactionID
AND LPI.DaysPastTAT = MaxSub.MaxTAT
WHERE(WorkEventDepartmentID =17
OR DepartmentID = 17)
AND PendingIndicator = 1
AND "Date" >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31 */

UNION

SELECT 
'Received' AS "Transaction Type"
,SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,ReceivedDate AS "Date"
,EmployeeRoleName AS "Employee Role Name"
,COALESCE(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"	
,COALESCE(ManagerlastName || ', ' || ManagerFirstName, 'Unkonwn') AS "Manager"
,TeamName	AS "Team Name"
,FunctionName	AS "Function Name"
,SegmentName	AS "Segment Name"
,WorkEventName	AS "Work Event"
,Priority	
,AdminSystem AS "Admin System"	
,ProcessName "Process Name"	
,ProcessID AS "Process ID"
,ProcessOrder	AS "Process Order"	
,ServiceChannelName	AS "Service Channel Code"
,PartyTypeName	AS "Party Type Name"
,EmployeeOrganizationName AS "Employee Organization Name"
,EmployeeDepartmentName AS "Employee Department Name"
,SiteName AS "Site Name"
,WorkEventOranizationName	AS "Work Event Organization Name"
,WorkEventDepartmentName	AS "Work Event Department Name"
,PrimaryRoleName	AS "Primary Role Name"
,SystemName	AS "System Name"
,WorkEventNumber	AS "Work Event Number"
,DepartmentCode	 AS "Department Code"
,DivisionCode	AS "Division Code"
,TAT
,LongCompletedDate AS "Completed Time Stamp"
,CAST(NULL AS VARCHAR(5)) AS NIGODescription
,ShortComment AS "Short Comments"
,MAX(TransDate)	AS "Max Trans Date"
,COUNT(DISTINCT ActivityID) AS "Transaction Count"
,NULL AS "Total TAT Days"
,NULL AS "Met Expected Count"
,NULL AS "Met Expected Ind Count"
,SUM(CurrentProdCredit) AS "Productivity Credits"
,NULL AS "NIGO Count"
,NULL AS "IGO Count"
,NULL AS "IGO NIGO Count"
,NULL AS "Flex Count"
,NULL AS "Met TAT Count"
,NULL AS "Past TAT 1"
,NULL AS "Past TAT 2"
,NULL AS "Past TAT 3"
,NULL AS "Past TAT 4+"
FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
WHERE  (WorkEventDepartmentID =17
OR DepartmentID = 17)
AND SequenceNumber = 1
AND "Date" >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31, 32
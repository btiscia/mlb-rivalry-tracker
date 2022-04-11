/*
This routine provides Historical  Current  for Service Center
* Peer Review & Change Log: 
* Peer Review Date: 
* Source for this routine is PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
*Revision Made: 7/9/2019 
*Revisions: Pending removed entirely, added Completed Time Stamp. Revision by Kristin Carlile
*Revision Made: 8/11/2020 
*Revisions:  Requestor Type, Requestor Name and SourceFirmNumber added.  Revision by Lorraine Christian
*Revision Made: 1/25/21 - removed dept ID 2 as DI has own dashboards now -KC
*/

SELECT 
'Completed' AS "Transaction Type"
,SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,CASE WHEN BCCIndicator = 0
	THEN 'N'
	ELSE 'Y'
END AS "Society 1851"
,CompletedDate AS "Date"
,EmployeeRoleName AS "Employee Role Name"
,COALESCE(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"	
,COALESCE(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
,TeamName	AS "Team Name"
,FunctionName	AS "Function Name"
,SegmentName	AS "Segment Name"
,WorkEventName	AS "Work Event Name"
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
,ShortComment
,CASE WHEN SourceFirmNumber = '--'
	THEN NULL
	ELSE SourceFirmNumber
END AS "Requesting Firm"
,RequestorTypeCode AS "Requestor Type Code"
,RequestorTypeName  AS "Requestor Type Name"
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
WHERE (WorkEventDepartmentID IN (29,30,31,32,33,34,35)
OR DepartmentID IN (29,30,31,32,33,34,35))
AND CompletedIndicator = 1
AND "Date" >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33, 34, 35, 36
/* UNION

SELECT 
'Pending' as "Transaction Type"
,NULL as "Source Transaction ID"
,cast(NULL as varchar(40)) as "Policy Number"
,CASE WHEN BCCIndicator = 0
	THEN 'N'
	ELSE 'Y'
END AS "Society 1851"
,LoadDate as "Date"
,EmployeeRoleName as "Employee Role Name"
,coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') as "Employee"	
,coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') as "Manager"
,TeamName	as "Team Name"
,FunctionName	as "Function Name"
,SegmentName	as "Segment Name"
,WorkEventName	as "Work Event Name"
,Priority	
,AdminSystem as "Admin System"	
,ProcessName "Process Name"	
,ProcessID as "Process ID"
,ProcessOrder	as "Process Order"	
,ServiceChannelName	as "Service Channel Code"
,PartyTypeName	as "Party Type Name"
,EmployeeOrganizationName as "Employee Organization Name"
,EmployeeDepartmentName as "Employee Department Name"
,SiteName as "Site Name"
,WorkEventOranizationName	as "Work Event Organization Name"
,WorkEventDepartmentName	as "Work Event Department Name"
,PrimaryRoleName	as "Primary Role Name"
,SystemName	as "System Name"
,WorkEventNumber	as "Work Event Number"
,DepartmentCode	 as "Department Code"
,DivisionCode	as "Division Code"
,NULL as TAT
,cast(NULL as varchar(5))  as NIGODescription
,cast(NULL as varchar(100)) as ShortComment
,MAX(TransDate)	as "Max Trans Date"
,COUNT(distinct ActivityID) as "Transaction Count"
,NULL as "Total TAT Days"
,SUM(CASE WHEN MetExpectedIndicator = 1 AND DaysPastTAT <= 0 THEN 1 ELSE 0 END) as "Met Expected Count"
,SUM(MetExpectedIndicator) as "Met Expected Ind Count"
,SUM(CurrentProdCredit) as "Productivity Credits"
,NULL as "NIGO Count"
,NULL as "IGO Count"
,NULL as "IGO NIGO Count"
,NULL as "Flex Count"
,SUM(MetTAT) as "Met TAT Count"
,SUM(PastTAT1) / "Transaction Count" as "Past TAT 1"
,SUM(PastTAT2) / "Transaction Count" as "Past TAT 2"
,SUM(PastTAT3)  / "Transaction Count" as "Past TAT 3"
,SUM(PastTAT4) / "Transaction Count" as "Past TAT 4+"
FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW LPI
LEFT JOIN
(SELECT
SourceTransactionID, 
MAX(DaysPastTAT) MaxTAT
,CASE WHEN MaxTAT  <= 0 THEN 1 ELSE 0 END as MetTAT
,CASE WHEN MaxTAT  = 1 THEN 1 ELSE 0 END as PastTAT1
,CASE WHEN MaxTAT  = 2 THEN 1 ELSE 0 END as PastTAT2
,CASE WHEN MaxTAT  = 3 THEN 1 ELSE 0 END as PastTAT3
,CASE WHEN MaxTAT  >= 4 THEN 1 ELSE 0 END as PastTAT4
FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
WHERE  (WorkEventDepartmentID IN (34,35)
OR DepartmentID IN (34,35))
AND PendingIndicator = 1
AND LoadDate >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1) MaxSub
ON LPI.SourceTransactionID = MaxSub.SourceTransactionID
AND LPI.DaysPastTAT = MaxSub.MaxTAT
WHERE(WorkEventDepartmentID IN (34,35)
OR DepartmentID IN (34,35))
AND PendingIndicator = 1
AND "Date" >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32 */

UNION

SELECT 
'Received' AS "Transaction Type"
,SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,CASE WHEN BCCIndicator = 0
	THEN 'N'
	ELSE 'Y'
END AS "Society 1851"
,ReceivedDate AS "Date"
,EmployeeRoleName AS "Employee Role Name"
,COALESCE(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"	
,COALESCE(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
,TeamName	AS "Team Name"
,FunctionName	AS "Function Name"
,SegmentName	AS "Segment Name"
,WorkEventName	AS "Work Event Name"
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
,ShortComment
,CASE WHEN SourceFirmNumber = '--'
	THEN NULL
	ELSE SourceFirmNumber
END AS "Requesting Firm"
,RequestorTypeCode AS "Requestor Type Code"
,RequestorTypeName  AS "Requestor Type Name"
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
WHERE  (WorkEventDepartmentID IN (29,30,31,32,33,34,35)
OR DepartmentID IN (29,30,31,32,33,34,35))
AND SequenceNumber = 1
AND "Date" >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32, 33,34,35,36
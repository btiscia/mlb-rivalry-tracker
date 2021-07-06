/*
This routine provides Historical  Current  Completed for MMSD related Transactions
Source for this routine is PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
Created: 6/1/2021 
Revisions: None Yet
Revision by John Avgoustakis
*/

SELECT 
'Completed' as "Transaction Type"
,MMSDIndicator
,SellingFirmDisplayName as "Firm Name"
,SellingRegion as "Region"
,SourceTransactionID as "Source Transaction ID"
,HoldingKey as "Policy Number"
,CASE WHEN BCCIndicator = 0
	THEN 'N'
	ELSE 'Y'
END AS "Society 1851"
,CompletedDate as "Date"
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
,TAT
,LongCompletedDate AS "Completed Time Stamp"
,NIGODescription
,ShortComment
,RequestorTypeCode AS "Requestor Type Code"
,RequestorTypeName  AS "Requestor Type Name"
,MAX(TransDate)	as "Max Trans Date"
,COUNT(distinct ActivityID) as "Transaction Count"
,TAT * "Transaction Count" as "Total TAT Days"
,SUM(CASE WHEN MetExpectedIndicator = 1 AND MetExpected = 1 THEN 1 ELSE 0 END) as "Met Expected Count"
,SUM(MetExpectedIndicator) as "Met Expected Ind Count"
,SUM(CurrentProdCredit) as "Productivity Credits"
,SUM(CASE WHEN IGOIndicator = 1 AND NIGOCode = '-99' THEN 1 ELSE 0 END) as "NIGO Count"
,SUM(CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END) as "IGO Count"
,SUM(IGOIndicator) as "IGO NIGO Count"
,SUM(FlexIndicator)  as "Flex Count"
,SUM(CASE WHEN DaysPastTAT <= 0 THEN 1 ELSE 0 END) as "Met TAT Count"
,SUM(CASE WHEN DaysPastTAT = 1 THEN 1 ELSE 0 END) as "Past TAT 1"
,SUM(CASE WHEN DaysPastTAT = 2 THEN 1 ELSE 0 END) as "Past TAT 2"
,SUM(CASE WHEN DaysPastTAT = 3 THEN 1 ELSE 0 END) as "Past TAT 3"
,SUM(CASE WHEN DaysPastTAT >= 4 THEN 1 ELSE 0 END) as "Past TAT 4+"
FROM PROD_DMA_VW.TRANS_CURR_MMSD_VW
WHERE CompletedIndicator = 1
AND "Date" >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33, 34, 35, 36, 37, 38, 39
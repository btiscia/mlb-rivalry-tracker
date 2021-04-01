--Removed Pending/ Completed Unions in this reporting view

SELECT
'Received' AS "Transaction Type"
,systemDivisionname
,SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,ReceivedDate AS "Date"
,EmployeeRoleName AS "Employee Role Name"
,COALESCE(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"	
,COALESCE(ManagerlastName || ', ' || ManagerFirstName, 'Unkonwn') AS "Manager"
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
,CAST(NULL AS VARCHAR(5)) AS NIGODescription
,ShortComment
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
WHERE  (WorkEventDepartmentID IN (7,8)
OR DepartmentID IN (7,8))
AND SequenceNumber = 1
AND "Date" >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32

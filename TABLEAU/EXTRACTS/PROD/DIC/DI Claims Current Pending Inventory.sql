SELECT
LoadDate
,IntegratedActivityID AS "Integrated Activity ID"
,SourceTransactionID as "Source Transaction ID"
,SystemName AS "System Name"
,HoldingKey AS "Policy Number"
,BaseClaimNumber AS "Base Claim Number"
,ShortClaimNumber AS "Claim #"
,ReceivedDate AS "Received Date"
,ExpectedCompletedDate  AS "Expected Completed Date"
,DaysPending  AS "Days Pending"
,DaysPastTAT AS "Days Past TAT" 
,TAT
,TATGoal AS "TAT Goal"
,COALESCE(DemandCredit, ProductivityCredit) AS "Productivity Credits"
 ,COALESCE(EmployeeRoleName , 'Unknown') AS "Role"
,COALESCE(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee Name"	
,COALESCE(EmployeeManagerlastName || ', ' || EmployeeManagerFirstName, 'Unknown') AS "Manager Name"
,COALESCE(EmployeeTeamName, 'Unknown') AS "Team Name"
,COALESCE(WorkEventFunctionName, 'Unknown') AS "Function Name"
,COALESCE(WorkEventSegmentName, 'Unknown') AS "Segment Name"
,COALESCE(WorkEventWorkEventName, 'Unknown') AS "Work Event Name"
,COALESCE(EmployeeOrganizationName, 'Unknown') AS "Employee Organization Name"
,COALESCE(EmployeeDepartmentName, 'Unknown') AS "Employee Department Name"
,COALESCE(WorkEventOrganizationName, 'Unknown') AS "Work Event Organization Name"
,COALESCE(WorkEventDepartmentName	, 'Unknown') AS  "Work Event Department Name"
,COALESCE(WorkEventPrimaryRoleName, 'Unknown') AS "Work Event Primary Role Name"
,COALESCE(DIBSClaimantName, 'Unknown') AS "Claimaint Name" 
,COALESCE(LogEmployeeLastName || ', ' || LogEmployeeFirstName, 'Unknown') AS "Logged By"
,CASE WHEN SystemName = 'CATS'  THEN 'CATS' 
WHEN WorkEventSystemDepartmentName = 'Diary'  THEN 'DIBS Diary' 
WHEN WorkEventSystemDepartmentName = 'Payment'   THEN 'DIBS Payment' 
WHEN  WorkEventSystemDepartmentName = 'TREX CONTENT CLOSURE LETTER'   THEN 'TREX Closure Letter' 
WHEN  WorkEventSystemDepartmentName = 'TREX CONTENT STATUS LETTER'   THEN 'TREX Status Letter' 
WHEN  WorkEventSystemDepartmentName = 'TREX CONTENT'   THEN 'TREX Content'
WHEN  WorkEventSystemDepartmentName = 'TREX MAIL'   THEN 'TREX Mail'
WHEN  WorkEventSystemDepartmentName = 'TREX WORK'   THEN 'TREX Work'
WHEN SystemName = 'MEDVOC' THEN 'MEDVOC' 
ELSE 'UNKNOWN' END AS "System"
,PriorityName AS "Prioirty"
,ReviewStatus as "Work Status"
,COUNT(DISTINCT IntegratedActivityID) AS "Transaction Count"    
,MAX(TransDate)	AS "Transaction Date"


FROM Prod_DMA_VW.ACT_DIC_CURR_INTEGRATED_VW

WHERE
TransactionTypeID = 2
AND LoadDate = CURRENT_DATE
AND (RestrictedClaimIndicator = 0 OR RestrictedClaimIndicator IS NULL)

GROUP BY  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
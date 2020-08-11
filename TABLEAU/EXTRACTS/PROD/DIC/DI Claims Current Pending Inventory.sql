SELECT
T1.LoadDate
,T1.IntegratedActivityID AS "Integrated Activity ID"
,T1.SourceTransactionID as "Source Transaction ID"
,T1.SystemName AS "System Name"
,T1.HoldingKey AS "Policy Number"
,T1.BaseClaimNumber AS "Base Claim Number"
,T1.ShortClaimNumber AS "Claim #"
,T1.ReceivedDate AS "Received Date"
,T1.ExpectedCompletedDate  AS "Expected Completed Date"
,T1.DaysPending  AS "Days Pending"
,T1.DaysPastTAT AS "Days Past TAT" 
,T1.TAT
,T1.TATGoal AS "TAT Goal"
,COALESCE(T1.DemandCredit, T1.ProductivityCredit) AS "Productivity Credits"
,COALESCE(T1.EmployeeRoleName , 'Unknown') AS "Role"
,COALESCE(T1.EmployeeLastName || ', ' || T1.EmployeeFirstName, 'Unknown') AS "Employee Name"	
,COALESCE(T1.EmployeeManagerlastName || ', ' || T1.EmployeeManagerFirstName, 'Unknown') AS "Manager Name"
,COALESCE(T1.EmployeeTeamName, 'Unknown') AS "Team Name"
,COALESCE(T1.WorkEventFunctionName, 'Unknown') AS "Function Name"
,COALESCE(T1.WorkEventSegmentName, 'Unknown') AS "Segment Name"
,COALESCE(T1.WorkEventWorkEventName, 'Unknown') AS "Work Event Name"
,COALESCE(T1.EmployeeOrganizationName, 'Unknown') AS "Employee Organization Name"
,COALESCE(T1.EmployeeDepartmentName, 'Unknown') AS "Employee Department Name"
,COALESCE(T1.WorkEventOrganizationName, 'Unknown') AS "Work Event Organization Name"
,COALESCE(T1.WorkEventDepartmentName	, 'Unknown') AS  "Work Event Department Name"
,COALESCE(T1.WorkEventPrimaryRoleName, 'Unknown') AS "Work Event Primary Role Name"
,COALESCE(T1.DIBSClaimantName, 'Unknown') AS "Claimaint Name" 
,COALESCE(T1.LogEmployeeLastName || ', ' || T1.LogEmployeeFirstName, 'Unknown') AS "Logged By"
,CASE WHEN T1.SystemName = 'CATS'  THEN 'CATS' 
WHEN	T1.WorkEventSystemDepartmentName = 'Diary'  THEN 'DIBS Diary' 
WHEN	T1.WorkEventSystemDepartmentName = 'Payment'   THEN 'DIBS Payment' 
WHEN  T1.WorkEventSystemDepartmentName = 'TREX CONTENT CLOSURE LETTER'   THEN 'TREX Closure Letter' 
WHEN  T1.WorkEventSystemDepartmentName = 'TREX CONTENT STATUS LETTER'   THEN 'TREX Status Letter' 
WHEN  T1.WorkEventSystemDepartmentName = 'TREX CONTENT'   THEN 'TREX Content'
WHEN  T1.WorkEventSystemDepartmentName = 'TREX MAIL'   THEN 'TREX Mail'
WHEN  T1.WorkEventSystemDepartmentName = 'TREX WORK'   THEN 'TREX Work'
WHEN T1.SystemName = 'MEDVOC' THEN 'MEDVOC' 
ELSE 'UNKNOWN' END AS "System"
,T1.PriorityName AS "Prioirty"
,T1.ReviewStatus as "Work Status"
,T2.AppealIndicator AS " Appeal Indicator"
,T2.ContestableIndicator AS "Contestable Indicator"
,T2.ERISAIndicator AS "ERISA Indicator"
,T2.LateNoticeIndicator AS "Late Notice Indicator"
,T2.QuickDecisionIndicator AS "Quick  Decision Indicator"
,COUNT(DISTINCT T1.IntegratedActivityID) AS "Transaction Count"    
,MAX(T1.TransDate)	AS "Transaction Date"

FROM Prod_DMA_VW.ACT_DIC_CURR_INTEGRATED_VW T1
INNER JOIN PROD_DMA_VW.DI_CLAIM_CURR_DIM_VW T2 ON T1.CLAIMNUMBER = T2.CLAIMNUMBER

WHERE
TransactionTypeID = 2
AND T1.LoadDate = CURRENT_DATE
AND (T1.RestrictedClaimIndicator = 0 OR T1.RestrictedClaimIndicator IS NULL)

GROUP BY  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36
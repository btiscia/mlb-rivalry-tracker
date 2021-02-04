--DI Claims Historical Details - Point in Time

SELECT
TransactionTypeName AS "Transaction Type"
,T1.TransDate AS "Transaction Date"
,SourceTransactionID AS "Source Transaction ID"
,ShortClaimNumber AS "Short Claim Number"
,BaseClaimNumber AS "Base Claim Number"
,ClaimNumber AS "Claim Number"
,CASE
     WHEN TRANSACTIONTYPEID = 1 THEN ReceivedDate
     WHEN TRANSACTIONTYPEID = 2 THEN LoadDate
     WHEN TRANSACTIONTYPEID = 3 THEN CompletedDate
     WHEN TRANSACTIONTYPEID = 4 THEN LoggedDate
END AS "Date"   
,EmployeeRoleName AS "Employee Role Name"
,COALESCE(T1.EmployeeLastName || ', ' || T1.EmployeeFirstName, 'Unknown') AS "Employee"     
,COALESCE(T1.EmployeeManagerlastName || ', ' || T1.EmployeeManagerFirstName, 'Unknown') AS "Manager"
,EmployeeTeamName AS "Team Name"
,WorkEventFunctionName AS "Function Name"
,WorkEventSegmentName AS "Segment Name"
,WorkEventWorkEventName AS "Work Event Name"
,SystemName AS "System Name"
,EmployeeOrganizationName AS "Employee Organization Name"
,EmployeeDepartmentName AS "Employee Department Name"
---,EmployeeRoleGradeName AS "Employee Role Grade Name" ---Add once new view has migrated to Prod
--,LogEmployeeRoleGradeName AS "Logged Employee Role Grade Name" ---Add once new view has migrated to Prod
,WorkEventOrganizationName AS "Work Event Organization Name"
,WorkEventDepartmentName AS "Work Event Department Name"
,WorkEventPrimaryRoleName AS "Primary Role Name"
,WorkEventNumber AS "Work Event Number"
,WorkEventDepartmentCode AS "Department Code"
,WorkEventDivisionCode AS "Division Code"
,LoggedByTeamPartyID AS "Logged By Team Party ID"
,LoggedByPartyEmployeeID AS "Logged By Party Employee ID"
,CASE
    WHEN TRANSACTIONTYPEID = 2 THEN COALESCE(DemandCredit,ProductivityCredit)
    ELSE ProductivityCredit
END AS "Productivity Credits"
,TAT
,WorkEventDepartmentID
,1 AS "Transaction Count"
,TAT AS "Total TAT Days"
,CASE WHEN TRANSACTIONTYPEID = 3 THEN
CASE WHEN WorkEventMetExpectedIndicator = 1 AND MetExpected = 1 THEN 1 ELSE 0 END  
                                                            WHEN TRANSACTIONTYPEID = 2 THEN
                                                            CASE WHEN WorkEventMetExpectedIndicator = 1 AND DaysPastTAT<=0 THEN 1 ELSE 0 END  
                                                            END AS "Met Expected Count"
,WorkEventMetExpectedIndicator AS "Met Expected Ind Count"
,CASE WHEN T1.WorkEventGroupID = 8  THEN 1 ELSE 0 END ReferralIndicator
,CASE WHEN FilterGroupID IS NOT NULL THEN 1 ELSE 0 END TATIndicator
,CASE WHEN DaysPastTAT <= 0 THEN 1 ELSE 0 END AS "Met TAT Count"
,CASE WHEN DaysPastTAT = 1 THEN 1 ELSE 0 END AS "Past TAT 1"
,CASE WHEN DaysPastTAT = 2 THEN 1 ELSE 0 END AS "Past TAT 2"
,CASE WHEN DaysPastTAT = 3 THEN 1 ELSE 0 END AS "Past TAT 3"
,CASE WHEN DaysPastTAT >= 4 THEN 1 ELSE 0 END AS "Past TAT 4+"
,CASE WHEN SystemName = 'CATS'  THEN 'CATS'
WHEN WorkEventSystemDepartmentName = 'Diary'  THEN 'DIBS Diary'
WHEN WorkEventSystemDepartmentName = 'Payment'   THEN 'DIBS Payment'
WHEN  WorkEventSystemDepartmentName = 'TREX CONTENT CLOSURE LETTER'   THEN 'TREX Closure Letter'
WHEN  WorkEventSystemDepartmentName = 'TREX CONTENT STATUS LETTER'   THEN 'TREX Status Letter'
WHEN  WorkEventSystemDepartmentName = 'TREX CONTENT'   THEN 'TREX Content'
WHEN  WorkEventSystemDepartmentName = 'TREX MAIL'   THEN 'TREX Mail'
WHEN  WorkEventSystemDepartmentName = 'TREX WORK'   THEN 'TREX Work'
WHEN SystemName = 'MEDVOC' THEN 'MEDVOC'
ELSE 'UNKNOWN' END AS "Processing System"
,COALESCE(LogEmployeeLastName || ', ' || LogEmployeeFirstName, 'Unknown') AS "Logged by Employee"
,MedicalReviewRNL AS "Medical Review"
,CAST(MedicalReviewSupportDate AS DATE) "Medical Review Support Date"
,ReceivedDate AS "Received Date"  
,CompletedDate AS "Completed Date"
,T1.PaymentCheckDate AS "Payment Check Date"
,DIBSClaimantName AS "Claimant Name"
,PriorityName AS "Priority Name"
,DaysPastTAT AS "Days Past TAT"
,WorkEventGroupID
,WorkEventGroupName AS "Work Event Group Name"
,WorkEventGroupTypeName AS "Work Event Group Type Name"
,T5.RoleGradeName AS "Employee Role Grade Name" --remove once new view has migrated to Prod
,T6.RoleGradeName AS "LoggedEmployeeRoleGradeName"  --remove once new view has migrated to Prod
FROM PROD_DMA_VW.ACT_DIC_PIT_INTEGRATED_VW T1
LEFT JOIN (SELECT * FROM PROD_DMA_VW.FILTER_AND_CONV_LIST_VW WHERE FILTERGROUPID =30) T3 ON T1.WorkEventID = T3.SearchID
INNER JOIN Prod_DMA_VW.EMPLOYEE_PIT_DIM_VW T5 ON T1.TEAMPARTYID = T5.TEAMPARTYID --Added Temporarly untill view can be migrated to production
INNER JOIN Prod_DMA_VW.EMPLOYEE_PIT_DIM_VW T6 ON T1.LOGGEDBYTEAMPARTYID = T6.TEAMPARTYID --Added Temporarly untill view can be migrated to production
WHERE (RestrictedClaimIndicator = 0 OR RestrictedClaimIndicator IS NULL)
AND (WorkEventDepartmentID = 6 OR EmployeeDepartmentID = 6)
----DIC Historical Current

SELECT DISTINCT
TransactionTypeName AS "Transaction Type"  
,TransDate AS "Transaction Date"
,SourceTransactionID AS "Source Transaction ID" 
,HoldingKey AS "Policy Number" 
,BaseClaimNumber AS "Base Claim Number"  
,CASE 
     WHEN TRANSACTIONTYPEID = 1 THEN ReceivedDate
     WHEN TRANSACTIONTYPEID = 2 THEN LoadDate
     WHEN TRANSACTIONTYPEID = 3 THEN CompletedDate
     WHEN TRANSACTIONTYPEID = 4 THEN LoggedDate
END AS "Date"    
,EmployeeRoleName AS "Employee Role Name"  
,Coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"      
,Coalesce(EmployeeManagerlastName || ', ' || EmployeeManagerFirstName, 'Unknown') AS "Manager"  
,EmployeeTeamName AS "Team Name"  
,WorkEventFunctionName AS "Function Name"  
,WorkEventSegmentName AS "Segment Name"  
,WorkEventWorkEventName AS "Work Event Name"  
,SystemName AS "System Name"  
,EmployeeOrganizationName AS "Employee Organization Name"  
,EmployeeDepartmentName AS "Employee Department Name"        
,WorkEventOrganizationName AS "Work Event Organization Name"  
,WorkEventDepartmentName AS "Work Event Department Name"  
,WorkEventPrimaryRoleName AS "Primary Role Name"  
,WorkEventNumber AS "Work Event Number"  
,WorkEventDepartmentCode AS "Department Code"  
,WorkEventDivisionCode AS "Division Code"  
,LoggedByTeamPartyID AS "Logged By Team Party ID"
,LoggedByPartyEmployeeID AS "Logged By Party Employee ID"
,Coalesce(DemandCredit, ProductivityCredit) AS "Productivity Credits"
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
,Coalesce(LogEmployeeLastName || ', ' || LogEmployeeFirstName, 'Unknown') AS "Logged by Employee" 
,MedicalReviewRNL AS "Medical Review"
,Cast(MedicalReviewSupportDate AS DATE) "Medical Review Support Date"
,ReceivedDate AS "Received Date"   
,CompletedDate AS "Completed Date"
,DIBSClaimantName AS "Claimant Name"
,PriorityName AS "Priority Name" 
FROM PROD_DMA_VW.ACT_DIC_CURR_INTEGRATED_VW
WHERE (WorkEventDepartmentID = 6 OR EmployeeDepartmentID = 6)
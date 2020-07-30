----DIC Daily Transactions

SELECT TransactionTypeName AS "Transaction Type"
,IntegratedActivityID 
,SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,ShortClaimNumber AS "Short Claim Number"
,BaseClaimNumber AS "Base Claim Number"
,ClaimNumber AS "Claim Number"
,1 AS "Transaction Count"
,CASE 
     WHEN TRANSACTIONTYPEID = 1 THEN ReceivedDate
     WHEN TRANSACTIONTYPEID = 2 THEN LoadDate
     WHEN TRANSACTIONTYPEID = 3 THEN CompletedDate
     WHEN TRANSACTIONTYPEID = 4 THEN LoggedDate
END AS "Date"    
,LoggedDate AS "Logged Date"
,Coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"    
,Coalesce(EmployeeManagerlastName || ', ' || EmployeeManagerFirstName, 'Unknown') AS "Manager"
,EmployeeRoleName AS "Employee Role Name"
,EmployeeTeamName    AS "Team Name"
,WorkEventFunctionName    AS "Function Name"
,WorkEventSegmentName    AS "Segment Name"
,WorkEventWorkEventName    AS "Work Event Name"
,SystemName AS "Data Source"
,WorkEventNumber    AS "Work Event Number"
,T1.ExpectedCompletedDate AS "Expected Completed Date"
--"Holidays" removed 7/8/2020 JayJohnson
,TAT
,DaysPastTAT AS "Days Past TAT"
,WorkEventMetExpectedIndicator AS "Met Expected Indicator"
,MetExpected AS "Met Expected"
,MedicalReviewRNL
,PriorityName as Priority
,ClaimCategory as Category
,ReviewStatus as "Work Status"
,CASE
    WHEN TRANSACTIONTYPEID = 2 THEN Coalesce(DemandCredit,ProductivityCredit)
    ELSE ProductivityCredit
END AS "Productivity Credits"
,WorkEventActionableIndicator AS "Actionable Indicator"
,CASE WHEN SourceTransactionID IS NULL THEN 0
    ELSE 1
END AS "Completed Flag"
,T1.TransDate AS "Trans Date"
,T1.PaymentCheckDate AS "Payment Check Date"
FROM PROD_DMA_VW.ACT_DIC_PIT_INTEGRATED_VW T1
WHERE (WorkEventDepartmentID = 6 OR EmployeeDepartmentID = 6)
                AND "Date" >= Add_Months(Current_Date, -3)
        AND TransactionTypeID IN (2,3,4)
        AND (RestrictedClaimIndicator = 0 OR RestrictedClaimIndicator IS NULL)
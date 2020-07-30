SELECT T1.ClaimNumber AS "Claim Number"
                , T2.ClaimDimensionUniqueID
                , T2.ShortClaimNumber AS "Short Claim Number"
                , T2.PolicyNumber AS "Policy Number"
                ,T2.ClaimCategory AS "Claim Category"
                , T2.ExaminerPartyEmployeeID
                , T4.EmployeeLastName || ', ' || T4.EmployeeFirstName AS "Examiner"
                , T4.ManagerLastName || ', ' || T4.ManagerFirstName AS "Manager"
                , T2.DisabilityDate
                , T2.OpenDate  AS "Open Date"
                , T1.ClaimStatusDate AS "Closed Date"
                , T1.ClaimStatusCode AS "Status Code"
                , T1.CloseRecloseReason "Close Reason Code"
                , T1.TransDate AS "Transaction Date"
                , T3.ClaimStatusDate AS "Last Approved Date"
                , T2.ICD1Description AS Diagnosis
                , T2.ICD1GroupName AS "Diagnosis Group"
                , T5.CloseReasonName AS "Close Reason Name"
                , T5.CloseReasonCategory AS "Close Reason Category"
FROM PROD_DMA_VW.DBO_DIBS_CLAIM_STATUS_VW T1 
INNER JOIN PROD_DMA_VW.DI_CLAIM_CURR_DIM_VW T2 ON T1.ClaimNumber = T2.ClaimNumber
LEFT JOIN (SELECT T1.*
                                                                                                FROM PROD_DMA_VW.DBO_DIBS_CLAIM_STATUS_VW T1
                                                                                                WHERE ClaimStatusCode = 'AC' AND Type2CurrentFlag = 1 AND ClaimStatusDate >= '2016-01-01'
                                                                                                QUALIFY ROW_NUMBER() OVER (PARTITION BY ClaimNumber ORDER BY ClaimStatusDate DESC) =1) T3 ON T1.ClaimNumber = T3.ClaimNumber
LEFT JOIN PROD_DMA_VW.EMPLOYEE_CURR_DIM_VW T4 ON T2.ExaminerPartyEmployeeID = T4.PartyEmployeeID
LEFT JOIN PROD_DMA_VW.DIC_CLOSE_REASON_LOV_VW T5 ON T1.CloseRecloseReason = T5.CloseReasonCode
WHERE T1.ClaimStatusCode IN ('CL','RC')
   				AND T2.OpenDate >= '2016-01-01' --Nothing opened prior to 1/1/2016
   				AND T1.Type2CurrentFlag = 1
   				AND T2.CurrentSubstatus LIKE ANY ('%AC%','%DN%')
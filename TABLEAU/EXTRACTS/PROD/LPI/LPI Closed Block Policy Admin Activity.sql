SELECT 
Pending."Transaction Type"
,Pending."Admin System"
,Pending."Policy Block"
,Pending."Department Name"
,Pending."Organization Name"
,Pending."Received Date"
,Pending."Pending Date"
,Completed."Completed Date"
,Pending."Expected Completion Date"
,Pending. "Policy Number"
,Pending."Source Transaction ID"
,Pending.WorkEventID
,Pending. "Work Event"
,Pending."Employee"
,Pending."Short Comments"
,Pending."Trans Date"
,Pending."TAT"
,Pending."Days Pending"
from 
(SELECT DISTINCT
CAST('Pending' as VARCHAR (15)) as "Transaction Type"
,AdminSystem as "Admin System"
,CASE
                WHEN TRIM(LEADING '0' FROM HoldingKey) LIKE ANY ('6%','7%') THEN 'PALLM'
                ELSE 'Former Datalife'
END "Policy Block"
,SystemDepartmentName as "Department Name"
,SystemDivisionName as "Organization Name"
,ReceivedDate "Received Date"
,LoadDate as "Pending Date"
,ExpectedCompletedDate as "Expected Completion Date"
,TRIM(LEADING '0' FROM HoldingKey) as "Policy Number"
,SourceTransactionID as "Source Transaction ID"
,WorkEventNumber as WorkEventID
,WorkEventName as "Work Event"
,coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') as "Employee"               
,ShortComment as "Short Comments"
,TransDate as "Trans Date"
,TAT
,CASE 
				WHEN  PendingIndicator = 1 THEN "Pending Date" - "Received Date" 
				ELSE NULL
END "Days Pending"
FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
WHERE
PendingIndicator = 1
AND 
((LENGTH(TRIM(LEADING '0' FROM HoldingKey)) = 8
AND AdminSystem in ('VNTG1','PALLM','MPR')
AND TRIM(LEADING '0' FROM HoldingKey) LIKE ANY ('6%','7%')
AND HoldingKey LIKE ('%0'))
OR
(AdminSystem in ('VNTG1')
AND LENGTH(TRIM(LEADING '0' FROM HoldingKey)) = 7
AND 
(TRIM(LEADING '0' FROM HoldingKeY) LIKE ANY ('6%','4%'))))) Pending

left join

(SELECT
SourceTransactionID
,CompletedDate as "Completed Date"
,TAT
FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
WHERE CompletedIndicator = 1) Completed

ON Pending."Source Transaction ID" = Completed.SourceTransactionID
WHERE "Received Date" >= '2015-01-01'



UNION



SELECT
'Completed' as "Transaction Type"
,AdminSystem as "Admin System"
,CASE
                WHEN TRIM(LEADING '0' FROM HoldingKey) LIKE ANY ('6%','7%') THEN 'PALLM'
                ELSE 'Former Datalife'
END "Policy Block"
,SystemDepartmentName as "Department Name"
,SystemDivisionName as "Organization Name"
,ReceivedDate as "Received Date"
,LoadDate as "Pending Date"
,CompletedDate as "Completed Date"
,ExpectedCompletedDate as "Expected Completion Date"
,TRIM(LEADING '0' FROM HoldingKey) as "Policy Number"
,SourceTransactionID as "Source Transaction ID"
,WorkEventNumber as WorkEventID
,WorkEventName as "Work Event"
,coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') as "Employee"   
,ShortComment as "Short Comments"
,TransDate as "Trans Date"
,TAT
,CASE 
				WHEN  PendingIndicator = 1 THEN "Pending Date" - "Received Date" 
				ELSE NULL
END "Days Pending"
FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
WHERE CompletedIndicator = 1
AND 
((LENGTH(TRIM(LEADING '0' FROM HoldingKey)) = 8
AND AdminSystem in ('VNTG1','PALLM','MPR')
AND TRIM(LEADING '0' FROM HoldingKey) LIKE ANY ('6%','7%')
AND HoldingKey LIKE ('%0'))
OR
(AdminSystem in ('VNTG1')
AND LENGTH(TRIM(LEADING '0' FROM HoldingKey)) = 7
AND TRIM(LEADING '0' FROM HoldingKey) LIKE ANY ('6%','4%')))
AND "Received Date" >= '2015-01-01'
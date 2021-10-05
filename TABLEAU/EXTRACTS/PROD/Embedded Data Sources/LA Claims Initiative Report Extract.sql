/* 
NAME: LIFE CLAIMS INITIATIVE REPORT
CREATED BY: Jason Johnson, Vincent Boanaddio
 */


SELECT DISTINCT T1.HoldingKey AS PolicyNumber
, T1.AdminSystem
, T1.WorkEventName AS "Work Event"
,Case when T1.GroupID = 15 THEN 'Forms Sent'
	When T1.GroupID = 16 THEN 'Forms Not Sent'
	Else 'Unknown'
	End As Exam
, T1.ReceivedDate AS ExamRecdDate
, T1.CompletedDate AS ExamCpltDate
, T1.AssignedTo  AS ExamAssignedTo
, T2.WorkEventName AS Contact
, T2.ReceivedDate AS ContactRcvdDate
, T2.CompletedDate  AS ContactCpltDate
, T2.AssignedTo AS ContactAssignedTo
, T3.WorkEventName AS Proof
, T3.ReceivedDate AS ProofRcvdDate
, T4.CompletedDate  AS ProofCpltDate
, T5.WorkEventName AS Payment
, T5.MinReceivedDate AS PaymentMinRcvdDate
, T5.MaxReceivedDate AS PaymentMaxRcvdDate
, T5.MinCompletedDate  AS PaymentMinCpltDate
, T5.MaxCompletedDate AS PaymentMaxCpltDate
, T5.PaymentCount
,T2.ReceivedDate-T1.ReceivedDate as "ExamSt-ContactStCT"
--,T5.MinReceivedDate-T1.ReceivedDate as "Min Total Payment CycleTime" ---Corrected 4/20/20
,T5.MinCompletedDate -T1.ReceivedDate as "Min Total Payment CycleTime"
, T5.MaxCompletedDate-T1.ReceivedDate as "Max Total Payment CycleTime"
--,T5.MinReceivedDate-T3.ReceivedDate as "Min Prof-Payment Cycle Time"---Corrected 4/20/20
--,T5.MinCompletedDate -T3.ReceivedDate as "Min Prof-Payment Cycle Time"  ---Updated to new calc 4/20/20
--, T5.MaxCompletedDate-T3.ReceivedDate as "Max Prof-Payment Cycle Time"---Updated to new calc 4/20/20
,T5.MinCompletedDate-T4.CompletedDate as"Min Prof-Payment Cycle Time"
,T5.MaxCompletedDate-T4.CompletedDate as "Max Prof-Payment Cycle Time"

 FROM (SELECT HoldingKey, AdminSystem, SourceTransactionID, SequenceNumber, WorkEventName, WorkEventID,GroupID, ReceivedDate, CompletedDate, EmployeeLastName||','||EmployeeFirstName AS AssignedTo
                FROM      PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
                WHERE   WORKEVENTID IN (25654,25655,26799,26798,26797,26795,26796,26790,26794,26791,26792,26793)) T1
             
--- CONTACT             
LEFT JOIN (SELECT HoldingKey, AdminSystem, SourceTransactionID, WorkEventName, WorkEventID, ReceivedDate, CompletedDate, EmployeeLastName||','||EmployeeFirstName AS AssignedTo
                        FROM      PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
                        WHERE   WORKEVENTID IN (25663,25662)
						QUALIFY ROW_NUMBER() OVER (PARTITION BY HoldingKey, SourceTransactionID ORDER BY SequenceNumber DESC) = 1)  AS T2 ON T1.HoldingKey = T2.HoldingKey AND T1.AdminSystem = T2.AdminSystem
                      
--- PROOF FIRST RECEIVED                     
LEFT JOIN (SELECT HoldingKey, AdminSystem, WorkEventName, WorkEventID, MIN(ReceivedDate) ReceivedDate
FROM      PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
    WHERE   WORKEVENTID IN (25656,25661,25665)
   GROUP BY 1,2,3,4) T3 ON T1.HoldingKey = T3.HoldingKey AND T1.AdminSystem = T3.AdminSystem
  
--- PROOF LAST COMPLETED                     
LEFT JOIN (SELECT HoldingKey, AdminSystem, WorkEventName, WorkEventID, MAX(CompletedDate) CompletedDate
FROM      PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
    WHERE   WORKEVENTID IN (25656,25661,25665)
   GROUP BY 1,2,3,4) T4 ON T1.HoldingKey = T4.HoldingKey AND T1.AdminSystem = T4.AdminSystem
                                       
 ---PAYMENT                    
LEFT JOIN (SELECT DISTINCT HoldingKey, AdminSystem, WorkEventName, WorkEventID, MIN(ReceivedDate) AS MinReceivedDate, MAX(ReceivedDate) AS MaxReceivedDate, MIN(CompletedDate) AS MinCompletedDate, MAX(CompletedDate) AS MaxCompletedDate, COUNT(DISTINCT SourceTransactionID) AS PaymentCount
                        FROM      PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
                        WHERE   WORKEVENTID = 25658
                       GROUP BY 1,2,3,4) T5 ON T1.HoldingKey = T5.HoldingKey AND T1.AdminSystem = T5.AdminSystem
                      
QUALIFY ROW_NUMBER() OVER (PARTITION BY T1.HoldingKey  ORDER BY T1.SourceTransactionID Desc, T1.SequenceNumber DESC) = 1
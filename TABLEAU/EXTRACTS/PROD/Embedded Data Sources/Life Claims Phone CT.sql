SELECT 
STARTEVENT.HoldingKey AS PolicyNumber, 
STARTEVENT.SourceTransactionID AS StartEventTransactionID, 
STARTEVENT.WorkEventName AS StartEventName, 
STARTEVENT.ReceivedDate AS StartEventRecdDate, 
STARTEVENT.CompletedDate AS StartEventCpltDate, 
STARTEVENT.AssignedTo AS StartEventAssignTo, 
ENDEVENT.SourceTransactionID AS EndEventTransactionID, 
ENDEVENT.WorkEventName AS EndEventName, 
ENDEVENT.ReceivedDate AS EndEventRcvdDate, 
ENDEVENT.CompletedDate AS EndEventCpltDate, 
ENDEVENT.AssignedTo AS EndEventAssignTo, 
ENDEVENT.CompletedDate - STARTEVENT.ReceivedDate AS CycleTime


FROM     
   (
         SELECT 
         TCI.HoldingKey, 
         TCI.AdminSystem,
         TCI.SourceTransactionID, 
         TCI.WorkEventName, 
         TCI.ReceivedDate, 
         TCI.CompletedDate, 
         TCI.EmployeeLastName||','||TCI.EmployeeFirstName AS AssignedTo, 
         RANK() OVER(PARTITION BY TCI.HoldingKey
                           ORDER BY MIN(TCI.LoggedDate)) AS RCOUNT
                           
         FROM     
         PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW AS TCI 
         INNER JOIN
               (
                      SELECT SourceTransactionID, MAX(SequenceNumber) AS MAXSEQ
                       FROM      PROD_DMA_VW.ACTIVITY_FCT_VW
                       GROUP BY 1
                 ) AS MAXTRANS 
         ON TCI.SourceTransactionID = MAXTRANS.SourceTransactionID 
         AND TCI.SequenceNumber = MAXTRANS.MAXSEQ
         
         WHERE  TCI.WorkEventNumber IN ('10541', '10542', '10543', '10544', '10552','4356','10269','9852','9849','9850','9848','9847','9853','9851')
         AND
         TCI.ReceivedDate>='2017-04-01'

         GROUP BY 1, 2, 3, 4, 5, 6,7
   ) 
   AS STARTEVENT 

INNER JOIN
   (
       SELECT 
       HoldingKey, 
       AdminSystem,
       SourceTransactionID, 
       WorkEventName, 
       ReceivedDate, 
       CompletedDate, 
       EmployeeLastName||','||EmployeeFirstName AS AssignedTo
        
        FROM      PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
        
        WHERE   WorkEventNumber IN ('10345', '10346') 
        AND CompletedIndicator = 1
   ) 
   AS ENDEVENT 
ON STARTEVENT.HoldingKey = ENDEVENT.HoldingKey
AND
STARTEVENT.AdminSystem=ENDEVENT.AdminSystem

WHERE  STARTEVENT.RCOUNT = '1'

GROUP BY 
1,2,3,4,5,6,7,8,9,10,11,12
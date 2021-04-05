SELECT
JobNumber,
JobName,
TaskNumber,
CASE WHEN TaskName IS NULL THEN 'Missing Task Name'
ELSE TaskName END AS TaskName,
CoreAdd AS RecordsAdded,
CoreUpdated AS RecordsUpdated,
BeginDTM,
EndDTM,
PassFail,
MonthYear

FROM (

SELECT 
  T1.JobID AS JobNumber
, T3.JobName
, T1.TaskID AS TaskNumber
, T2.TaskName
, T1.CoreAdd
, T1.CoreUpdated
, T1.BeginDateTimeStamp AS BeginDTM
, T1.EndDateTimeStamp AS EndDTM
,CAST(T1.BeginDateTimeStamp AS DATE FORMAT 'MM-YYYY') AS MonthYear
, CASE 
                WHEN T1.TaskID = 51  AND CAST(T1.BeginDateTimeStamp AS DATE) <= '2019-03-22' THEN 'BAD'  
                WHEN T1.TaskID = 45  AND CAST(T1.BeginDateTimeStamp AS DATE) <= '2019-03-22' THEN 'BAD'  
                WHEN T1.TaskID = 285 AND CAST(T1.BeginDateTimeStamp AS DATE) <= '2019-09-03' THEN 'BAD'  
                WHEN T1.TaskID = 285 AND CAST(T1.BeginDateTimeStamp AS DATE) >= '2019-11-01' 
                                                                                                                                                                  AND CAST(T1.BeginDateTimeStamp AS DATE) <= '2020-01-15' THEN 'BAD' 
                WHEN T1.TaskID = 287 AND CAST(T1.BeginDateTimeStamp AS DATE) <= '2019-09-03' THEN 'BAD'  
                WHEN T1.TaskID = 286 AND CAST(T1.BeginDateTimeStamp AS DATE) <= '2019-09-03' THEN 'BAD'  
                ELSE 'GOOD' END AS RecordType
, CASE WHEN T1.EndDateTimeStamp IS NULL THEN 'Fail' 
                                                                ELSE 'Pass' END AS PassFail

FROM PROD_DMA_VW.JOB_LOG_QA_VW T1

LEFT OUTER JOIN  PROD_DMA_VW.TASK_LOV_VW T2 ON T1.TaskID = T2.TaskID
LEFT OUTER JOIN PROD_DMA_VW.JOB_LOV_VW          T3 ON T1.JobID = T3.JobID

WHERE CAST(T1.BeginDateTimeStamp AS DATE) >= (Current_Date -365))A

WHERE RecordType = 'Good'
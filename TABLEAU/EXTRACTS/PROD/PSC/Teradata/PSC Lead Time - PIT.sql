SELECT 
Pending.*
,Coalesce("Completed Date", PreviousBusinessDay) AS "Date" 
,Coalesce("Completed Count", 0) AS "Completed Count" 
FROM
(SELECT 
LoadDate AS "Pending Date"
,DD.PreviousBusinessDay
,PartyTypeName AS "Party Type Name"
,ServiceChannelName AS "Service Channel Code"
,TeamName AS "Team Name"
,FunctionName AS "Function Name"
,SegmentName AS "Segment Name"
,WorkEventName AS "Work Event Name" 
,Sum(ItemCount) AS "Pending Count"
FROM PROD_DMA_VW.PSC_MART_PIT_IVW PIV
LEFT JOIN PROD_DMA_VW.DATE_DIM_VW DD
ON PIV.LoadDate = DD.ShortDate
WHERE (WorkEventDepartmentID = 4
OR DepartmentID = 4) 
AND TransactionTypeID = 2
AND LoadDate >= Current_Date - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7,8) AS Pending
LEFT JOIN 
(SELECT 
CompletedDate AS "Completed Date"
,PartyTypeName AS "Party Type Name"
,ServiceChannelName AS "Service Channel Code"
,TeamName AS "Team Name"
,FunctionName AS "Function Name"
,SegmentName AS "Segment Name"
,WorkEventName AS "Work Event Name" 
,Sum(ItemCount) AS "Completed Count"
FROM PROD_DMA_VW.PSC_MART_PIT_IVW
WHERE (WorkEventDepartmentID = 4
OR DepartmentID = 4) 
AND TransactionTypeID = 3
AND CompletedDate >= Current_Date - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7) AS Completed
ON Pending.PreviousBusinessDay = Completed."Completed Date"
AND Pending."Party Type Name" = Completed."Party Type Name"
AND Pending."Service Channel Code" = Completed."Service Channel Code"
AND Pending."Team Name" = Completed."Team Name"
AND Pending."Function Name"= Completed."Function Name"
AND Pending."Segment Name"= Completed."Segment Name"
AND Pending."Work Event Name" = Completed."Work Event Name"
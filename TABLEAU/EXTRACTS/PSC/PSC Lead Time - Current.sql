SELECT 
Pending.*
,coalesce("Completed Date", PreviousBusinessDay) as "Date" 
,coalesce("Completed Count", 0) as "Completed Count" 
FROM
(SELECT 
LoadDate as "Pending Date"
,DD.PreviousBusinessDay
,PartyTypeName as "Party Type Name"
,ServiceChannelName as "Service Channel Code"
,TeamName as "Team Name"
,FunctionName as "Function Name"
,SegmentName as "Segment Name"
,WorkEventName as "Work Event Name" 
,SUM(ItemCount) as "Pending Count"
FROM PROD_DMA_VW.PSC_MART_CURR_IVW PIV
LEFT JOIN PROD_DMA_VW.DATE_DIM_VW DD
ON PIV.LoadDate = DD.ShortDate
WHERE (WorkEventDepartmentID = 4
OR T1. DepartmentID = 4) 
AND LeadTimeIndicator = 1
AND PendingIndicator = 1
AND LoadDate >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7,8) as Pending
LEFT JOIN 
(SELECT 
CompletedDate as "Completed Date"
,PartyTypeName as "Party Type Name"
,ServiceChannelName as "Service Channel Code"
,TeamName as "Team Name"
,FunctionName as "Function Name"
,SegmentName as "Segment Name"
,WorkEventName as "Work Event Name" 
,SUM(ItemCount) as "Completed Count"
FROM PROD_DMA_VW.PSC_MART_CURR_IVW
WHERE (WorkEventDepartmentID = 4
OR T1. DepartmentID = 4) 
AND LeadTimeIndicator = 1
AND CompletedIndicator = 1
AND CompletedDate >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7) as Completed
ON Pending.PreviousBusinessDay = Completed."Completed Date"
AND Pending."Party Type Name" = Completed."Party Type Name"
AND Pending."Service Channel Code" = Completed."Service Channel Code"
AND Pending."Team Name" = Completed."Team Name"
AND Pending."Function Name"= Completed."Function Name"
AND Pending."Segment Name"= Completed."Segment Name"
AND Pending."Work Event Name" = Completed."Work Event Name"
SELECT LoadDate AS "Pending Date"
,T2.PreviousBusinessDay
,T1.PartyTypeName AS "Party Type Name"
,T1.ServiceChannelName AS "Service Channel Code"
,T1.TeamName AS "Team Name"
,T1.FunctionName AS "Function Name"
,T1.SegmentName AS "Segment Name"
,T1.WorkEventName AS "Work Event Name" 
,ActionableIndicator AS "Actionable Indicator"
,Sum(ItemCount) AS "Pending Count"
,Coalesce(T3.CompletedDate, PreviousBusinessDay) AS "Date" 
,Coalesce("Completed Count", 0) AS "Completed Count" 
FROM PROD_DMA_VW.PSC_MART_CURR_IVW T1
--- Inner Join to Date Dim to grab Previous Business Day
INNER JOIN PROD_DMA_VW.DATE_DIM_VW T2 ON T1.LoadDate = T2.ShortDate
--- Left Join to grab Completed Counts for each Pending grouping
LEFT JOIN (SELECT 
	CompletedDate
	,PartyTypeID
	,ServiceChannelName
	,TeamID
	,FunctionID
	,SegmentID
	,WorkEventID
	,Sum(ItemCount) AS "Completed Count"
	FROM PROD_DMA_VW.PSC_MART_CURR_IVW
	WHERE TransactionTypeID = 3 -- Completed Transaction Type ID
	AND CompletedDate >= Add_Months(Current_Date, -6)
	GROUP BY 1,2,3,4,5,6,7) T3 ON T2.PreviousBusinessDay = T3.CompletedDate
		AND T1.PartyTypeID = T3.PartyTypeID
		AND T1.ServiceChannelName = T3.ServiceChannelName
		AND T1.TeamID = T3.TeamID
		AND T1.FunctionID = T3.FunctionID
		AND T1.SegmentID = T3.SegmentID
		AND T1.WorkEventID = T3.WorkEventID
WHERE LeadTimeIndicator = 1 -- Applied to this KPI
AND TransactionTypeID = 2 -- Pending Transaction Type ID
AND LoadDate >= Add_Months(Current_Date, -6)
GROUP BY 1,2,3,4,5,6,7,8,9,11,12
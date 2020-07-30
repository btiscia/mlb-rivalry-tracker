SELECT T1.[PolicyNum] AS [Policy Number] -- Policy Number
,(SELECT NEXT_BD
	FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
    WHERE NBSubmitDate = [SHORT_DT]) AS [SE2 Report Date]

,(SELECT NEXT_BD
	FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
	WHERE CAST(SuitabilitySubmitDate AS DATE) = [SHORT_DT]) AS [Suitability Report Date]
,'Input' as [Event Type]
,CAST(SuitabilitySubmitDate as DATE) AS [Suitability Submit Date]
,CASE
	WHEN T1.SuitabilityCurrentStatus in ('Cancelled','Cancel/Reject') THEN T1.SuitabilityLastStatusDate
	WHEN T1.SuitabilityCurrentStatus is not null THEN T1.SuitabilityTransmitDate
	END AS [Suitability Throughput]
,NBSubmitDate AS [NB Submit Date]
,CASE
	WHEN T1.[NewBusinessStatus] = 'Rejected' THEN T1.RejectDate
	WHEN T1.[NewBusinessStatus] = 'Reported' THEN T1.IssueDate
	END AS [SE2 Throughput]
,NewBusinessStatus as [New Business Status]
,CASE
   WHEN T1.[PlanCode] LIKE ('%Capital Vantage%') THEN 'Capital Vantage'
   WHEN T1.[PlanCode] LIKE ('%Transitions Select%') THEN 'Transition Select'
   WHEN T1.[PlanCode] LIKE ('%RetireEase Choice%') THEN 'RetireEase Choice'
   WHEN T1.[PlanCode] LIKE ('%RetireEase%') THEN 'RetireEase'
   WHEN T1.[PlanCode] LIKE ('%Stable Voyage%') THEN 'Stable Voyage'
   WHEN T1.[PlanCode] LIKE ('%Odyssey Select%') THEN 'Odyssey Select'
   WHEN T1.[PlanCode] LIKE ('%Index Horizons%') THEN 'Index Horizons'
   ELSE 'Unknown'
END AS [Product]
,[ProductType] AS [Product Category]
,CASE 
   WHEN T1.[SubmitDate] IS NOT NULL AND T1.[NewBusinessStatus] IN ('Submitted, Pending', 'Pending Issue') THEN 'Pending New Business'
   WHEN T1.[SubmitDate] IS NOT NULL AND T1.[SuitabilityCurrentStatus] = 'Pending Approval' THEN 'Pending Suitability'
   ELSE NULL
END AS [Pending Status]
,CASE
   WHEN T1.[SubmitDate] IS NOT NULL AND T1.[NewBusinessStatus] = 'Submitted, Pending' THEN 'Received, Not Approved'
   WHEN T1.[SubmitDate] IS NOT NULL AND T1.[NewBusinessStatus] = 'Pending Issue' THEN 'In Good Order, Awaiting Funds'
   ELSE NULL
END AS [Pending New Business Contract Status]
,BingoStatus AS [Bingo Status]
,[Channel] AS [Distributor]
,CASE WHEN T1.[Channel] IN ('CAS','CAB') THEN 'MMFA' ELSE 'SDP' END AS [Channel]
,[System]
,[FirmName] AS [Firm Name]
,[AdvisorName] AS [Advisor]
FROM RptgAndAnalytics.StrdRptg.AnnuityNBFlatFile T1
WHERE 
SubmitDate < CAST(GETDATE() AS DATE)
AND (IssueDate < CAST(GETDATE() AS DATE)
OR IssueDate IS NULL)


---------------------------------------------

Union

----------------------------------------------

SELECT T1.[PolicyNum] AS [Policy Number]
,(SELECT NEXT_BD
	FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
	WHERE 
	CASE WHEN T1.[NewBusinessStatus] = 'Rejected' THEN T1.RejectDate
	     WHEN T1.[NewBusinessStatus] = 'Reported' THEN T1.IssueDate
	     END = [SHORT_DT]) AS [SE2 Report Date]
,(SELECT NEXT_BD
	FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
	WHERE 
	CASE WHEN T1.SuitabilityCurrentStatus in ('Cancelled','Cancel/Reject') THEN T1.SuitabilityLastStatusDate
	     WHEN T1.SuitabilityCurrentStatus is not null THEN T1.SuitabilityTransmitDate
	     END = [SHORT_DT]) AS [Suitability Report Date]
,'Throughput' AS [Event Type]
,CAST(SuitabilitySubmitDate AS DATE) AS [Suitability Submit Date]
,CASE
	WHEN T1.SuitabilityCurrentStatus in ('Cancelled','Cancel/Reject') THEN T1.SuitabilityLastStatusDate
	WHEN T1.SuitabilityCurrentStatus is not null THEN T1.SuitabilityTransmitDate
	END AS [Suitability Throughput]
,NBSubmitDate AS [NB Submit Date]
,CASE
	WHEN T1.[NewBusinessStatus] = 'Rejected' THEN T1.RejectDate
	WHEN T1.[NewBusinessStatus] = 'Reported' THEN T1.IssueDate
	END AS [SE2 Throughput]
,NewBusinessStatus as [New Business Status]
,CASE
   WHEN T1.[PlanCode] LIKE ('%Capital Vantage%') THEN 'Capital Vantage'
   WHEN T1.[PlanCode] LIKE ('%Transitions Select%') THEN 'Transition Select'
   WHEN T1.[PlanCode] LIKE ('%RetireEase Choice%') THEN 'RetireEase Choice'
   WHEN T1.[PlanCode] LIKE ('%RetireEase%') THEN 'RetireEase'
   WHEN T1.[PlanCode] LIKE ('%Stable Voyage%') THEN 'Stable Voyage'
   WHEN T1.[PlanCode] LIKE ('%Odyssey Select%') THEN 'Odyssey Select'
   WHEN T1.[PlanCode] LIKE ('%Index Horizons%') THEN 'Index Horizons'
   ELSE 'Unknown'
END AS [Product]
,[ProductType] AS [Product Category]
,CASE 
   WHEN T1.[SubmitDate] IS NOT NULL AND T1.[NewBusinessStatus] IN ('Submitted, Pending', 'Pending Issue') THEN 'Pending New Business'
   WHEN T1.[SubmitDate] IS NOT NULL AND T1.[SuitabilityCurrentStatus] = 'Pending Approval' THEN 'Pending Suitability'
   ELSE NULL
END AS [Pending Status]
,CASE
   WHEN T1.[SubmitDate] IS NOT NULL AND T1.[NewBusinessStatus] = 'Submitted, Pending' THEN 'Received, Not Approved'
   WHEN T1.[SubmitDate] IS NOT NULL AND T1.[NewBusinessStatus] = 'Pending Issue' THEN 'In Good Order, Awaiting Funds'
   ELSE NULL
END AS [Pending New Business Contract Status]
,BingoStatus AS [Bingo Status]
,[Channel] AS [Distributor]
,CASE WHEN T1.[Channel] IN ('CAS','CAB') THEN 'MMFA' ELSE 'SDP' END AS [Channel]
,[System]
,[FirmName] AS [Firm Name]
,[AdvisorName] AS [Advisor]
FROM RptgAndAnalytics.StrdRptg.AnnuityNBFlatFile T1
WHERE 
SubmitDate < CAST(GETDATE() AS DATE)
AND (IssueDate < CAST(GETDATE() AS DATE)
OR IssueDate IS NULL)
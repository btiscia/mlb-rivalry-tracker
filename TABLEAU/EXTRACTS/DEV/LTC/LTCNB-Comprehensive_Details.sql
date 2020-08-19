
SELECT 
 T1.[System]
,T1.[PolicyNum] as [Policy Number]
,T1.[CurrentInforceStatus] AS [Contract Status]
,T1.[StatusDescription] AS [Status Description]
,T1.[ProductType] AS [Product Category]
,T1.[PlanCode] AS [Product Type]
,T1.[Channel]
,T1.[RegionName] AS [Region]
,T1.[Firm] AS [Firm Number]
,T1.[AgencyName] AS [Firm Name]
,T1.[AdvisorName] AS [Advisor]
,T1.[ContractState] AS [Contract State]
,T1.[ResidenceState] AS [Residence State]
,T1.[PlacementStatus] AS [Placement Status]
,CAST(T1.[SubmitDate] AS DATE) AS [Submit Date]
,CAST(T1.[IssueDate] AS DATE) AS [Issue Date]
,CAST(T1.[ReportedDate] AS DATE) AS [Reported Date]
,T1.[NotTakenDate] AS [Not Taken Date]
,T1.[DeclineDate] AS [Decline Date]
,T1.[Incp_Wdrn_Date] AS [Incomplete Withdrawn Date]
,T1.[PlacementStatusDate] AS [Placement Status Date]
,[AnticipatedPremium] AS [Anticipated Premium]
,DateDiff(dd,T1.[SubmitDate],T1.[IssueDate]) AS [SubmitToIssueCycleTime]
,DateDiff(dd,T1.[IssueDate],T1.[ReportedDate]) AS [IssueToReportedCycleTime]
,DateDiff(dd,T1.[SubmitDate],T1.[ReportedDate]) AS [SubmitToReportedCycleTime]
,NULL as [PlanMetric]
,NULL as [Daily KPI Plan]
,NULL as [Daily MTD Plan]
,(SELECT BUSINESS_DAY 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[SubmitDate] = [SHORT_DT]) AS [Submit Business Day]

,(SELECT PREV_BD 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[SubmitDate] = [SHORT_DT]) AS [Submit Previous Business Day]

,(SELECT BUSINESS_DAY 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[IssueDate] = [SHORT_DT]) AS [Issue Business Day]

,(SELECT [PREV_BD] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[IssueDate] = [SHORT_DT]) AS [Issue Previous Business Day]

,(SELECT [PREV_BD] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE SHORT_DT = CAST(GETDATE() AS DATE)) AS [PreviousBusinessDayOfToday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[SubmitDate] = [SHORT_DT]) AS [Submit Date Is Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[IssueDate] = [SHORT_DT]) AS [Issue Date is Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[PlacementStatusDate] = [SHORT_DT]) AS [Placement Status Date is Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[ReportedDate] = [SHORT_DT]) AS [Reported Date is Holiday]

,CASE WHEN [StatusDescription] IN ('Submitted, Not Issued', 'Issued, Not Reported') THEN 1 ELSE 0 END AS [Pending Indicator]

FROM [RptgAndAnalytics].[StrdRptg].[LTCNBFlatFile] T1

WHERE 
SubmitDate < CAST(GETDATE() AS DATE)
AND (IssueDate < CAST(GETDATE() AS DATE)
OR IssueDate IS NULL)


UNION


SELECT 
'Plan' AS [System]
,NULL AS [Policy Number]
--,NULL AS [Contract]
,NULL AS [Contract Status]
,NULL AS [Status Description]
,'SignatureCare' AS [Product Category]
,[Product1] AS  [Product Type]
,CASE
	WHEN [SalesGroup] = 'MMCAS' THEN 'MMFA'
	WHEN [SalesGroup] = 'Total' THEN 'Total'
	ELSE 'SDP'
END AS [Channel]
,NULL AS [Region]
,NULL AS [Firm Number]
,NULL AS [Firm Name]
,NULL AS [Advisor]
,NULL AS [Contract State]
,NULL AS [Resident State]
,NULL AS [Placement Status]
,CASE
	WHEN [Volumetric1] LIKE '%Submitted%' THEN [Date of Year]
	ELSE NULL
END AS [Submit Date]
,CASE
	WHEN [Volumetric1] LIKE '%Issued%' OR Volumetric1 LIKE '%Reported%' THEN [Date of Year]
	ELSE NULL
END AS [Issue Date]
,CASE
	WHEN [Volumetric1] LIKE '%Issued%' OR Volumetric1 LIKE '%Reported%' THEN [Date of Year]
	ELSE NULL
END AS [Reported Date]
,NULL AS [Not Taken Date]
,NULL AS [Decline Date]
,NULL AS [Incomplete Withdrawn Date]
,NULL AS [Placement Status Date]
,NULL AS [Anticipated Premium]
,NULL AS [SubmitToIssueCycleTime]
,NULL AS [IssueToReportedCycleTime]
,NULL AS [SubmitToReportedCycleTime]
,[Volumetric1] AS [PlanMetric]
,[Daily KPI Plan]
,[Daily MTD Plan]
,(SELECT [BUSINESS_DAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [Date of Year] = [SHORT_DT]) AS [Submit Business Day]

,(SELECT [PREV_BD]
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [Date of Year] = [SHORT_DT]) AS [Submit Previous Business Day]

,(SELECT [BUSINESS_DAY]
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [Date of Year] = [SHORT_DT]) AS [Issue Business Day]

,(SELECT [PREV_BD] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [Date of Year] = [SHORT_DT]) AS [Issue Previous Business Day]

,(SELECT [PREV_BD] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE SHORT_DT = CAST(GETDATE() AS DATE)) AS [PreviousBusinessDayOfToday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [Date of Year] = [SHORT_DT]) AS [Submit Date Is Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [Date of Year] = [SHORT_DT]) AS [Issue Date is Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [Date of Year] = [SHORT_DT]) AS [Placement Status Date is Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [Date of Year] = [SHORT_DT]) AS [Reported Date is Holiday]

,NULL AS [Pending Indicator]

FROM [RptgAndAnalytics].[StrdRptg].[KPIPlans]
WHERE LOB = 'LTC'


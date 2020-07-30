SELECT

T1.[TransactionCycleDate]
,T1.[TotalDeposit] AS [FirstYearReportedPremiumDeposit]
,T2.[System]
,T2.[PolicyNum] as [Policy Number]
,T2.[HldgKey] AS [Contract]
,T2.[InforceStatus] AS [Contract Status]
,T2.[ProductType] AS [Product Category]
,T2.[PlanCode] AS [Plan Code]
,CASE
   WHEN T2.[PlanCode] LIKE ('%Capital Vantage%') THEN 'Capital Vantage'
   WHEN T2.[PlanCode] LIKE ('%Transitions Select%') THEN 'Transition Select'
   WHEN T2.[PlanCode] LIKE ('%RetireEase Choice%') THEN 'RetireEase Choice'
   WHEN T2.[PlanCode] LIKE ('%RetireEase%') THEN 'RetireEase'
   WHEN T2.[PlanCode] LIKE ('%Stable Voyage%') THEN 'Stable Voyage'
   WHEN T2.[PlanCode] LIKE ('%Odyssey Select%') THEN 'Odyssey Select'
   WHEN T2.[PlanCode] LIKE ('%Index Horizons%') THEN 'Index Horizons'
   ELSE 'Unknown'
END AS [Product]
,T2.[MarketType] AS [Market Type]
,T2.[Channel] AS [Distributor]
,CASE WHEN T2.[Channel] IN ('CAS','CAB') THEN 'MMFA' ELSE 'SDP' END AS [Channel]
,T2.[ChannelType] AS [Channel Type]
,T2.[RegionName] AS [Region]
,T2.[FirmName] AS [Firm Name]
,T2.[Firm]
,T2.[AdvisorName] AS [Advisor]
,T2.[ContractState] AS [Contract State]
,CASE
       WHEN T2.[NBDocType] = 'Annuity Application' THEN 'Annuity Application'
       WHEN T2.[NBDocType] = 'Incoming Transfer' THEN 'Incoming Transfer'
       WHEN T2.[NBDocType] = 'NB Purchase w App' THEN 'NB Purchase w App'
       WHEN T2.[NBDocType] = 'NB Reg 60' THEN 'NB Reg 60'
   ELSE 'N/A'
END AS [Doc Type]
,T2.[BingoStatus] AS [Bingo Status]
,CASE WHEN T2.[IssueDate] >= '2018-08-01' AND T2.[BingoStatus] = 'BINGO' THEN 1 ELSE 0 END AS [BINGO Indicator]
,CASE WHEN T2.[IssueDate] >= '2018-08-01' THEN 1 ELSE 0 END AS [Issue Count for BINGO Rate]
,T2.[BingoDate] AS [BINGO Date]
,T2.[CalDaysSinceSubmit]
,T2.[CalDaysNBRcvdToIssued]
,T2.[AppSignedDate] AS [App Signed Date]
,T2.[NBSubmitDate] AS [NB Submit Date]
,T2.[SubmitDate] AS [Submit Date]
,T2.[IssueDate] AS [Issue Date]
,T2.[RejectDate] AS [Reject Date]
,NULL as [PlanMetric]
,NULL as [Daily KPI Plan]
,NULL as [Daily MTD Plan]
,(SELECT BUSINESS_DAY 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T2.[SubmitDate] = [SHORT_DT]) AS [Submit Business Day]

,(SELECT PREV_BD 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T2.[SubmitDate] = [SHORT_DT]) AS [Submit Previous Business Day]

,(SELECT BUSINESS_DAY 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T2.[IssueDate] = [SHORT_DT]) AS [Issue Business Day]

,(SELECT [PREV_BD] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T2.[IssueDate] = [SHORT_DT]) AS [Issue Previous Business Day]

,(SELECT [PREV_BD] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [SHORT_DT] = CAST(GETDATE() AS DATE)) AS [PreviousBusinessDayOfToday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T2.[SubmitDate] = [SHORT_DT]) AS [Submit Date Is Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T2.[IssueDate] = [SHORT_DT]) AS [Issue Date is Holiday]

FROM [RptgAndAnalytics].[StrdRptg].[AnnuityReportedData] T1

LEFT JOIN [RptgAndAnalytics].[StrdRptg].[AnnuityNBFlatFile] T2 
          ON T1.ContractNum = T2.PolicyNum
          WHERE 
              T2.SubmitDate < CAST(GETDATE() AS DATE)
              AND (T2.IssueDate < CAST(GETDATE() AS DATE)
              OR T2.IssueDate IS NULL)


UNION


SELECT 

CASE
       WHEN [Volumetric1] LIKE '%Issued%' OR Volumetric1 LIKE '%Reported%' THEN [Date of Year]
       ELSE NULL
END AS [TransactionCycleDate]
,NULL AS [FirstYearReportedPremiumDeposit]
,'Plan' AS [System]
,NULL AS [Policy Number]
,NULL AS [Contract]
,NULL AS [Contract Status]
,CASE
       WHEN Product1 LIKE 'Variable Annuity%' THEN 'Variable Annuity'
       WHEN Product1 LIKE 'Income Annuity%' THEN 'Income Annuity'
       WHEN Product1 LIKE 'Fixed Annuity%' THEN 'Fixed Annuity'
       ELSE 'Fixed Indexed'
END as [Product Category]
,[Volumetric1] as [Plan Code]
,NULL AS [Product]
,NULL AS [Market Type]
,NULL AS [Distributor]
,CASE
       WHEN [Product1] LIKE '%MMFA%' OR [Product1] LIKE '%CAB%' THEN 'MMFA'
       WHEN [Product1] LIKE '%SDP%' THEN 'SDP'
       ELSE 'Total'
END AS [Channel]
,CASE
       WHEN [Product1] LIKE '%MMFA%' OR [Product1] LIKE '%CAB%' THEN 'Non-SDP'
       WHEN [Product1] LIKE '%SDP%' THEN 'SDP'
       ELSE 'Total'
END as [Channel Type]
,NULL AS [Region]
,NULL AS [Firm Name]
,NULL AS [Firm]
,NULL AS [Advisor]
,NULL AS [Contract State]
,NULL AS [Doc Type]
,NULL AS [Bingo Status]
,NULL AS [BINGO Indicator]
,NULL AS [Issue Count for BINGO Rate]
,NULL AS [BINGO Date]
,NULL AS [CalDaysSinceSubmit]
,NULL AS [CalDaysNBRcvdToIssued]
,NULL AS [App Signed Date]
,CASE
       WHEN [Volumetric1] LIKE '%Submitted%' THEN [Date of Year]
       ELSE NULL
END as [NB Submit Date]
,CASE
       WHEN [Volumetric1] LIKE '%Submitted%' THEN [Date of Year]
       ELSE NULL
END AS [Submit Date]
,CASE
       WHEN [Volumetric1] LIKE '%Issued%' OR Volumetric1 LIKE '%Reported%' THEN [Date of Year]
       ELSE NULL
END AS [Issue Date]


,NULL AS [Reject Date]
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

FROM [RptgAndAnalytics].[StrdRptg].[KPIPlans]
WHERE (LOB = 'Annuity' AND Volumetric1 = 'Reported Premium')
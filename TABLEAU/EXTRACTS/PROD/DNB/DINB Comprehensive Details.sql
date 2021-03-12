SELECT
'DI' AS [SYSTEM]
,T1.[Policy #] AS [Policy NUMBER]
,T1.[Premium]
,T1.[Contract State]
,T1.[Agency] AS [Firm]
,T1.[Soliciting Agt Name] AS [Advisor Name]
,T1.[Market] AS [Market TYPE]

--,CASE WHEN T1.[Market] IN ('SmBiz','Indiv') THEN 'Indiv and Small Biz' ELSE 'Worksite' END AS [Market Type Grouping]
,CASE WHEN T1.[Market] = 'Worksite' THEN T1.[Market] ELSE 'Indiv and Small Biz' END AS [Market TYPE GROUPING]

,CASE WHEN T1.[Market] = 'Worksite' AND T1.[UW TYPE] = 'Fully U/W' THEN 'Fully U/W' 
		  WHEN T1.[Market] = 'Worksite' AND T1.[UW TYPE] = 'GSI' THEN 'GSI' 
		  WHEN T1.[Graded] = 'Yes' THEN 'w/ Graded Premium' 
 END AS [Market Breakdown]

,T1.[UW TYPE]
,T1.[Product]
,T1.[Product TYPE]
,T1.[Graded]
,T1.[Cur Status] AS [CURRENT Status]
,T1.[Cur Status DATE] AS [CURRENT Status DATE]
,T1.[App SIGN DATE]
,T1.[Submit DATE]
,T1.[Issue DATE]
,T1.[Reported DATE]
,T1.[Bingo Ind]
,T1.[BINGO Review DATE]
,T1.[Prepaid] AS [Prepaid Ind]
,T1.[EZApp] AS [EZApp Ind]
,T1.[ESign] AS [ESign Ind]
,T1.[EZIssue] AS [EZ Issue Ind]

,CASE 
   WHEN T1.[App SIGN DATE] IS NOT NULL AND T1.[App SIGN DATE] <= T1.[FIRST FA DATE]
   AND T1.[App SIGN DATE] <= T1.[Apvd DATE]
   AND T1.[Issue DATE] IS NOT NULL
   THEN DateDiff(dd,T1.[App SIGN DATE],T1.[Issue DATE]) 
 END AS [AppSignedToIssueCycleTime]

 --,DateDiff(dd, T1.[App Sign Date], T1.[Issue Date]) AS [AppSignedToIssueCycleTime]

--,DateDiff(dd, T1.[App Sign Date],T1.[Reported Date]) AS [AppSignedToReportedCycleTime]

,CASE
   WHEN T1.[UW TYPE] = 'GSI' THEN DateDiff(dd, T1.[App SIGN DATE], T1.[Issue DATE]) 
 END AS [GSI_AppSignedToIssueCycleTime]

,CASE
   WHEN T1.[UW TYPE] = 'Fully U/W' THEN DateDiff(dd, T1.[App SIGN DATE], T1.[Issue DATE]) 
 END AS [Fully_UW_AppSignedIssueCycleTime]
 
,NULL AS [PlanMetric]
,NULL AS [Daily KPI Plan]
,NULL AS [Daily MTD Plan]
,NULL AS [Daily YTD Plan]
,(SELECT BUSINESS_DAY 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Submit DATE] = [SHORT_DT]) AS [Submit Business DAY]

,(SELECT PREV_BD 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Submit DATE] = [SHORT_DT]) AS [Submit Previous Business DAY]

,(SELECT BUSINESS_DAY 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Issue DATE] = [SHORT_DT]) AS [Issue Business DAY]

,(SELECT [PREV_BD] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Issue DATE] = [SHORT_DT]) AS [Issue Previous Business DAY]

,(SELECT [PREV_BD] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE SHORT_DT = CAST(GETDATE() AS DATE)) AS [PreviousBusinessDayOfToday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Submit DATE] = [SHORT_DT]) AS [Submit DATE IS Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Issue DATE] = [SHORT_DT]) AS [Issue DATE IS Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Cur Status DATE] = [SHORT_DT]) AS [CURRENT Status DATE IS Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Reported DATE] = [SHORT_DT]) AS [Reported DATE IS Holiday]

,[CASE Status]
 ,CASE  
      WHEN [Cur Status] LIKE 'APPR%' OR [Cur Status] LIKE 'RESUBMIT%' THEN 'Placed'
      WHEN [Cur Status] LIKE 'DECL%' THEN 'Declined'
      WHEN [Cur Status] LIKE 'NOT TAKEN%'THEN 'Not Taken'
      WHEN [Cur Status] LIKE 'POSTP%' THEN 'Postpone'
 END [Placement Status]
 
 ,CASE 
      WHEN T1.[CASE Status] LIKE 'SUBMIT%' AND T1.[Issue DATE] IS NULL THEN 'Submitted, Not Approved'
      WHEN T1.[CASE Status] LIKE 'Issue%' OR T1.[CASE Status] LIKE 'Approve%' AND T1.[Issue DATE] IS NOT NULL THEN 'Issued, Not Reported'
		WHEN T1.[CASE Status] LIKE 'Issue%' OR T1.[CASE Status] LIKE 'Approve%' THEN 'Approved, Not Issued'
 END AS [Pending Status]

 ,CASE 
	WHEN ([CASE Status] LIKE 'Issue%' OR [CASE Status] LIKE 'Approve%') AND [Issue DATE] IS NOT NULL THEN [Issue DATE]
    WHEN ([CASE Status] LIKE 'Issue%' OR [CASE Status] LIKE 'Approve%') AND [Issue DATE] IS NULL THEN [Apvd DATE]
    WHEN [CASE Status] LIKE 'Issue%' OR [CASE Status] LIKE 'Approve%' THEN [Apvd DATE]
    WHEN ([Submit DATE] <> '1900-01-01' AND [Submit DATE] IS NOT NULL) THEN [Submit DATE]
    ELSE [App Capture DATE]
 END AS AgingStartDate


,T1.[App Capture DATE]
,T1.[FIRST FA]
,T1.[FIRST FA DATE]


FROM [LifeNewBizDataStaging].[dbo].[DINewBusinesFlatFile] T1
WHERE (MMIPOInd <> 'Yes' 
	OR 
	MMIPOInd IS NULL)
	AND Market IS NOT NULL


UNION

SELECT [SYSTEM]
,[Policy NUMBER]
,[Premium]
,[Contract State]
,[Firm]
,[Advisor Name]
,[Market TYPE]
,[Market TYPE GROUPING]
,[Market Breakdown]
,[UW TYPE]
,[Product]
,[Product TYPE]
,[Graded]
,[CURRENT Status]
,[CURRENT Status DATE]
,[App SIGN DATE]
,[Submit DATE]
,[Issue DATE]
,[Reported DATE]
,[Bingo Ind]
,[BINGO Review DATE]
,[Prepaid Ind]
,[EZApp Ind]
,[ESign Ind]
,[EZ Issue Ind]
,[AppSignedToIssueCycleTime]
,[GSI_AppSignedToIssueCycleTime]
,[Fully_UW_AppSignedToIssueCycleTime]
,[PlanMetric]
,SUM([Daily KPI Plan])
,SUM([Daily MTD Plan])
,SUM([Daily YTD Plan])
,[Submit Business DAY]
,[Submit Previous Business DAY]
,[Issue Business DAY]
,[Issue Previous Business DAY]
,[PreviousBusinessDayOfToday]
,[Submit DATE IS Holiday]
,[Issue DATE IS Holiday]
,[CURRENT Status DATE IS Holiday]
,[Reported DATE IS Holiday]
,[CASE Status]
,[Placement Status]
,[Pending Status]
,AgingStartDate
,[App Capture DATE]
,[FIRST FA]
,[FIRST FA DATE]

FROM

(SELECT
 
'Plan' AS [SYSTEM]
,NULL AS [Policy NUMBER]
,NULL AS [Premium]
,NULL AS [Contract state]
,NULL AS [Firm]
,NULL AS [Advisor Name]
,[Product1] AS [Market TYPE]
--,CASE WHEN [Product1] IN ('SmBiz','Indiv') THEN 'Indiv and Small Biz'ELSE 'Worksite' END AS [Market Type Grouping]
,CASE WHEN [Product1] = 'Worksite' THEN [Product1] ELSE 'Indiv and Small Biz' END AS [Market TYPE GROUPING]
,NULL AS [Market Breakdown]
,NULL AS [UW TYPE]
,NULL AS [Product]
,NULL AS [Product TYPE]
,NULL AS [Graded]
,NULL AS [CURRENT Status]
,NULL AS [CURRENT Status DATE]
,NULL AS [App SIGN DATE]
,CASE
	WHEN [Volumetric1] LIKE '%Submitted%' THEN [DATE OF YEAR]
	ELSE NULL
END AS [Submit DATE]
,CASE
	WHEN [Volumetric1] LIKE '%Issued%' OR Volumetric1 LIKE '%Reported%' THEN [DATE OF YEAR]
	ELSE NULL
END AS [Issue DATE]
,CASE
	WHEN [Volumetric1] LIKE '%Issued%' OR Volumetric1 LIKE '%Reported%' THEN [DATE OF YEAR]
	ELSE NULL
END AS [Reported DATE]
,NULL AS [Bingo Ind]
,NULL AS [BINGO Review DATE]
,NULL AS [Prepaid Ind]
,NULL AS [EZApp Ind]
,NULL AS [ESign Ind]
,NULL AS [EZ Issue Ind]

,NULL AS [AppSignedToIssueCycleTime]
,NULL AS [GSI_AppSignedToIssueCycleTime]
,NULL AS [Fully_UW_AppSignedToIssueCycleTime]

,[Volumetric1] AS [PlanMetric]
,[Daily KPI Plan]
,[Daily MTD Plan]
,[Daily YTD Plan]
,(SELECT [BUSINESS_DAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [DATE OF YEAR] = [SHORT_DT]) AS [Submit Business DAY]

,(SELECT [PREV_BD]
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [DATE OF YEAR] = [SHORT_DT]) AS [Submit Previous Business DAY]

,(SELECT [BUSINESS_DAY]
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [DATE OF YEAR] = [SHORT_DT]) AS [Issue Business DAY]

,(SELECT [PREV_BD] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [DATE OF YEAR] = [SHORT_DT]) AS [Issue Previous Business DAY]

,(SELECT [PREV_BD] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE SHORT_DT = CAST(GETDATE() AS DATE)) AS [PreviousBusinessDayOfToday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [DATE OF YEAR] = [SHORT_DT]) AS [Submit DATE IS Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [DATE OF YEAR] = [SHORT_DT]) AS [Issue DATE IS Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [DATE OF YEAR] = [SHORT_DT]) AS [CURRENT Status DATE IS Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [DATE OF YEAR] = [SHORT_DT]) AS [Reported DATE IS Holiday]

,NULL AS [CASE Status]
,NULL AS [Placement Status]
,NULL AS [Pending Status]
,NULL AS AgingStartDate
,NULL AS [App Capture DATE]
,NULL AS [FIRST FA]
,NULL AS [FIRST FA DATE]

FROM [RptgAndAnalytics].[StrdRptg].[KPIPlans]
WHERE LOB = 'DI'
AND Product1 IN ('SmBiz','Indiv','Worksite')
AND [DATE OF YEAR] > '2019-12-31') AS BasePlans
GROUP BY 
[SYSTEM]
,[Policy NUMBER]
,[Premium]
,[Contract State]
,[Firm]
,[Advisor Name]
,[Market TYPE]
,[Market TYPE GROUPING]
,[Market Breakdown]
,[UW TYPE]
,[Product]
,[Product TYPE]
,[Graded]
,[CURRENT Status]
,[CURRENT Status DATE]
,[App SIGN DATE]
,[Submit DATE]
,[Issue DATE]
,[Reported DATE]
,[Bingo Ind]
,[BINGO Review DATE]
,[Prepaid Ind]
,[EZApp Ind]
,[ESign Ind]
,[EZ Issue Ind]
,[AppSignedToIssueCycleTime]
,[GSI_AppSignedToIssueCycleTime]
,[Fully_UW_AppSignedToIssueCycleTime]
,[PlanMetric]
,[Submit Business DAY]
,[Submit Previous Business DAY]
,[Issue Business DAY]
,[Issue Previous Business DAY]
,[PreviousBusinessDayOfToday]
,[Submit DATE IS Holiday]
,[Issue DATE IS Holiday]
,[CURRENT Status DATE IS Holiday]
,[Reported DATE IS Holiday]
,[CASE Status]
,[Placement Status]
,[Pending Status]
,[AgingStartDate]
,[App Capture DATE]
,[FIRST FA]
,[FIRST FA DATE]
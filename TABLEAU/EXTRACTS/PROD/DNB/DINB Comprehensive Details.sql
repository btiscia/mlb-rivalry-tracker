/*
Name: DINB Comprehensive Details
Author: Bill Trombley
Updated By: Bill Trombley
Last Updated: 2/5/2024
Comments: Modify Channel code to use new MMSD indicator
*/

SELECT
'DI' AS [System]
,T1.[Policy #] AS [Policy Number]
,T1.[Premium]
,T1.[Contract State]
,T1.[Agency] AS [Firm]
,CASE WHEN T1.[MMSD] = 1 THEN 'MMSD' ELSE 'MMFA'END AS [Channel]
,T1.[Soliciting Agt Name] AS [Advisor Name]
,T1.[Market] AS [Market Type]
,CASE WHEN T1.[Market] = 'Worksite' THEN T1.[Market] ELSE 'Indiv and Small Biz' END AS [Market Type Grouping]

,CASE WHEN T1.[Market] = 'Worksite' AND T1.[UW Type] = 'Fully U/W' THEN 'Fully U/W' 
		  WHEN T1.[Market] = 'Worksite' AND T1.[UW Type] = 'GSI' THEN 'GSI' 
		  WHEN T1.[Graded] = 'Yes' THEN 'w/ Graded Premium' 
 END AS [Market Breakdown]

,T1.[UW Type]
,T1.[Product]
,T1.[Product Type]
,T1.[Graded]
,T1.[Cur Status] AS [Current Status]
,T1.[Cur Status Date] AS [Current Status Date]
,T1.[App Sign Date]
,T1.[Submit Date]
,T1.[Issue Date]
,T1.[Reported Date]
,T1.[Bingo Ind]
,T1.[BINGO Review Date]
,T1.[Prepaid] AS [Prepaid Ind]
,T1.[EZApp] AS [EZApp Ind]
,T1.[ESign] AS [ESign Ind]
,T1.[EZIssue] AS [EZ Issue Ind]

,CASE 
   WHEN T1.[App Sign Date] IS NOT NULL AND T1.[App Sign Date] <= T1.[First FA Date]
   AND T1.[App Sign Date] <= T1.[Apvd Date]
   AND T1.[Issue Date] IS NOT NULL
   THEN DateDiff(dd,T1.[App Sign Date],T1.[Issue Date]) 
 END AS [AppSignedToIssueCycleTime]

,CASE
   WHEN T1.[UW Type] = 'GSI' THEN DateDiff(dd, T1.[App Sign Date], T1.[Issue Date]) 
 END AS [GSI_AppSignedToIssueCycleTime]

,CASE
   WHEN T1.[UW Type] = 'Fully U/W' THEN DateDiff(dd, T1.[App Sign Date], T1.[Issue Date]) 
 END AS [Fully_UW_AppSignedIssueCycleTime]
 
,NULL as [PlanMetric]
,NULL as [Daily KPI Plan]
,NULL as [Daily MTD Plan]
,NULL as [Daily YTD Plan]
,(SELECT BUSINESS_DAY 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Submit Date] = [SHORT_DT]) AS [Submit Business Day]

,(SELECT PREV_BD 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Submit Date] = [SHORT_DT]) AS [Submit Previous Business Day]

,(SELECT BUSINESS_DAY 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Issue Date] = [SHORT_DT]) AS [Issue Business Day]

,(SELECT [PREV_BD] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Issue Date] = [SHORT_DT]) AS [Issue Previous Business Day]

,(SELECT [PREV_BD] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE SHORT_DT = CAST(GETDATE() AS DATE)) AS [PreviousBusinessDayOfToday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Submit Date] = [SHORT_DT]) AS [Submit Date Is Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Issue Date] = [SHORT_DT]) AS [Issue Date is Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Cur Status Date] = [SHORT_DT]) AS [Current Status Date is Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE T1.[Reported Date] = [SHORT_DT]) AS [Reported Date is Holiday]

,[Case Status]
 ,CASE  
      WHEN [Cur Status] LIKE 'APPR%' OR [Cur Status] LIKE 'RESUBMIT%' THEN 'Placed'
      WHEN [Cur Status] LIKE 'DECL%' THEN 'Declined'
      WHEN [Cur Status] LIKE 'NOT TAKEN%'THEN 'Not Taken'
      WHEN [Cur Status] LIKE 'POSTP%' THEN 'Postpone'
 END [Placement Status]
 
 ,CASE 
      WHEN T1.[Case Status] LIKE 'SUBMIT%' AND T1.[Issue Date] IS NULL THEN 'Submitted, Not Approved'
      WHEN T1.[Case Status] LIKE 'Issue%' OR T1.[Case Status] LIKE 'Approve%' AND T1.[Issue Date] IS NOT NULL THEN 'Issued, Not Reported'
		WHEN T1.[Case Status] LIKE 'Issue%' OR T1.[Case Status] LIKE 'Approve%' THEN 'Approved, Not Issued'
 END AS [Pending Status]

 ,CASE 
	WHEN ([Case Status] LIKE 'Issue%' OR [Case Status] LIKE 'Approve%') AND [Issue Date] IS NOT NULL THEN [Issue Date]
    WHEN ([Case Status] LIKE 'Issue%' OR [Case Status] LIKE 'Approve%') AND [Issue Date] IS NULL THEN [Apvd Date]
    WHEN [Case Status] LIKE 'Issue%' OR [Case Status] LIKE 'Approve%' THEN [Apvd Date]
    WHEN ([Submit Date] <> '1900-01-01' and [Submit Date] IS NOT NULL) THEN [Submit Date]
    ELSE [App Capture Date]
 END AS AgingStartDate


,T1.[App Capture Date]
,T1.[First FA]
,T1.[First FA Date]



FROM [LifeNewBizDataStaging].[dbo].[DINewBusinesReportingFile] T1

Left Join [RptgAndAnalytics].[Reference].[Agencies] T2
ON T1.[Agency] = T2.[OriginalAgencyCode]

WHERE (MMIPOInd <> 'Yes' 
	OR 
	MMIPOInd IS NULL)
	AND Market IS NOT NULL
	
UNION

SELECT [System]
,[Policy Number]
,[Premium]
,[Contract State]
,[Firm]
,[Channel]
,[Advisor Name]
,[Market Type]
,[Market Type Grouping]
,[Market Breakdown]
,[UW Type]
,[Product]
,[Product Type]
,[Graded]
,[Current Status]
,[Current Status Date]
,[App Sign Date]
,[Submit Date]
,[Issue Date]
,[Reported Date]
,[Bingo Ind]
,[BINGO Review Date]
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
,[Submit Business Day]
,[Submit Previous Business Day]
,[Issue Business Day]
,[Issue Previous Business Day]
,[PreviousBusinessDayOfToday]
,[Submit Date Is Holiday]
,[Issue Date is Holiday]
,[Current Status Date is Holiday]
,[Reported Date is Holiday]
,[Case Status]
,[Placement Status]
,[Pending Status]
,AgingStartDate
,[App Capture Date]
,[First FA]
,[First FA Date]

FROM

(SELECT
 
'Plan' AS [System]
,NULL AS [Policy Number]
,NULL AS [Premium]
,NULL AS [Contract state]
,NULL AS [Firm]
,[SalesGroup] AS [Channel]
,NULL AS [Advisor Name]
,[Product1] AS [Market Type]
,CASE WHEN [Product1] = 'Worksite' THEN [Product1] ELSE 'Indiv and Small Biz' END AS [Market Type Grouping]
,NULL AS [Market Breakdown]
,Null AS [UW Type]
,Null as [Product]
,Null as [Product Type]
,Null as [Graded]
,Null as [Current Status]
,Null as [Current Status Date]
,Null as [App Sign Date]
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
,Null as [Bingo Ind]
,Null as [BINGO Review Date]
,Null as [Prepaid Ind]
,Null as [EZApp Ind]
,Null as [ESign Ind]
,Null as [EZ Issue Ind]

,Null as [AppSignedToIssueCycleTime]
,Null as [GSI_AppSignedToIssueCycleTime]
,Null as [Fully_UW_AppSignedToIssueCycleTime]

,[Volumetric1] AS [PlanMetric]
,[Daily KPI Plan]
,[Daily MTD Plan]
,[Daily YTD Plan]
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
   WHERE [Date of Year] = [SHORT_DT]) AS [Current Status Date is Holiday]

,(SELECT [IS_HOLIDAY] 
   FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
   WHERE [Date of Year] = [SHORT_DT]) AS [Reported Date is Holiday]

,NULL AS [Case Status]
,NULL AS [Placement Status]
,NULL AS [Pending Status]
,NULL AS AgingStartDate
,NULL AS [App Capture Date]
,NULL AS [First FA]
,NULL AS [First FA Date]

FROM [RptgAndAnalytics].[StrdRptg].[KPIPlans]
WHERE LOB = 'DI'
AND Product1 IN ('SmBiz','Indiv','Worksite')
and [Date of Year] > '2019-12-31') as BasePlans
group by 
[System]
,[Policy Number]
,[Premium]
,[Contract State]
,[Firm]
,[Channel]
,[Advisor Name]
,[Market Type]
,[Market Type Grouping]
,[Market Breakdown]
,[UW Type]
,[Product]
,[Product Type]
,[Graded]
,[Current Status]
,[Current Status Date]
,[App Sign Date]
,[Submit Date]
,[Issue Date]
,[Reported Date]
,[Bingo Ind]
,[BINGO Review Date]
,[Prepaid Ind]
,[EZApp Ind]
,[ESign Ind]
,[EZ Issue Ind]
,[AppSignedToIssueCycleTime]
,[GSI_AppSignedToIssueCycleTime]
,[Fully_UW_AppSignedToIssueCycleTime]
,[PlanMetric]
,[Submit Business Day]
,[Submit Previous Business Day]
,[Issue Business Day]
,[Issue Previous Business Day]
,[PreviousBusinessDayOfToday]
,[Submit Date Is Holiday]
,[Issue Date is Holiday]
,[Current Status Date is Holiday]
,[Reported Date is Holiday]
,[Case Status]
,[Placement Status]
,[Pending Status]
,[AgingStartDate]
,[App Capture Date]
,[First FA]
,[First FA Date]
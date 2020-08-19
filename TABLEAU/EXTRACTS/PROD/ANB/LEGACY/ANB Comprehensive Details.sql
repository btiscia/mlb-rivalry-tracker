SELECT [System]
,T1.[PolicyNum] as [Policy Number]
,T1.[HldgKey] AS [Contract]
,T1.[InforceStatus] AS [Contract Status]
,T1.[ProductType] AS [Product Category]
,T1.[PlanCode] AS [Plan Code]
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
,T1.[MarketType] AS [Market Type]
,T1.[Channel] AS [Distributor]
,CASE WHEN T1.[Channel] IN ('CAS','CAB') THEN 'MMFA' ELSE 'SDP' END AS [Channel]
,T1.[ChannelType] AS [Channel Type]
,T1.[RegionName] AS [Region]
,T1.[FirmName] AS [Firm Name]
,T1.[Firm]
,T1.[AdvisorName] AS [Advisor]
,T1.[ContractState] AS [Contract State]
,T1.[AppSignedDate] AS [App Signed Date]
,T1.[NBSubmitDate] AS [NB Submit Date]
,T1.[SubmitDate] AS [Submit Date]
,T1.[IssueDate] AS [Issue Date]
,T1.[RejectDate] AS [Reject Date]
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
,T1.[NBDocType] AS [New Business Doc Type]
,CASE
       WHEN T1.[NBDocType] = 'Annuity Application' THEN 'Annuity Application'
       WHEN T1.[NBDocType] = 'Incoming Transfer' THEN 'Incoming Transfer'
       WHEN T1.[NBDocType] = 'NB Purchase w App' THEN 'NB Purchase w App'
       WHEN T1.[NBDocType] = 'NB Reg 60' THEN 'NB Reg 60'
   ELSE 'N/A'
END AS [Doc Type]
,T1.[ReplacementIndicator] AS [Replacement Indicator]
,T1.[AutoApprovedIND] AS [SuitabilityAutoApproveIndicator]
,T1.[ReplacementType] AS [Replacement Type]
,T1.[AnticipatedPremium] AS [Anticipated Premium]
--,T1.[DepositAmount] AS [Deposit Amount]
--,T5.[TotalFirstYearReportPrem]
,T1.[NewBusinessStatus] AS [New Business Status]
,T1.[BingoStatus] AS [Bingo Status]
,CASE WHEN IssueDate >= '2018-08-01' AND BingoStatus = 'BINGO' THEN 1 ELSE 0 END AS [BINGO Indicator]
,CASE WHEN T1.[IssueDate] >= '2018-08-01' THEN 1 ELSE 0 END AS [Issue Count for BINGO Rate]
,T1.[BingoDate] AS [BINGO Date]
,T1.[CalDaysSinceSubmit]
,T1.[CalDaysNBRcvdToIssued]
,CAST(T1.[SuitabilitySubmitDate] AS DATE) AS [Suitability Submit Date]
,CASE
       WHEN T1.SuitabilityCurrentStatus in ('Cancelled','Cancel/Reject') THEN T1.SuitabilityLastStatusDate
       WHEN T1.SuitabilityCurrentStatus is not null THEN T1.SuitabilityTransmitDate
       END AS [Suitability Throughput]
,CASE
       WHEN T1.[NewBusinessStatus] = 'Rejected' THEN T1.RejectDate
       WHEN T1.[NewBusinessStatus] = 'Reported' THEN T1.IssueDate
       END AS [SE2 Throughput]
,CASE 
   WHEN T1.[SubmitDate] IS NOT NULL
      THEN (SELECT COUNT(*) FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM] WHERE
          [IS_HOLIDAY] = 0 AND
          [IS_WEEKDAY] = 1 AND
          CAST([SHORT_DT] AS DATE) >=T1.[SubmitDate]
          AND CAST([SHORT_DT] AS DATE)<CAST(GETDATE() AS DATE))
END AS [BussinessDaysSinceSubmit]
,T1.[CalDaysSubmitToIssue] AS [Submit to Issue Cycle Time]
,CASE 
   WHEN T1.[IssueDate] IS NOT NULL
      THEN (SELECT COUNT(*) FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM] WHERE
          [IS_HOLIDAY] = 0 AND
          [IS_WEEKDAY] = 1 AND
          CAST([SHORT_DT] AS DATE) >=T1.[SubmitDate]
          AND CAST([SHORT_DT] AS DATE) >=T1.[SubmitDate] AND CAST([SHORT_DT] AS DATE)<T1.[IssueDate])
END AS [BussinessDaysSubmittoIssueCycleTime]
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

,(SELECT [NEXT_BD]
       FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
    WHERE [NBSubmitDate] = [SHORT_DT]) AS  [NB Submit Report Day]

,(select [NEXT_BD]
       from [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
       Where CAST([SuitabilitySubmitDate] AS DATE) = [SHORT_DT]) AS [Suitability Submit Report Day]

,(SELECT [NEXT_BD]
       FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
       WHERE 
               CASE WHEN T1.[NewBusinessStatus] = 'Rejected' THEN T1.RejectDate
            WHEN T1.[NewBusinessStatus] = 'Reported' THEN T1.IssueDate
            END = [SHORT_DT]) AS [SE2 Throughput Report Day]

,(SELECT [NEXT_BD]
       FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
       WHERE 
              CASE WHEN T1.SuitabilityCurrentStatus in ('Cancelled','Cancel/Reject') THEN T1.SuitabilityLastStatusDate
           WHEN T1.SuitabilityCurrentStatus is not null THEN T1.SuitabilityTransmitDate
           END = [SHORT_DT]) AS [Suitability Throughput Report Day]

,CASE WHEN T2.ORDER_ID IS NOT NULL THEN T2.NIGO_IND 
       ELSE CASE WHEN T3.ORDER_ID IS NOT NULL THEN T3.NIGO_IND END
END AS [IR NIGO Indicator]

,CASE WHEN T2.ORDER_ID IS NOT NULL THEN CAST(T2.CREATED_DT AS DATE)
       ELSE CASE WHEN T3.ORDER_ID IS NOT NULL THEN CAST(T3.CREATED_DT AS DATE) END
END AS [IR Review Date]
,[CalDaysAppSignToSuitSubmit]
,[CalDaysSuitSubmitToSuitApvd]
,[CalDaysSuitApvdToSuitTransmit]
,[CalDaysSuitSubmitToSuitTransmit]
,[CalDaysSignToNBSubmit]  
,[CalDaysSuitCmpltToNBRcvd]
,[CalDaysNBSubmitToBINGO]
,[CalDaysBINGOToPAW]
,[CalDaysBINGOToTOA]
,T1.[CalDaysSignToIssue]
,T1.[CalDaysSuitSubmitToIssue]
,[CalDaysNBSubmitToPAW]
,[CalDaysTOAToIssue]
,[SLACycleTime] as [SLA]
,[SLA_Goal] as [SLA_Goal]
,Case 
	When [SLACycleTime] is null and [SLA_Goal] is null Then NULL
	when [SLACycleTime] <= [SLA_Goal] then 1
	else 0
	end [SLA_Ident]

FROM RptgAndAnalytics.StrdRptg.[AnnuityNBFlatFile] T1

LEFT JOIN (SELECT DISTINCT [ORDER_ID], MAX([CREATED_DT]) AS [CREATED_DT], MAX(CASE WHEN [FIELD_FACE_IND] = 1 AND [RESPONSE_REVISED_VAL] = 0 THEN 1 ELSE 0 END) AS [NIGO_IND]
                     FROM RptgAndAnalytics.StrdRptg.ANBIRNIGO_VW
                     WHERE [Q_ID] >= 0 AND [ORDER_ID] LIKE '%[^0-9]%'
                     GROUP BY [ORDER_ID]) T2 ON T1.[iPipelineOrderNumber] = T2.[ORDER_ID]

LEFT JOIN (SELECT DISTINCT [ORDER_ID], MAX([CREATED_DT]) AS [CREATED_DT], MAX(CASE WHEN [FIELD_FACE_IND] = 1 AND [RESPONSE_REVISED_VAL] = 0 THEN 1 ELSE 0 END) AS [NIGO_IND]
                     FROM RptgAndAnalytics.StrdRptg.ANBIRNIGO_VW
                     WHERE [Q_ID] >= 0 AND [ORDER_ID] NOT LIKE '%[^0-9]%'
                     GROUP BY [ORDER_ID]) T3 ON T1.[PolicyNum] = T3.[ORDER_ID]

LEFT JOIN (SELECT CAST(GOAL_VAL AS INT) AS SLA_Goal, TRANS_TYPE
                    FROM [RptgAndAnalytics].[StrdRptg].[DMA_GOAL_DIM_TEST] WHERE DEPARTMENT_ID = 47) T4 ON T1.NBDocTypeID = T4.TRANS_TYPE

---LEFT JOIN (SELECT ContractNum, SUM(TotalDeposit) AS [TotalFirstYearReportPrem] ---Replaced with Teradata source on 4-1-2020
                   --  FROM [RptgAndAnalytics].[StrdRptg].[AnnuityReportedData]
                   --  GROUP BY ContractNum
                   --  ) T5 ON T1.PolicyNum = T5.ContractNum

WHERE 
SubmitDate < CAST(GETDATE() AS DATE)
AND (IssueDate < CAST(GETDATE() AS DATE)
OR IssueDate IS NULL)


UNION

SELECT 'Plan' AS [System]
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
,NULL AS [Pending Status]
,NULL AS [Pending New Business Contract Status]
,NULL AS [New Business Doc Type]
,NULL AS [Doc Type]
,NULL AS [Replacement Indicator]
,NULL AS [SuitabilityAutoApproveInd]
,NULL AS [Replacement Type]
,NULL AS [Anticipated Premium]
--,NULL AS [Deposit Amount]
--,Null as [TotalFirstYearReportPrem] 
,NULL AS [New Business Status]
,NULL AS [Bingo Status]
,NULL AS [BINGO Indicator]
,NULL AS [Issue Count for BINGO Rate]
,NULL AS [BINGO Date]
,NULL AS [CalDaysSinceSubmit]
,NULL AS [CalDaysNBRcvdToIssued]
,NULL AS [BussinessDaysSinceSubmit]
,NULL AS [Submit to Issue Cycle Time]
,NULL AS [BussinessDaysSubmittoIssueCycleTime]
,Null AS [Suitability Submit Date]
,Null AS [Suitability Throughput]
,Null AS [SE2 Throughput]
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

,(SELECT [NEXT_BD]
  FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
  WHERE [Date of Year] = [SHORT_DT]) AS [NB Submit Report Day]

,(SELECT [NEXT_BD]
  FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
  WHERE [Date of Year] = [SHORT_DT]) AS [Suitability Submit Report Day]

,(SELECT [NEXT_BD]
  FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
  WHERE [Date of Year] = [SHORT_DT]) AS [SE2 Throughput Report Day]

,(SELECT [NEXT_BD]
  FROM [RptgAndAnalytics].[StrdRptg].[DMA_DATE_DIM]
  WHERE [Date of Year] = [SHORT_DT]) AS [Suitability Throughput Report Day]
,NULL AS [IR Review Date]
,NULL AS [IR NIGO Indicator]
,Null AS[CalDaysAppSignToSuitSubmit]
,Null AS [CalDaysSuitSubmitToSuitApvd]
,Null AS [CalDaysSuitApvdToSuitTransmit]
,Null AS [CalDaysSuitSubmitToSuitTransmit]
,Null AS [CalDaysSignToNBSubmit]
,Null AS [CalDaysSuitCmpltToNBRcvd]
,Null AS [CalDaysNBSubmitToBINGO]
,Null AS [CalDaysBINGOToPAW]
,Null AS [CalDaysBINGOToTOA]

,Null AS [CalDaysSignToIssue]
,NULL AS [CalDaysSuitSubmitToIssue]
,Null AS [CalDAysNBSubmitToPAW]
,Null AS [CalDaysTOAToIssue]
,Null as [SLA]
,Null as [SLA_Goal]
,Null as [SLA_Ident]
FROM [RptgAndAnalytics].[StrdRptg].[KPIPlans]
WHERE LOB = 'Annuity'
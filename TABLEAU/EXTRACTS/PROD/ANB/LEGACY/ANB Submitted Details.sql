SELECT 
[PolicyNum] as "Policy Number"
,[FirmName] as "Firm Name"
,[Channel] AS [Distributor]
,CASE WHEN [Channel] IN ('CAS','CAB') THEN 'MMFA' ELSE 'SDP' END AS [Channel]
,[RegionName] as "Region"
,[AdvisorID] as "Advisor ID"
,[AdvisorName] As "Advisor"
,[SubmitDate] aS "Submit Date"
,[IssueDate] as "Issue Date"
,[CalDaysSubmitToIssue] as "Cycle Time"
,[AnticipatedPremium] as "Anticipated Premium"
,[BingoStatus]  as "BINGO Status"
,CASE WHEN BINGOSTATUS = 'BINGO' THEN 1 ELSE 0 END as "Bingo Indicator"   
,[System]
FROM [RptgAndAnalytics].[StrdRptg].[AnnuityNBFlatFile]
WHERE [SubmitDate] IS NOT NULL AND ((YEAR(SUBMITDATE) >= YEAR(GETDATE())-2)
OR YEAR(IssueDate) >= YEAR(GETDATE())-2)
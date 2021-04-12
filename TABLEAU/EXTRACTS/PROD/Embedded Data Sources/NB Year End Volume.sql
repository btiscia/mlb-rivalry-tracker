SELECT * FROM [RptgAndAnalytics].[StrdRptg].[QuotaBuster]
WHERE YESubmitDate < CAST(getdate() AS DATE)
OR YEIssueDate < CAST(getdate() AS DATE)
SELECT
	   G.AgencyDisplayName,
	   H.FinalRiskClass,
	   C.PrimaryInsuredGender,
	   C.ProductType,
	   H.TabaccoClass AS TobaccoClass,
	   C.UWPath,
	   B.FaceAmount,
	   C.PrimaryInsuredLastName,
	   B.SubmittedDate, 
       B.IssueDate,
	   B.ReportedDate,
	   C.InsuredAge,
	   C.ApplicationType,
	   B.ApplicationReceivedDate,
	   (SELECT GoalValue3 FROM LifeNewBizReporting.dbo.[LNB_GoalsDIM] WHERE GoalTypeID = 9 AND TransType = 'Submitted' AND SalesGroup = FinalRiskClass AND
						CASE WHEN InsuredAge < 17 THEN 1 ELSE 2 END = CASE WHEN GoalValue = 0 THEN 1 ELSE 2 END) AS SubmitBaseline,
	   (SELECT GoalValue3 FROM LifeNewBizReporting.dbo.[LNB_GoalsDIM] WHERE GoalTypeID = 9 AND TransType = 'Issued' AND SalesGroup = FinalRiskClass AND
						CASE WHEN InsuredAge < 17 THEN 1 ELSE 2 END = CASE WHEN GoalValue = 0 THEN 1 ELSE 2 END) AS IssueBaseline,
	   (SELECT GoalValue3 FROM LifeNewBizReporting.dbo.[LNB_GoalsDIM] WHERE GoalTypeID = 9 AND TransType = 'Reported' AND SalesGroup = FinalRiskClass AND
						CASE WHEN InsuredAge < 17 THEN 1 ELSE 2 END = CASE WHEN GoalValue = 0 THEN 1 ELSE 2 END) AS ReportedBaseline

FROM
       LifeNewBizReporting.dbo.[LNB_CycleTimesFCT] A
       INNER JOIN LifeNewBizReporting.dbo.[LNB_ApplicationFCT] B ON A.PolicyNumberINT = B.PolicyNumberINT
       INNER JOIN LifeNewBizReporting.dbo.[LNB_ApplicationDIM] C ON A.PolicyNumberINT = C.PolicyNumberINT
       INNER JOIN LifeNewBizReporting.dbo.[LNB_AgencyDIM] G ON B.AgencyNumber = G.OriginalAgencyNumber
       INNER JOIN LifeNewBizReporting.dbo.[LNB_CoverageDIM] H ON A.PolicyNumberINT = H.PolicyNumberINT

	   WHERE
	   (B.ApplicationReceivedDate >= '2014-05-01'
	   AND B.ApplicationReceivedDate <= '2016-08-31')
       OR (B.IssueDate >= '2014-05-01'
	   AND B.IssueDate <= '2016-08-31')
	   OR (B.ReportedDate >= '2014-05-01'
	   AND B.ReportedDate <= '2016-08-31')
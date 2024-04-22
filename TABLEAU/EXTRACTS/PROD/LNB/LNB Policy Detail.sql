/*
FILENAME: LNB Policy Detail
CREATED BY: Bill Trombley
LAST UPDATED: 4/22/2024
CHANGES MADE: Limited the time frame of the extract to 3 years.
*/

SELECT
	   A.PolicyNumber, 
       A.PolicyNumberINT,
       E.TeamName AS UWTeam,
       F.TeamName AS CMTeam,
       C.ProductType,
       PlanCode,
       ProductionDrivenTeam,
       AgencyDisplayName,
       Region,
       CustomerTeamName,
       SignedReceived, 
       ReceivedApproved, 
       ApprovedIssued,
       ReceivedApprovedFiveDayBand = (SELECT FiveDayBand FROM LifeNewBizReporting.dbo.[LNB_CycleTimeBandsLOV] WHERE ReceivedApproved = CycleTimeDay),
       ReceivedApprovedLegacyBand = (SELECT LegacyBand FROM LifeNewBizReporting.dbo.[LNB_CycleTimeBandsLOV] WHERE ReceivedApproved = CycleTimeDay),
       IssuedReported, 
       SignedIssued, 
       SignedReported,
       CMIOrderDate,
       EZMedCMICycleTimeDays,
       EZMedCMICycleTimeMinutes, 
       LastFinalActionType,
       LastFinalActionDate,
       FirstFinalActionType,
       FirstFinalActionDate, 
       ApprovedDate, 
       WithdrawnDate, 
       DeclineDate, 
       IncompleteDate, 
       SubmittedDate, 
       IssueDate, 
       ApplicationSignDate, 
       ApplicationReceivedDate,
       ADEDate,
       ReportedDate,
       EZMedModifiedDTM,
       EZMedOrderCreateDTM,
       EZMedRatingDTM,
       OrginatingSystem, 
       FaceAmount, 
       FaceAmountBand, 
       B.AmountAtRisk,
       ClientAmountAtRisk,
       InsuredAge,
       C.InsuranceAge, 
       InsuredAgeBand, 
       AlgoEZAppProductExclusionIND, 
       AlgoAgeRiskAMTExclusionIND, 
       AlgoEligibleIND, 
       AlgoEligibleOverrideIND, 
       AlgoOverRideReason, 
       AlgoMiscellaneousExclusionIND, 
       UWPath, 
       DelayedCaseIND, 
       CMIExclusionIND, 
       ApplicationType, 
       EZAppIND, 
       EZAppESignIND, 
       LargeCaseIND, 
       CMIEligibleIND,
       ALGOCaseType,
       EZMEdOrderStatus,
       EZMedStatusCodeGroup,
       EZMedStatusCode,
       EZMedRatingScore,
       EZMedRatingScore_Insured2,
       JuvenileAlgoPolicyResult,
       LTCRider,
       WPRider,
       ALIRRider,
       LISRRider,
       SIPRRider,
       RTRRider,
       GIRRider,
       OIRORider,
       OIRIRider,
       CC1Rider, 
       RiskClass,
       FinalRiskClass, 
       TabaccoClass AS TobaccoClass, 
       RatedIND,
       APSReceivedDate,
       APSReviewDate,
       APPStartAPSReceived,
       FieldOrderedCount,
       HomeOfficeOrderedCount,
       APSTypeIND,
	   LastAlgoRequirementReceived,
       LastALGORequirementReceivedDate,
       LabsReceivedDate,
       RXReceivedDate,
       MVRReceivedDate,
       Part2ReceivedDate,
       CMIReceivedDate,
       ApplicationStartLabsReceived,
       ApplicationStartRXReceived,
       ApplicationStartMVRReceived,
       ApplicationStartPart2Received,
       ApplicationStartCMIReceived,
	   ApplicationStartDate,
	   ApplicationStartLastAlgoRequirementReceived,
	   ApplicationStartLastAlgoRequirementReceivedBand = 
	   (SELECT LastAlgoRequirementBand FROM LifeNewBizReporting.dbo.[LNB_CycleTimeBandsLOV] WHERE ApplicationStartLastAlgoRequirementReceived = CycleTimeDay),	   
	   ApplicationStartLastRequirementReceived,
	   LastRequirementReceivedDate,
	   ApplicationStartPHIReceived,
	   ApplicationStartSHQReceived,
	   PHIReceivedDate,
	   SHQReceivedDate,
	   ContractState,
	   WeightedPremium,
	   DistributionChannel,
	   WeightedPremiumBand,
	   AdvisorName,
	   AdvisorNumber,
	   PrimaryInsuredGender,
	   PrimaryInsuredLastName,
	   CaseStatus,
	   CaseStatusDate,
	   DecisionStatus,
	   CaseApprovedIND,
	   ConversionIND,
	   UnderwriterID,
	   C.UnderwriterName,
	   H.LastM3SResult,
	   ApplicationFirstClosedDate,
	   AmountAtRiskBand,
	   CycleTimeByReceivedDT_IND,
	   (SELECT GoalValue3 FROM LifeNewBizReporting.dbo.[LNB_GoalsDIM] WHERE GoalTypeID = 9 AND TransType = 'Submitted' AND SalesGroup = FinalRiskClass AND
						CASE WHEN InsuredAge < 17 THEN 1 ELSE 2 END = CASE WHEN GoalValue = 0 THEN 1 ELSE 2 END) AS SubmitBaseline,
	   (SELECT GoalValue3 FROM LifeNewBizReporting.dbo.[LNB_GoalsDIM] WHERE GoalTypeID = 9 AND TransType = 'Issued' AND SalesGroup = FinalRiskClass AND
						CASE WHEN InsuredAge < 17 THEN 1 ELSE 2 END = CASE WHEN GoalValue = 0 THEN 1 ELSE 2 END) AS IssueBaseline,
	   (SELECT GoalValue3 FROM LifeNewBizReporting.dbo.[LNB_GoalsDIM] WHERE GoalTypeID = 9 AND TransType = 'Reported' AND SalesGroup = FinalRiskClass AND
						CASE WHEN InsuredAge < 17 THEN 1 ELSE 2 END = CASE WHEN GoalValue = 0 THEN 1 ELSE 2 END) AS ReportedBaseline,
	   (SELECT GoalValue FROM LifeNewBizReporting.dbo.[LNB_GoalsDIM] WHERE GoalID = 5000) AS RecAppJuvGoal,
       (SELECT GoalValue FROM LifeNewBizReporting.dbo.[LNB_GoalsDIM] WHERE GoalID = 5001) AS RecAppAdultGoal,
       (SELECT GoalValue FROM LifeNewBizReporting.dbo.[LNB_GoalsDIM] WHERE GoalID = 5002) AS RecAppNonGoal,
       (SELECT GoalValue FROM LifeNewBizReporting.dbo.[LNB_GoalsDIM] WHERE GoalID = 5003) AS StraightThruJuvGoal,
       (SELECT GoalValue FROM LifeNewBizReporting.dbo.[LNB_GoalsDIM] WHERE GoalID = 5004) AS StraightThruAdultGoal,
       (SELECT GoalValue FROM LifeNewBizReporting.dbo.[LNB_GoalsDIM] WHERE GoalID = 5007) AS ESignGoal,
	   CASE 
              WHEN H.LastM3SResult = 'decl' THEN 'Declined' 
              WHEN H.LastM3SResult IN ('subnt', 'subt') THEN 'Rated' 
              WHEN H.LastM3SResult IN ('nt', 't') THEN 'Standard' 
              WHEN H.LastM3SResult IN ('spnt', 'spt') THEN 'Select Preferred' 
              WHEN H.LastM3SResult = 'upnt' THEN 'Ultra Preferred' 
              ELSE H.LastM3SResult 
       END AS FinalM3SRiskClass,
	   (SELECT MAX(LastUpdated) AS DataLastUpdated FROM [LifeNewBizReporting].[dbo].[LNB_LastUpdated]) AS DataLastUpdated,
	   I.DetailedUWPath,
	   I.SummaryUWPath,
            CASE ApplicationType
	        WHEN 'ADD' THEN 'Additional'
			WHEN 'ALT' THEN 'Alternate'
			WHEN 'CNC' THEN 'Concurrent'
			WHEN 'CNV' THEN 'Conversion'
			WHEN 'EXC' THEN 'Exchange'
			WHEN 'INC' THEN 'Increase'
			WHEN 'OPT' THEN 'Option'
			WHEN 'ORG' THEN 'Original'
			WHEN 'ORW' THEN 'Original With'
			WHEN 'SRV' THEN 'Survey'
			WHEN 'TMP' THEN 'Temporary'
			ELSE ApplicationType 
	    END AS ApplicationTypeFullName
		,[CMIOrderType]
		,[OnlineCMIModifiedDTM]
        ,[OnlineCMIOrderCreateDTM]
        ,[TeleCMIModifiedDTM]
        ,[TeleCMIOrderCreateDTM]
        ,[OnlineCMIOrderID]
        ,[TeleCMIOrderID]
		,CASE WHEN J.MCRHitIndicator IS NULL OR J.MCRHitIndicator = 0 THEN 'No' ELSE 'Yes' END AS MCRReviewedInd
		,CASE WHEN EHRReviewedIndicator IS NULL OR EHRReviewedIndicator = 0 THEN 'No' ELSE 'Yes' END AS EHRReviewedIndicator

	   FROM 
       LifeNewBizReporting.dbo.[LNB_CycleTimesFCT] A
       INNER JOIN LifeNewBizReporting.dbo.[LNB_ApplicationFCT] B ON A.PolicyNumberINT = B.PolicyNumberINT
       INNER JOIN LifeNewBizReporting.dbo.[LNB_ApplicationDIM] C ON A.PolicyNumberINT = C.PolicyNumberINT
       INNER JOIN LifeNewBizReporting.dbo.[LNB_EZMedDIM] D ON A.PolicyNumberINT = D.PolicyNumberINT
       INNER JOIN LifeNewBizReporting.dbo.[LNB_TeamDIM] E ON B.UWTeamID = E.TeamID
       INNER JOIN LifeNewBizReporting.dbo.[LNB_TeamDIM] F ON B.CMTeamID = F.TeamID
       INNER JOIN LifeNewBizReporting.dbo.[LNB_AgencyDIM] G ON B.AgencyNumber = G.OriginalAgencyNumber
       INNER JOIN LifeNewBizReporting.dbo.[LNB_CoverageDIM] H ON A.PolicyNumberINT = H.PolicyNumberINT
	   LEFT OUTER JOIN [LifeNewBizReporting].[dbo].[LNB_UWPathsLOV] I ON C.UWPath = I.DetailedUWPath
	   LEFT OUTER JOIN [LifeNewBizReporting].[dbo].[LNBDHPPolicyLevelExtract] J ON A.PolicyNumber = J.PolicyNumber

	   WHERE YEAR(ApplicationReceivedDate) BETWEEN YEAR(GETDATE()) - 2 AND YEAR(GETDATE())
	   AND (YEAR(IssueDate) BETWEEN YEAR(GETDATE()) - 2 AND YEAR(GETDATE())
	   OR IssueDate IS NULL)
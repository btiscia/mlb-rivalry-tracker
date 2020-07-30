SELECT
ReportingDate AS "Date"
,CycleTimeType AS "Cycle Time Type"
,ShortClaimNumber AS"Short Claim Number" 
,NoFormsIndicator AS "No Forms Indicator"
,CycleTime AS "Cycle Time"
,MetExpected
--,GoalID AS "Goal ID"
,GoalValue AS "Goal Value"
--,SourceSystemID
--,RunID
--,UpdateRunID
,TransDate
,ClaimCategory AS "Claim Category"
,DIBSCustomerName AS "Claimant"
--,OccupationDescription
--,ICD1GroupID
--,ICD1GroupName
--,ICD1Code
--,ICD1Description
,DisabilityDate AS "Date of Disability"
,DateOfNotice
,DateOfForms
,DateOfDecision
,PreclaimEndDate
,EstimatedBenefitDuration
,BirthDate AS "Birth Date"
,ResidenceState AS "Residence State"
,ExaminerID
,ExaminerName AS "Examiner"
,ExaminerPartyEmployeeID
,ExaminerManagerName AS "Manager"
,ExaminerTeamName AS "Team"
FROM PROD_DMA_VW.DIC_CYCLE_TIME_RPT_VW
WHERE (RestrictedClaimIndicator = 0 OR RestrictedClaimIndicator IS NULL)
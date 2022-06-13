--Tableau Data Source: DI Claims Caseload Restricted

/*
* This routine pulls from DIC_CASE_LOAD_RPT_VW (Created by Vince Bonaddio)
*  Peer Review & Change Log:
*  Peer Review Date: 
*  Source for this routine is  
*  Author: John Avgoustakis
*  Created: 12/12/2019
* Revision: 1/5/2022 - Bill Trombley - Removed Restricted Claim filter.
======================================================================
*/

 
SELECT
ShortClaimNumber
,ClaimNumber AS "Claim Number"
,PolicyNumber AS "Policy Number"
,ClaimCategory AS "Claim Category"
,CASE
    WHEN BaseClaimIndicator = 1 THEN 'Claim' ELSE 'Additional Policy'
END AS "Claim/Add'l Policy"
,CaseLoadClaimCategory AS Category
,AgeDays AS "Days Aging"
,AgeMonths AS "Months Aging"
,COALESCE(ExaminerName, 'Unknown') AS Examiner
,ManagerName AS Manager
,InsuredFullName AS Insured
,CASE
    WHEN ClaimStatusCategory = 'Approved' AND TeamFunctionID = 3 THEN 'Stable and Mature' 
    ELSE ClaimStatusCategory
END AS "Claim Status"
,CurrentSubstatus AS "Claim Substatus"
,DisabilityDate
,LateNoticeIndicator
,ERISAIndicator
,ContestableIndicator
,InLitigationIndicator
,OwnOccupationIndicator
,ReservationOfRightsIndicator
,SupportIndicator
,WorksiteIndicator
,EFTIndicator
,SSDIApprovedIndicator
,BenefitEndDate AS "Max Benefit Date"
,AttorneyRepIndicator
,AppealIndicator
,RecoveryBenefitIndicator
,QuickDecisionIndicator
,InsuredZip AS "Insured Zip Code"
,InsuredState AS "Insured State"
,EstimatedBenefitDuration
,LastPreClaimSubstatusDate 
,PreClaimDeleteDate
,ApprovedSubstatusDate
,HealthDate
,WaiverOnlySubstatusDate
,BirthDate AS "Birth Date"
,AgeAtDOD
,ReinsuranceReportDate
,ICD1Code
,ICD1Description
,ICD1GroupName
,NoticeDate AS "Notice Date"
,OpenDate AS "Open Date"
,MedicalReviewSupportDate
,TransDate
,LoadDate AS "Load Date"
,RestrictedClaimIndicator
FROM    PROD_DMA_VW.DIC_CASE_LOAD_RPT_VW
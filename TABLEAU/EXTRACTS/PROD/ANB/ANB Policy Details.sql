/*
Name: ANB Modern Policy Details
Author/Editor: Vince Bonaddio / Bill Trombley
Last Updated: 4/15/2021
Comments: Added Placement Status and Final Disposition Date
*/

--Contract Level

SELECT
T1.HoldingKey
,T1.OrderEntryID
,T1.AgreementID
,T1.PolicyNumber
,T1.NewBusinessDocType
,T1.ContractState
,T1.ResidenceState
,NULL AS Region
,T1.AgentID
,T1.Advisor
,T1.AgencyNumber
,T1.FirmName
,CASE WHEN T1.Distributor = 'SDP' THEN 'MMSD' ELSE T1.Distributor END AS Distributor
,T1.Channel
,T1.ChannelType
,T1.MarketTypeCode AS "Market Code"
,T1.MarketTypeCategory AS "Market Category"
,CASE
WHEN T1.Product LIKE ('%Capital Vantage%') THEN 'Capital Vantage'
WHEN T1.Product LIKE ('%Transitions Select%') THEN 'Transition Select'
WHEN T1.Product LIKE ('%RetireEase Choice%') THEN 'RetireEase Choice'
WHEN T1.Product LIKE ('%RetireEase%') THEN 'RetireEase'
WHEN T1.Product LIKE ('%Stable Voyage%') THEN 'Stable Voyage'
WHEN T1.Product LIKE ('%Odyssey Select%') THEN 'Odyssey Select'
WHEN T1.Product LIKE ('%Index Horizons%') THEN 'Index Horizons'
WHEN T1.Product LIKE ('%Envision%') THEN 'Envision'
ELSE 'Unknown'
END AS Product
,T1.ProductCategory
,T1.AnticipatedPremium
,T1.DepositAmount
,T1.BINGOStatus,
(
SELECT PROD_DMA_VW.DATE_DIM_VW.IsHoliday
FROM PROD_DMA_VW.DATE_DIM_VW
WHERE T1.IssueDate = PROD_DMA_VW.DATE_DIM_VW.ShortDate
) AS IssueDateIsHoliday,
(
SELECT PROD_DMA_VW.DATE_DIM_VW.IsHoliday
FROM PROD_DMA_VW.DATE_DIM_VW
WHERE T1.ApplicationSubmitDate = PROD_DMA_VW.DATE_DIM_VW.ShortDate
) AS AppSubDateIsHoliday,
T1.BINGOIndicator,
T1.AutoApprovalIndicator,
(
SELECT PROD_DMA_VW.DATE_DIM_VW.IsHoliday
FROM PROD_DMA_VW.DATE_DIM_VW
WHERE T1.NewBusinessSubmitDate = PROD_DMA_VW.DATE_DIM_VW.ShortDate
) AS NBSubmitDateIsHoliday,
CASE
WHEN T1.IssueDate >= '2018-08-01' THEN 1
ELSE 0
END AS IssueCountforBINGORate,
(
SELECT PROD_DMA_VW.DATE_DIM_VW.PreviousBusinessDay
FROM PROD_DMA_VW.DATE_DIM_VW
WHERE PROD_DMA_VW.DATE_DIM_VW.ShortDate = CAST(CURRENT_DATE AS DATE)
) AS PrevBusDayOfToday
,T1.ApplicationSubmitDate
,T1.SuitabilityApprovalDate
,T1.OriginalOrderSubmitDate
,T1.SuitabilitySubmitDate
,T1.ApplicationSignDate
,T1.OrderChangeDate
,T1.NewBusinessSubmitDate
,T1.PAWDate
,T1.TOADate
,T1.BINGODate
,T1.FirstNIGODate
,T1.NewBusinessEndDate
,T1.IssueDate
,T1.RejectDate
,T1.WithdrawnDate
,CAST(CURRENT_DATE AS DATE) - T1.ApplicationSubmitDate AS CalDaysSinceSub
,CAST(CURRENT_DATE AS DATE) - T1.NewBusinessEndDate AS CalDaysSinceNBSub
,T1.IssueDate - T1.ApplicationSignDate AS CalDaysSignToIssue
,T1.ApplicationSignDate - T1.ApplicationSubmitDate AS CalDaysSignToSub
,T1.OriginalOrderSubmitDate - T1.ApplicationSignDate AS CalDaysAppSignToSuitSub
,T1.NewBusinessSubmitDate - T1.ApplicationSignDate AS CalDaysSignToNBSub
,T1.IssueDate - T1.ApplicationSubmitDate AS SubtoIssueCycleTime
,T1.NewBusinessSubmitDate - T1.ApplicationSubmitDate AS CalDaysSubToNBSub
,T1.IssueDate - T1.NewBusinessSubmitDate AS CalDaysNBRcvdToIssued
,T1.BINGODate - T1.NewBusinessSubmitDate AS NBSubToBINGO
,T1.PAWDate - T1.NewBusinessSubmitDate AS CalDaysNBSubToPAW
,T2.BUSINESSDAY
,T1.SuitabilityApprovalDate - T1.SuitabilitySubmitDate AS CalDaysSuitSubToSuitApvd
,T1.NewBusinessSubmitDate - T1.SuitabilityApprovalDate AS CalDaysSuitApvdToNBSub
,CAST(T1.OrderChangeDate AS DATE) - T1.SuitabilityApprovalDate AS CalDaysSuitApvdToSuitTrans
,CAST(T1.OrderChangeDate AS DATE) - T1.SuitabilitySubmitDate AS CalDaysSuitSubToSuitTrans
,T1.IssueDate - T1.SuitabilitySubmitDate AS CalDaysSuitSubToIssue
,T1.NewBusinessSubmitDate - CAST(T1.OrderChangeDate AS DATE) AS CalDayssuitCmpltToNBRcvd
,T1.PAWDate - T1.BINGODate AS CalDaysBINGOToPAW
,T1.TOADate - T1.BINGODate AS CalDaysBINGOToTOA
,T1.IssueDate - T1.TOADate AS CalDaysTOAToIssue
, CASE WHEN NewBusinessDocType = 'NB Purchase w App' AND T3.FUNCTIONNAME = 'SE2' THEN (SELECT BUSINESSDAY FROM PROD_DMA_VW.DATE_DIM_VW WHERE SHORTDATE = IssueDate) - T2.BUSINESSDAY
WHEN NewBusinessDocType = 'Incoming Transfer' AND T3.FUNCTIONNAME = 'SE2' THEN (SELECT BUSINESSDAY FROM PROD_DMA_VW.DATE_DIM_VW WHERE SHORTDATE = TOADate) - T2.BUSINESSDAY
WHEN NewBusinessDocType = 'Annuity Application' AND T3.FUNCTIONNAME = 'SE2' THEN (SELECT BUSINESSDAY FROM PROD_DMA_VW.DATE_DIM_VW WHERE SHORTDATE = PAWDate) - T2.BUSINESSDAY
ELSE NULL
END AS SE2DocTypeCycleTime
, CASE WHEN NewBusinessDocType = 'NB Purchase w App' AND T3.FUNCTIONNAME = 'Home Office' THEN (SELECT BUSINESSDAY FROM PROD_DMA_VW.DATE_DIM_VW WHERE SHORTDATE = IssueDate) - T2.BUSINESSDAY
WHEN NewBusinessDocType = 'Incoming Transfer' AND T3.FUNCTIONNAME = 'Home Office' THEN (SELECT BUSINESSDAY FROM PROD_DMA_VW.DATE_DIM_VW WHERE SHORTDATE = TOADate) - T2.BUSINESSDAY
WHEN NewBusinessDocType = 'Annuity Application' AND T3.FUNCTIONNAME = 'Home Office' THEN (SELECT BUSINESSDAY FROM PROD_DMA_VW.DATE_DIM_VW WHERE SHORTDATE = PAWDate) - T2.BUSINESSDAY
ELSE NULL
END AS HODocTypeCycleTime
, FUNCTIONNAME
, GOALVALUE AS SLA
/*
, CASE WHEN T3.FUNCTIONNAME IS NULL THEN T3.GOALVALUE END AS SE2SLA
, CASE WHEN T3.FUNCTIONNAME = 'Home Office' THEN T3.GOALVALUE END AS HOSLA*/
,T1.TransDate
,CASE
WHEN T1.NewBusinessSubmitDate IS NOT NULL AND T1.WithdrawnDate IS NOT NULL THEN 'Withdrawn'
WHEN T1.NewBusinessSubmitDate IS NOT NULL AND T1.RejectDate IS NOT NULL THEN 'Rejected'
WHEN T1.NewBusinessSubmitDate IS NOT NULL AND T1.IssueDate IS NOT NULL AND T1.IssueDate <> '0001/01/01' THEN 'Issued'
END AS PlacementStatus
,CASE
WHEN T1.NewBusinessSubmitDate IS NOT NULL THEN COALESCE(T1.WithdrawnDate, T1.RejectDate, T1.IssueDate)
END AS FinalDispositionDate
,FinalDispositionDate - T1.NewBusinessSubmitDate AS CalDaysNBSubToFinalDisposition
FROM PROD_DMA_VW.ANB_APPLICATION_RPT_VW T1
LEFT JOIN PROD_DMA_VW.DATE_DIM_VW T2 ON T1.BINGODate = T2.ShortDate
LEFT JOIN PROD_DMA_VW.GOAL_CURR_DIM_VW T3 ON T1.NEWBUSINESSDOCTYPE = T3.TransactionTypeName
QUALIFY ROW_NUMBER() OVER(PARTITION BY HOLDINGKEY, NEWBUSINESSDOCTYPE, COALESCE(SE2DocTypeCycleTime, HODocTypeCycleTime) ORDER BY T1.TRANSDATE) = 1
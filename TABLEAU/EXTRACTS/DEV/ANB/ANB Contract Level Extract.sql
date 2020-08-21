--ANB Modern Policy Details
--Contract Level

SELECT '10' as "CalDayssuitCmpltToNBRcvd"

, HoldingKey
, OrderEntryID
, AgreementID
, PolicyNumber
, NewBusinessDocType
, ContractState
, ResidenceState
, Null as "Region"
, AgentID
, Advisor
, AgencyNumber
, FirmName
, Distributor
, Channel
, ChannelType
, ProductCode
, Product
, ProductCategory
, AnticipatedPremium
, DepositAmount
, BINGOStatus
, (SELECT IsHoliday FROM PROD_DMA_VW.DATE_DIM_VW WHERE IssueDate = ShortDate) AS "IssueDateIsHoliday"
, (SELECT IsHoliday FROM PROD_DMA_VW.DATE_DIM_VW WHERE ApplicationSubmitDate = ShortDate) AS "AppSubDateIsHoliday"
, BINGOIndicator
, AutoApprovalIndicator
,(SELECT IsHoliday FROM PROD_DMA_VW.DATE_DIM_VW WHERE NewBusinessSubmitDate = ShortDate) AS "NBSubmitDateIsHoliday"
, CASE WHEN IssueDate >= '2018-08-01' THEN 1 ELSE 0 END AS "IssueCountforBINGORate"
, (SELECT PreviousBusinessDay FROM PROD_DMA_VW.DATE_DIM_VW WHERE ShortDate = CAST(Current_Date AS DATE)) AS PrevBusDayOfToday
, ApplicationSubmitDate
, SuitabilityApprovalDate
, OriginalOrderSubmitDate
, SuitabilitySubmitDate
, ApplicationSignDate
, OrderChangeDate
, NewBusinessSubmitDate
, PAWDate
, TOADate
, BINGODate
, FirstNIGODate
, NewBusinessEndDate
, IssueDate
, RejectDate
, WithdrawnDate
, CAST(Current_Date AS DATE) - ApplicationSubmitDate AS CalDaysSinceSub
, CAST(Current_Date AS DATE) - NewBusinessEndDate AS CalDaysSinceNBSub
, IssueDate - ApplicationSignDate AS CalDaysSignToIssue
, ApplicationSignDate - ApplicationSubmitDate AS CalDaysSignToSub
, OriginalOrderSubmitDate - ApplicationSignDate AS CalDaysAppSignToSuitSub
, NewBusinessEndDate - ApplicationSignDate AS CalDaysSignToNBSub
, IssueDate - ApplicationSubmitDate AS "SubtoIssueCycleTime"
, SuitabilityApprovalDate - ApplicationSubmitDate AS CalDaysSubToSuitApvd
, NewBusinessSubmitDate - ApplicationSubmitDate AS CalDaysSubToNBSub
, IssueDate - NewBusinessSubmitDate AS CalDaysNBRcvdToIssued
, BINGODate - NewBusinessSubmitDate AS NBSubToBINGO
, NewBusinessSubmitDate - PAWDate AS CalDaysNBSubToPAW
, SuitabilityApprovalDate - SuitabilitySubmitDate AS CalDaysSuitSubToSuitApvd
, NewBusinessSubmitDate - SuitabilityApprovalDate AS CalDaysSuitApvdToNBSub
, CAST(OrderChangeDate AS DATE) - SuitabilityApprovalDate AS CalDaysSuitApvdToSuitTrans
, CAST(OrderChangeDate AS DATE) - SuitabilitySubmitDate AS CalDaysSuitSubToSuitTrans
, IssueDate - SuitabilitySubmitDate AS CalDaysSuitSubToIssue
, PAWDate - BINGODate AS CalDaysBINGOToPAW
, TOADate - BINGODate AS CalDaysBINGOToTOA
, IssueDate - TOADate AS CalDaysTOAToIssue

FROM PROD_DMA_VW.ANB_APPLICATION_RPT_VW T1

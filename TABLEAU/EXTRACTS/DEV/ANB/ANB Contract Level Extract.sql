--ANB Modern Policy Details
--Contract Level

SELECT '10' as "CalDayssuitCmpltToNBRcvd"

, (SELECT PreviousBusinessDay FROM PROD_DMA_VW.DATE_DIM_VW WHERE ShortDate = CAST(Current_Date AS DATE)) AS PrevBusDayOfToday
, Distributor
, Channel
, ChannelType
, Product
, Advisor
, Null as "Region"
, (SELECT IsHoliday FROM PROD_DMA_VW.DATE_DIM_VW WHERE IssueDate = ShortDate) AS "IssueDateIsHoliday"
, (SELECT IsHoliday FROM PROD_DMA_VW.DATE_DIM_VW WHERE ApplicationSubmitDate = ShortDate) AS "AppSubDateIsHoliday"
, AgreementID
, ProductCode
, HoldingKey
, OrderEntryID
, AutoApprovalIndicator
, AnticipatedPremium
, DepositAmount
, NewBusinessDocType
, ContractState
, ResidenceState
, AgentID
, AgencyNumber
, FirmName
, ProductCategory
, PolicyNumber
, SuitabilityApprovalDate
, OriginalOrderSubmitDate
, SuitabilitySubmitDate
, ApplicationSignDate
, NewBusinessSubmitDate
,(SELECT IsHoliday FROM PROD_DMA_VW.DATE_DIM_VW WHERE NewBusinessSubmitDate = ShortDate) AS "NBSubmitDateIsHoliday"
, IssueDate
, RejectDate
, WithdrawnDate
, PAWDate
, TOADate
, OrderChangeDate
, ApplicationSubmitDate
, FirstNIGODate
, NewBusinessEndDate
, BINGODate
, BINGOStatus
, BINGOIndicator
, CASE WHEN IssueDate >= '2018-08-01' THEN 1 ELSE 0 END AS "IssueCountforBINGORate"
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

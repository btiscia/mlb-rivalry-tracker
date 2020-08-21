--ANB Modern Policy Details
--Contract Level

SELECT '10' as

 HoldingKey
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
, IssueDate - ApplicationSignDate AS CalDaysSignToIssue  --Cycle Time Dashboard
, ApplicationSignDate - ApplicationSubmitDate AS CalDaysSignToSub
, OriginalOrderSubmitDate - ApplicationSignDate AS CalDaysAppSignToSuitSub   ---Cycle Time Dash

, NewBusinessSubmitDate - ApplicationSignDate AS CalDaysSignToNBSub  --Cycle Time Dash

, IssueDate - ApplicationSubmitDate AS "SubtoIssueCycleTime"  ---Cycle Time Dashboard
, SuitabilityApprovalDate - ApplicationSubmitDate AS CalDaysSubToSuitApvd
, NewBusinessSubmitDate - ApplicationSubmitDate AS CalDaysSubToNBSub
, IssueDate - NewBusinessSubmitDate AS CalDaysNBRcvdToIssued --Cycle Time dashboard
, BINGODate - NewBusinessSubmitDate AS NBSubToBINGO
, PAWDate-NewBusinessSubmitDate AS CalDaysNBSubToPAW  --Cycle Time Dashboard
, SuitabilityApprovalDate - SuitabilitySubmitDate AS CalDaysSuitSubToSuitApvd  ---Cycle Time Dashboard
, NewBusinessSubmitDate - SuitabilityApprovalDate AS CalDaysSuitApvdToNBSub
, CAST(OrderChangeDate AS DATE) - SuitabilityApprovalDate AS CalDaysSuitApvdToSuitTrans  ---Cycle Time Dashboard
, CAST(OrderChangeDate AS DATE) - SuitabilitySubmitDate AS CalDaysSuitSubToSuitTrans --Cycle Time Dashboard 
, IssueDate - SuitabilitySubmitDate AS CalDaysSuitSubToIssue  ---Cycle Time Dashboard
, NewBusinessSubmitDate -  CAST(OrderChangeDate AS DATE) AS "CalDayssuitCmpltToNBRcvd"  ---Cycle Time Dashboard
, PAWDate - BINGODate AS CalDaysBINGOToPAW
, TOADate - BINGODate AS CalDaysBINGOToTOA
, IssueDate - TOADate AS CalDaysTOAToIssue --Cycle Time Dashboard

FROM PROD_DMA_VW.ANB_APPLICATION_RPT_VW T1

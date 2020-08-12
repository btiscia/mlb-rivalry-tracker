SELECT '10' as "CalDayssuitCmpltToNBRcvd"

, (SELECT PreviousBusinessDay FROM PROD_DMA_VW.DATE_DIM_VW WHERE ShortDate = CAST(Current_Date AS DATE)) AS PreviousBusinessDayOfToday
, Distributor
, Channel
, ChannelType
, Product
, Advisor
, Null as "Region"
, (SELECT IsHoliday FROM PROD_DMA_VW.DATE_DIM_VW WHERE IssueDate = ShortDate) AS "Issue Date Is Holiday"
, (SELECT IsHoliday FROM PROD_DMA_VW.DATE_DIM_VW WHERE ApplicationSubmitDate = ShortDate) AS "Submit Date Is Holiday"
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
, CASE WHEN IssueDate >= '2018-08-01' THEN 1 ELSE 0 END AS "Issue Count for BINGO Rate"
, CAST(Current_Date AS DATE) - ApplicationSubmitDate AS CalDaysSinceSubmit
, CAST(Current_Date AS DATE) - NewBusinessEndDate AS CalDaysSinceNBSubmit
, IssueDate - ApplicationSignDate AS CalDaysSignToIssue
, ApplicationSignDate - ApplicationSubmitDate AS CalDaysSignToSubmit
, OriginalOrderSubmitDate - ApplicationSignDate AS CalDaysAppSignToSuitSubmit
, NewBusinessEndDate - ApplicationSignDate AS CalDaysSignToNBSubmit
, IssueDate - ApplicationSubmitDate AS "Submit to Issue Cycle Time"
, SuitabilityApprovalDate - ApplicationSubmitDate AS CalDaysSubmitToSuitApvd
, NewBusinessSubmitDate - ApplicationSubmitDate AS CalDaysSubmtToNBSubmit
, IssueDate - NewBusinessSubmitDate AS CalDaysNBRcvdToIssued
, BINGODate - NewBusinessSubmitDate AS NBSubmitToBINGO
, NewBusinessSubmitDate - PAWDate AS CalDaysNBSubmitToPAW
, SuitabilityApprovalDate - SuitabilitySubmitDate AS CalDaysSuitSubmitToSuitApvd
, NewBusinessSubmitDate - SuitabilityApprovalDate AS CalDaysSuitApvdToNBSubmit
, CAST(OrderChangeDate AS DATE) - SuitabilityApprovalDate AS CalDaysSuitApvdToSuitTransmit
, CAST(OrderChangeDate AS DATE) - SuitabilitySubmitDate AS CalDaysSuitSubmitToSuitTransmit
, IssueDate - SuitabilitySubmitDate AS CalDaysSuitSubmitToIssue
, PAWDate - BINGODate AS CalDaysBINGOToPAW
, TOADate - BINGODate AS CalDaysBINGOToTOA
, IssueDate - TOADate AS CalDaysTOAToIssue

FROM PROD_DMA_VW.ANB_APPLICATION_RPT_VW T1

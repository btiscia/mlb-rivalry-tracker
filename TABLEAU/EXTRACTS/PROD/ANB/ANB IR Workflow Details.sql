SELECT DISTINCT
ActivityID
, SourceTransactionID AS "OrderEntryID"
--, AgreementID
--, HoldingKey
, ChannelType
, ProductCategory AS "Product Category"
, Product
, Distributor
, Channel
, AgentID
, Advisor
, FirmNum
, FirmName AS "Firm Name"
, RegionName AS "Region Name"
, WorkEventID
, WorkEventName
, DivisionCode
, DepartmentCode
, FunctionName
, SegmentName
, TeamPartyID
, PartyEmployeeID
, EmployeeFirstName
, EmployeeLastName
, EmployeeLastName||', '|| EmployeeFirstName AS "Employee"
, ManagerLastName||', '|| ManagerFirstName AS "Manager"
, OrganizationName
, DepartmentName
, TeamName
, TransactionTypeID
, ReceivedDate AS "Received Date"
, LoadDate
, CompletedDate AS "Completed Date"
, TAT
, TATGoal
, DaysPending
, DaysPastTAT AS "Days Past TAT"
, InitialReviewIGOIndicator AS "IGOIndicator"
, SuitabilityIGOIndicator
, AutoApprovedIndicator
, ProductivityCredits
, ApplicationSignDate
, SuitabilityApprovalDate
, OriginalOrderSubmitDate
, ParentCancelDate
, SuitabilitySubmitDate
--, IssueDate
, RejectDate
--, WithdrawnDate
, CancelDate
, CancelReworkDate
--, NBPurchaseWAppIndicator
--, IncomingTransferIndicator
--, AnnuityAppIndicator
--, NBReg60Indicator
--, ExcludedIndicator
--, OverlapIndicator
--, SDElectIndicator
, TransDate
FROM PROD_DMA_VW.ACT_ANB_SUITABILITY_FCT_RPT_VW

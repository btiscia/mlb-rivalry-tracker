/*
* This routine pulls digital adoption PIT transactions with employee info and customer demographics 
*  Peer Review & Change Log:
*  Peer Review Date: 
*  Source for this routine is  PROD_DMA_VW.ACT_DIGITAL_ADOPT_MART_PIT_VW
*  Author: Kristin Carlile
*  Created: 4/12/2021
* Revised: 1/24/2022 added processing type field - Kristin Carlile
*/

SELECT 
IntegratedActivityID AS "Integrated Activity ID"
, SourceActivityID AS "Source Activity ID"
, SrcSysID AS "SrcSysID"
--, SourceFactTableID
, SourceTransactionID AS "Source Transaction ID"
, WorkID AS "Work ID"
, WorkEventID AS "Work Event ID"
, ServiceChannelCode AS "Service Channel Code"
, ServiceChannelName AS "Service Channel Name"
, TeamPartyID AS "Team Party ID" 
--, PartyEmployeeID
, MMID
--, SourceAgreementID
--, SourceHoldingKey
--, SourceAdminSystemID
--, SourceAdminSystemCode
--, RecIdent
--, PrimaryLogID
--, PrimaryLogValueDescription
--, RequestorTypeCode
, RequestorTypeName AS "Requestor Type Name" 
--, LoggedByTeamPartyID as "Logged by Team party ID"
--, LoggedByPartyEmployeeID as "Logged by Party Employee ID"
--, LoggedByMMID as "Logged by MMID"
, LoadDate as "Load Date" 
, LoggedDate as "Logged Date"
, ReceivedDate as "Received Date"
, CompletedDate as "Completed Date"
, ProdCredit as "Prod Credit"
, BCCIndicator as "BCC Indicator" 
, ShortComment as "Short Comment" 
, DirectLinkType as "Direct Link Type" 
--, CustomerAgreementDimensionID
--, CustomerAgreementUUID
--, CustomerAgreementChecksum
, AgreementID as "Agreement ID"
, HoldingKey as "Holding Key"
, HoldingKeyPrefix as "Holding Key Prefix" 
, HoldingKeySuffix as "Holding Key Suffix"
--, AgreementSourceCode as "Agreement Source Code"
, LOBCode as "LOB Code"
, LOBName as "LOB Name"
, MajorProductName as "Major Product Name"
, MinorProductName as "Minor Product Name"
, FaceAmount as "Face Amount"
, PolicyEffectiveDate as "Policy Effective Date"
, PolicyAge as "Policy Age"
, MemberID
--, PartyID
--, PartyAgreementStartDate
--, PartyAgreementEndDate
--, PartyAgreementRoleCode
--, PartyAgreementRoleName
--, PartyAgreementRoleSubtypeCode
, CustomerEffectiveDate as "Customer Effective Date"
, CustomerTenure as "Customer Tenure"
--, CustomerPartyTypeCode
--, BirthDate as "Birth Date"
, CustomerAge as "Customer Age"
, ResidenceState as "Residence State"
, ResidenceZipCode as "Residence Zip Code"
, GenderCode as "Gender"
, RegistrationDate as "Registration Date"
, RegistrationStatusCode as "Registration Status Code" 
, ExistingRegistrationIndicator as "Existing Registration Indicato"
, NewRegistrationIndicator as "New Registration Indicator"
, NewRegistrationCount as "New Registration Count"
, NoRegistrationIndicator as "No Registration Indicator"
, EmployeeTenure as "Employee Tenure"
, WorkEventNumber as "Work Event Number" 
, WorkEventOrganizationID as "Work Event Organization ID"
, WorkEventDepartmentID as "Work Event Department ID"
, DivisionCode as "Division Code" 
, DepartmentCode as "Department Code" 
--, FunctionID
--, SegmentID
, GroupID as "Group ID"
, GroupTypeID as "Group Type ID"
--, PrimaryRoleID
, WorkEventName as "Work Event Name"
, WorkEventOrganizationName as "Work Event Organization Name"
, SystemDivisionName as "System Division Name" 
, WorkEventDepartmentName as "Work Event Department Name"
--, SystemDepartmentName
, FunctionName as "Function"
, SegmentName as "Segment"
, GroupName as "Group Name"
, GroupTypeName
--, PrimaryRoleName
--, WorkEventActiveIndicator as "Work Event Active Indicator"
, ActionableIndicator as "Actionable Indicator"
, SystemName as "System Name"
--, WorkEventDimStartDate
--, WorkEventDimEndtDate
--, WorkEventDimTransDate
,ProcessingType as "Processing Type"
--, SiteID as "Site ID"
, EmployeeOrganizationID as "Employee Organization ID"
, EmployeeDepartmentID as "Employee Department ID"
--, TeamID
, EmployeeOrganizationName as "Employee Organization Name"
, EmployeeDepartmentName as "Employee Department Name"
--, ParentTeamName 
, TeamName as "Team Name"
, ManagerLastName || ', ' || ManagerFirstName as "Manager Name"
, ManagerEmail as "Manager Email" 
, TeamLeadLastName || ', ' || TeamLeadFirstName as "Team Lead Name"
, EmployeeRoleName as "Employee Role Name" 
--, EmployeePartyTypeName
, EmployeeLastName || ', ' || EmployeeFirstName as "Employee Name"
, EmployeeEmail as "Employee Email"
, InternalIndicator as "Internal Indicator"
, FTE 
, FTEHours as "FTE Hours"
, ClassRank as "Class Rank"
--, EmployeeReportingIndicator as "Employee Reporting Indicator" 
--, TimeOutReportIndicator as "TimeOut Report Indicator"
--, LTCIndicator as "LTC Indicator"
--, TrexIndicator as "TREX Indicator"
, HireDate as "Hire Date"
, EffectiveDate as "Effective Date"
, TerminationDate as "Termination Date"
--, EmployeeDimStartDate
--, EmployeeDimEndDate
--, EmployeeDimTransDate
, SourceSystemID as "Source System ID"
--, RunID
--, UpdateRunID
, TransDate as "Trans Date"

FROM PROD_DMA_VW.ACT_DIGITAL_ADOPT_MART_PIT_VW
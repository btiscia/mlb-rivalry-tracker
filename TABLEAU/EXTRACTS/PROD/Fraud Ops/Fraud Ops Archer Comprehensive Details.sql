/*
Name: Fraud Operations Archer Comprehensive Details SQL Extract
Author/Editor: John Avgoustakis
Last Updated: 10/1/2020
Comments: Added updated Payment Type field.

Editor: Christina Valenti
Last Updated: 12/14/2020
Comments: Added case statement for product line, 
changed case statement for business area,
and removed penetration level and penetration level category

Editor: Christina Valenti
Last Updated: 5/20/2022
Comments: 
Repointed to Vertica table
Replaced Like Any statement bc that is not avail in Vertica
*/
SELECT
	AlertID AS "Alert ID"  ,
	--,Null AS Firm
	AlertOriginCategory AS "Alert Category" ,
	AlertOrigin AS "Alert Origin" ,
	OpenedByMMID AS "Opened By MMID" ,
	OpenedByName AS "Opened By" ,
	Status ,
	AlertDateReceived AS "Date Received" ,
	DateClosed AS "Date Closed" ,
	CASE
		WHEN AccessChannel IS NULL THEN 'Unknown'
		ELSE AccessChannel
	END AS "Access Channel" ,
	CaseCautionPlaced AS "Caution Placed" ,
	CaseDateCautionRemoved AS "Date Caution Removed" ,
	CaseHandleTime AS "Handle Time" ,
	CaseReferralGroup AS "Referral Group" ,
	IncidentIntermediary AS Intermediary ,
	CaseDisposition AS "Case Disposition" ,
	Penetration ,
	PenetrationDepth AS "Penetration Depth"   ,
	--,PenetrationLevelCategory AS "Penetration Level Category"
	--,PenetrationLevel AS "Penetration Level"
 /*,CASE
    WHEN ProductType = 'Insurance Products' THEN 'Insurance'
    WHEN ProductType = 'Wealth Management / Investment Products' THEN 'MMLIS'
    WHEN ProductType = 'Retirement Products' THEN 'Workplace'
    ELSE 'Other'
END AS "Business Area"*/
	CASE
		WHEN ProductType = 'Insurance Products'
--		AND ProductLine NOT LIKE ALL ('%Coverpath%','%Haven%') THEN 'Insurance'
		AND Productline NOT LIKE '%Coverpath%'
		AND Productline NOT LIKE '%Haven%'
		THEN 'Insurance'
		WHEN ProductType = 'Wealth Management / Investment Products' THEN 'MMLIS'
		WHEN ProductType = 'Retirement Products' THEN 'Workplace'
		ELSE 'Other'
	END AS "Business Area",
	ReferralReason AS "Referral Reason" ,
	ReferrerName AS "Referral Name" ,
	ReferringArea AS "Referring Area" ,
	IncidentAccountResidence AS "Account Residence" ,
	ThreatActor AS "Threat Actor" ,
	IncidentTransaction AS "Transaction" ,
	Taxonomy  ,
	--,ProductLine as "Product Line"
	CASE
		WHEN ProductLine IS NULL THEN ProductType
		ELSE ProductLine
	END AS "Product Line" ,
	PaymentType AS "Payment Type"  ,
	--,RelatedDistributor AS Firm
	--,ControlEffectiveness AS "Control Effectiveness" ON HOLD
	IncidentAccountValue AS "Account Value" ,
	IncidentDisbmtAmountRequested AS "Disbursement Amount Requested" ,
	IncidentDisbmtAmountPaid AS "Disbursement Amount Paid" ,
	CASE
		WHEN IncidentDisbmtAmountPaid <= IncidentDisbmtAmountRequested
		AND DateClosed IS NOT NULL THEN IncidentDisbmtAmountRequested - IncidentDisbmtAmountPaid
		ELSE 0
	END AS "Disbursement Amount Prevented" ,
	CASE
		WHEN CaseDisposition IN ('Fraud', 'Fraud Missed', 'Inconclusive - Suspected Fraud' )
		AND DateClosed IS NOT NULL THEN 1
		ELSE 0
	END AS "Fraud Case Indicator" ,
	CASE
		WHEN CaseDisposition IN ('Fraud', 'Inconclusive - Suspected Fraud' )
		AND (IncidentDisbmtAmountPaid = 0
		OR IncidentDisbmtAmountPaid IS NULL)
		AND DateClosed IS NOT NULL THEN 1
		ELSE 0
	END AS "Fraud Prevented Indicator" ,
	CASE
		WHEN CaseDisposition IN ('Fraud', 'Fraud Missed', 'Inconclusive - Suspected Fraud' )
		AND IncidentDisbmtAmountRequested > 0
		AND DateClosed IS NOT NULL THEN 1
		ELSE 0
	END AS "Disbursement Requested Ind" ,
	CASE
		WHEN CaseDisposition IN ('Fraud', 'Fraud Missed', 'Inconclusive - Suspected Fraud' )
		AND (IncidentDisbmtAmountRequested > 0
		AND IncidentDisbmtAmountPaid = 0)
		AND DateClosed IS NOT NULL THEN 1
		ELSE 0
	END AS "Disbursement Prevented Ind" ,
	CASE
		WHEN CaseDisposition IN ('Fraud', 'Fraud Missed', 'Inconclusive - Suspected Fraud' )
		AND IncidentDisbmtAmountPaid > 0
		AND DateClosed IS NOT NULL THEN 1
		ELSE 0
	END AS "Disbursement Not Prevented Ind" ,
    Trans_dt AS TransDate
FROM
--  PROD_DMA_VW.ARCHER_CASE_DETAIL_VW
	dma_vw.archer_case_detail_vw
WHERE
  DateClosed <= Current_Date
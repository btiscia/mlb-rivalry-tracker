/*
Name: Fraud Operations Archer Details SQL Extract
Author/Editor: John Avgoustakis/Kristin Carlile
Last Updated: 10/19/2020
Comments: Added new fields.

Editor: Christina Valenti
Last Updated:  12/11/2020
Comments: Added case statement for product line,, removed penetration level
and added join to archer_case_detail_vw to reset Business Area (case statement
in view code is not correct and cannot be changed at this time due to code freeze)
Business area logic should eventually be removed from here and re-done in 
the view 

*/

SELECT DISTINCT

 acv.AlertID AS "Alert ID"
,acv.OpenedByMMID AS "MM ID"
,acv.OpenedByName AS "Employee"
,acv.Status
,acv.AlertOriginCategory AS "Alert Origin Category"
,acv.AlertOrigin AS "Alert Origin"
,acv.AlertDateReceived AS "Received Date"
,acv.DateClosed AS "Closed Date"
,acv.ReferralReasonCategory AS "Reason for Referral Category"
,acv.ReferralReason AS "Reason for Referral"
,acv.ReferringArea AS "Referring Area"
,acv.ReferrerMMID AS "Referrer MMID"
,acv.ReferrerName AS "Referrer Employee"
,acv.ThreatActor AS "Threat Actor"
,acv.AccessChannel AS "Access Channel"
,CASE 
	WHEN acv.AccessChannel LIKE '%;%' THEN  'Multiple'
	WHEN acv.AccessChannel IS NULL THEN  'Unknown'
	ELSE acv.AccessChannel 
END AS "Access Channel Grouping"
--,PenetrationLevel AS "Penetration Level"  removed 12/14/2020
,acv.IncidentTransactionCategory AS "Incident Transaction Category" --added the wording category
,acv.IncidentDisbmtAmountRequested AS "Disbursement Amount Requested"
,acv.IncidentDisbmtAmountPaid AS "Disbursement Amount Paid"
--,IncidentDisbmtAmountPrevented AS "Disbursement Amount Prevented"
--,ProductType AS "Alert Product Line" --check if you are using this and change to product type

--,ProductLine AS "Product Line" --replaced with below case statement on 12/14/2020
--taking product type from details view because case view sets it to other when prod line is null
--this logic should eventually move to the view.
,CASE WHEN acv.ProductLine IS NULL THEN acdv.ProductType 
   ELSE acv.ProductLine 
 END AS "Product Line"

,acv.IncidentTransaction AS "Incident Transaction"	

--,acv.BusinessArea AS "Business Area"  replaced with below case statement on 12/14/2020
,CASE WHEN acv.ProductType = 'MULTIPLE' THEN 'MULTIPLE'
  WHEN acv.ProductType IS NULL AND acv.ProductLine = 'MULTIPLE'  THEN 'MULTIPLE'
  WHEN acdv.ProductType = 'Insurance Products' AND acdv.ProductLine NOT LIKE ALL ('%Coverpath%', '%Haven%') THEN 'Insurance'
  WHEN acdv.ProductType = 'Wealth Management / Investment Products' THEN 'MMLIS'
  WHEN acdv.ProductType = 'Retirement Products' THEN 'Workplace'
   ELSE 'Other'
 END AS "Business Area"

,acv.IncidentAccountValue AS "Account Value"
,acv.IncidentAccountResidence AS "Owner Resident State"
,acv.CaseReferralGroup AS "Referred To Group"
,acv.CaseDisposition AS "Case Disposition"
,acv.ControlEffectiveness AS "Control Effectiveness"
,acv.Taxonomy AS Taxonomy

,CASE
	WHEN acv.CaseDisposition IN ('Fraud', 'Fraud Missed', 'Inconclusive - Suspected Fraud' )
		        	AND acv.DateClosed IS NOT NULL THEN 1 ELSE 0
END AS "Fraud Case Indicator"

,CASE
	WHEN acv.CaseDisposition IN ('Fraud', 'Inconclusive - Suspected Fraud' ) 
					AND (acv.IncidentDisbmtAmountPaid = 0 OR acv.IncidentDisbmtAmountPaid IS NULL)
					AND acv.DateClosed IS NOT NULL THEN 1 ELSE 0
END AS "Fraud Prevented Indicator"

,CASE
	WHEN acv.CaseDisposition IN ('Fraud', 'Fraud Missed', 'Inconclusive - Suspected Fraud' ) 
					AND acv.IncidentDisbmtAmountRequested > 0
					AND acv.DateClosed IS NOT NULL THEN 1 ELSE 0
END AS "Disbursement Requested Ind"

,CASE
	WHEN acv.CaseDisposition IN ('Fraud', 'Fraud Missed', 'Inconclusive - Suspected Fraud' ) 
					AND  (acv.IncidentDisbmtAmountRequested > 0 AND acv.IncidentDisbmtAmountPaid = 0)
					AND acv.DateClosed IS NOT NULL THEN 1 ELSE 0
END AS "Disbursement Prevented Ind"

,CASE
	WHEN acv.CaseDisposition IN ('Fraud', 'Fraud Missed', 'Inconclusive - Suspected Fraud' ) 
					AND acv.IncidentDisbmtAmountPaid > 0 
					AND acv.DateClosed IS NOT NULL THEN 1 ELSE 0
END AS "Disbursement Not Prevented Ind"

,CASE 
	WHEN acv.IncidentDisbmtAmountPaid <= acv.IncidentDisbmtAmountRequested
				AND acv.DateClosed IS NOT NULL
		THEN acv.IncidentDisbmtAmountRequested - acv.IncidentDisbmtAmountPaid ELSE 0 
END AS "Disbursement Amount Prevented"

,acv.TransDate


FROM	 PROD_DMA_VW.ARCHER_CASE_VW AS acv
--added join on 12/14/2020 in order to re-do Business Area logic
--business area logic should eventually be removed from here and re-done in 
--the view 
LEFT JOIN PROD_DMA_VW.ARCHER_CASE_DETAIL_VW AS acdv
ON acv.alertid = acdv.alertid

WHERE acv.DateClosed  <= CURRENT_DATE
AND acv.FraudCaseIndicator = 1
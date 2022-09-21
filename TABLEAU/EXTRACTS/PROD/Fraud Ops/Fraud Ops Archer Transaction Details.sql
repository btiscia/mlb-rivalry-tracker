/*
Name: Fraud Ops Archer Transaction Details
Editor: Christina Valenti
Updated:  5/20/2022
Comments: Repointed to Vertica
*/
SELECT
	"AlertID" AS "Alert ID" ,
	"OpenedByMMID" AS "Opened By MMID" ,
	"OpenedByName" AS "Opened By" ,
	"DateClosed" AS "Date Closed" ,
	"CaseHandleTime" AS "Handle Time" ,
	"AlertOrigin" AS "Alert Origin" ,
	"AlertOriginCategory" AS "Alert Category" ,
	"CaseDisposition" AS "Case Disposition" ,
	"FraudCaseIndicator" AS "Fraud Case Indicator" ,
	"FollowUpIndicator" AS "Follow Up Indicator" ,
	"BusinessArea" AS "Business Area" ,
	"TransDate"
FROM
-- "PROD_DMA_VW"."ARCHER_TRANSACTION_VW"
	dma_vw.archer_transaction_vw
WHERE
	DateClosed <= CURRENT_DATE
/*
* This routine pulls  IR data for ANB BINGO dashboard.
*  Based on contracts.  Contracts are distinct agrrement IDs.  
*  Peer Review & Change Log:
*  Peer Review Date: 
*  Source for this routine is  PROD_DMA_VW.ANB_IR_NIGO_REASON_TOKEN_VW, PROD_DMA_VW.ANB_APPLICATION_RPT_VW
*  PROD_DMA_VW.FIRM_DIM_VW, PROD_USIG_CMN_VW.PRODUCT_TRANSLATOR_VW
*  PROD_DMA_VW.ANB_IR_MARKET_TYPES_VW,PROD_DMA_VW.ANB_IR_QUESTIONS_VW
*  Author: Zach Dorval, Lorraine Christian and Bill Trombley
*  Created: 2/4/2021
*  Revisions:  
====================================================================== 
======================================================================
                
======================================================================*/
SELECT DISTINCT
	PolicyNumber
	, T1.InitialReviewID
	, T1.OrderEntryID
	, AgreementID
	,Channel
	, CASE WHEN Distributor = 'SDP' THEN 'MMSD' ELSE Distributor END AS Distributor
	, Product
	, T1.ProductCategory
	, RegionName
	, T3.StateCode AS ResidenceState
	, FirmNum
	, FirmName
	, T3.AgentID
	, Advisor
	, MarketTypeCode
	, MarketTypeCategory
	, NIGOReason
	, NIGOCategory
	, CASE WHEN T2.REJECTDATE IS NOT NULL THEN 'Rejected'
			WHEN CANCELDATE IS NOT NULL THEN 'Canceled'
			WHEN APPROVEDDATE IS NOT NULL THEN 'Approved'
  		ELSE NULL END AS FinalDisposition
	, ApplicationSubmitDate
	, NewBusinessSubmitDate
	, SuitabilityApprovalDate
	, PAWDate
	, TOADate
	, T2.RejectDate
	, CancelDate
	, ApprovedDate
	, CAST(CreatedAtDateTimeStamp AS DATE) IRNIGODate
	,BINGOIndicator

	, CASE WHEN NIGOREASON IS NULL THEN SUITABILITYAPPROVALDATE
			WHEN T1.PRODUCTCATEGORY = 'Variable Annuity' THEN CAST(COALESCE( PAWDATE, TOADATE) AS DATE)
  		ELSE CAST(COALESCE(T2.REJECTDATE, CANCELDATE, APPROVEDDATE, PAWDATE, TOADATE, ISSUEDATE) AS DATE) END AS IRBINGODate
	, (IRBINGODate - IRNIGODate) IRNIGOResolution

FROM PROD_DMA_VW.ANB_APPLICATION_RPT_VW T1

LEFT JOIN PROD_DMA_VW.IPIPELINE_ORDER_FCT_VW T2 ON T2.ORDERENTRYID = T1.ORDERENTRYID
LEFT JOIN PROD_DMA_VW.ANB_IR_NIGO_REASON_TOKEN_VW T3 ON T3.INITIALREVIEWID = T1.INITIALREVIEWID
WHERE T1.INITIALREVIEWID IS NOT NULL

QUALIFY ROW_NUMBER() OVER(PARTITION BY T1.INITIALREVIEWID, NIGOREASON ORDER BY CREATEDATDATETIMESTAMP) = 1
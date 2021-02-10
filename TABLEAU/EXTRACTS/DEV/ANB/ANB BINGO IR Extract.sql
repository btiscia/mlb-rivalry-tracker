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
ApplicationID
, CASE WHEN BingoDate IS NULL THEN 0 ELSE 1 END AS BINGOIndicator
, DISTRIBUTOR AS Distributor
, Channel
, Firm
, Product Category
---No doc type for IR (from LC)
--<<<<<<< HEAD  (This from zach)
----NEED NIGO Category  -- will be there after release next week.  Week ending  2/12
--=======
-- Product Category to be added in Release next week
----NEED NIGO Category
-->>>>>>> 520ff11cc078e7a577c08ac8090cce961503225f
, NIGOReason  
, Product
, ProductCategory

, StateCode
, IRMarketTypeName
, SuitabilityIndicator
, IGOIndicator
, DISTRIBUTOR
, T1.AgentID
, T1.AGENTID
, T1.AGENCYNUMBER AS FIRMNUM
, T2.FirmName
, RegionName
, SUITABILITYAPPROVALDATE
, PAWDATE
, TOADATE
, NEWBUSINESSSUBMITDATE
, CASE WHEN CAST(ISSUEDATE AS DATE) = '0001-01-01' THEN NULL ELSE ISSUEDATE END AS ISSUEDATE
, CAST(T1.CreatedAtDateTimestamp AS DATE) IRNIGODATE
, CAST(CASE WHEN PRODUCTCATEGORY LIKE 'VARIABLE%' THEN COALESCE(PAWDATE,ISSUEDATE)  ELSE COALESCE(NEWBUSINESSSUBMITDATE, ISSUEDATE) END AS DATE) IRBINGODATE
, (IRBINGODATE - IRNIGODATE) NIGOResolution
FROM	PROD_DMA_VW.ANB_IR_NIGO_REASON_TOKEN_VW T1
INNER JOIN PROD_DMA_VW.ANB_APPLICATION_RPT_VW T2 ON T2.INITIALREVIEWID = T1.INITIALREVIEWID
LEFT JOIN PROD_DMA_VW.FIRM_DIM_VW T3 ON T1.AGENCYNUMBER = T3.ORIGINALFIRMNUMBER
LEFT JOIN PROD_USIG_CMN_VW.PRODUCT_TRANSLATOR_VW T4 ON CAST(T4.PROD_ID AS INTEGER)= T1.IRPRODUCTID
LEFT JOIN PROD_DMA_VW.ANB_IR_MARKET_TYPES_VW T5 ON T5.IRMARKETTYPEID = T1.IRMARKETTYPEID
LEFT JOIN PROD_DMA_VW.ANB_IR_QUESTIONS_VW T6 ON T6.QUESTIONNAME = T1.NIGOREASON
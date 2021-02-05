/*
* This routine pulls  initial reviews for ANB BINGO dashboard.
*  Based on cases.  Cases are distinct applications IDs.  .
*  Peer Review & Change Log:
*  Peer Review Date: 
*  Source for this routine is  PROD_DMA_VW_ACT_ANO_CURR_INTEGRATED_FCT_VW
*  Author: Zach Dorval, Lorraine Christian and Bill Trombley
*  Created: 2/4/2021
*  Revisions:  
*  Notes:  IR will not have "doc type" like SE2.  
====================================================================== 
======================================================================
                
======================================================================*/

SELECT DISTINCT
ApplicationID
, CASE WHEN BingoDate IS Null THEN 0 else 1 end as BINGOIndicator
, DISTRIBUTOR AS Distributor
, Channel
, Firm
---No doc type for IR
, Product Category
----NEED NIGO Category
, NIGOReason  

, Product
, StateCode
, IRMarketTypeName
, SuitabilityIndicator
, IGOIndicator
, DISTRIBUTOR
, T1.AgentID
, T1.AGENTID
, T1.AGENCYNUMBER AS FIRMNUM
, T2.FirmName
,  RegionName
, NEWBUSINESSSUBMITDATE
, ISSUEDATE
, CAST(T1.CreatedAtDateTimestamp AS DATE) NIGODATE
, CAST(ISSUEDATE AS DATE) BINGODATE
, (BINGODATE - NIGODATE) NIGOResolution
FROM	PROD_DMA_VW.ANB_IR_NIGO_REASON_TOKEN_VW T1
INNER JOIN PROD_DMA_VW.ANB_APPLICATION_RPT_VW T2 ON T2.INITIALREVIEWID = T1.INITIALREVIEWID
LEFT JOIN PROD_DMA_VW.FIRM_DIM_VW T3 ON T1.AGENCYNUMBER = T3.ORIGINALFIRMNUMBER
LEFT JOIN PROD_USIG_CMN_VW.PRODUCT_TRANSLATOR_VW T4 ON CAST(T4.PROD_ID AS INTEGER)= T1.IRPRODUCTID
LEFT JOIN PROD_DMA_VW.ANB_IR_MARKET_TYPES_VW T5 ON T5.IRMARKETTYPEID = T1.IRMARKETTYPEID
LEFT JOIN PROD_DMA_VW.ANB_IR_QUESTIONS_VW T6 ON T6.QUESTIONNAME = T1.NIGOREASON



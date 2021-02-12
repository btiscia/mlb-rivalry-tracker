/*
* This routine pulls  SE2 data for ANB BINGO dashboard.
*  Based on contracts.  Contracts are  distinct application IDs
*  Peer Review & Change Log:
*  Peer Review Date: 
*  Source for this routine is  PROD_DMA_VW.ANB_APPLICATION_RPT_VW ,  PROD_DMA_VW.ANB_NIGO_FCT_VW
*  Author: Zach Dorval, Lorraine Christian and Bill Trombley
*  Created: 2/4/2021
*  Revisions:  
====================================================================== 
======================================================================
                
======================================================================*/

SELECT DISTINCT
T1.AGREEMENTID
, PolicyNumber
, T1.OrderEntryID
, Distributor
, Channel
, DocumentTypeCode AS "Doc Type"
, Product
, ProductCategory
, ResidenceState
, AgentID
, Advisor
, FirmNum
, FirmName
, RegionName
, PAWDate
, TOADate
, NewBusinessSubmitDate
, SuitabilityApprovalDate
, RejectDate
, WithdrawnDate
, IssueDate
, NIGOCategory AS "NIGO Category"
, ReasonDescription AS "NIGO Reason"
, NIGODate
, NIGOResolvedDate
, BINGOIndicator
, (NIGOResolvedDate - NIGODate) NIGOResolution
, CASE WHEN RejectDate IS NOT NULL THEN 'Rejected'
			WHEN WithdrawnDate IS NOT NULL THEN 'Withdrawn'
			WHEN IssueDate IS NOT NULL THEN 'Issued'
  ELSE NULL END AS FinalDisposition

FROM PROD_DMA_VW.ANB_APPLICATION_RPT_VW T1

LEFT JOIN (SELECT DISTINCT AGREEMENTID
							, ORDERENTRYID
							, CAST(MIN(NIGODate) OVER (PARTITION BY AGREEMENTID) AS DATE) AS NIGODate
							, MAX(NIGOResolutionDate) OVER (PARTITION  BY AGREEMENTID) AS NIGOResolvedDate
							, T2.NIGOCategory
							, ReasonDescription
							, DocumentTypeCode
						FROM PROD_DMA_VW.ANB_NIGO_FCT_VW T1
						INNER JOIN PROD_DMA_VW.ANN_NIGO_REASON_LOV_VW T2 ON T2.NIGOUUID = T1.NIGOUUID
						WHERE T1.SYSTEMID = 34
						AND GROUPTYPE LIKE 'NEW B%') T2 ON COALESCE(T1.AGREEMENTID, T1.ORDERENTRYID) = COALESCE(T2.AGREEMENTID, T2.ORDERENTRYID)
		
WHERE  T1.ORIGINALORDERSUBMITDATE >= CURRENT_DATE - INTERVAL '1' MONTH 



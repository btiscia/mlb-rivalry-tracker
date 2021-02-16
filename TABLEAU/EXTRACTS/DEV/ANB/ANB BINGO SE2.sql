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
	PolicyNumber
	, T1.AGREEMENTID
	, T1.OrderEntryID
	, Channel
	, CASE WHEN Distributor = 'SDP' THEN 'MMSD' ELSE Distributor END AS Distributor
	, Product
	, ProductCategory
	, RegionName
	, ResidenceState
	, FirmNum
	, FirmName
	, AgentID
	, Advisor
	, DocumentTypeCode AS "Doc Type"
	,COALESCE(T1.AGREEMENTID, T1.POLICYNUMBER, T1.ORDERENTRYID) NIGOID
	, NIGOCategory AS "NIGO Category"
	, ReasonDescription AS "NIGO Reason"
	, CASE WHEN RejectDate IS NOT NULL THEN 'Rejecte'
			WHEN WithdrawnDate IS NOT NULL THEN 'Withdrawn'
			WHEN IssueDate IS NOT NULL THEN 'Issued'
  		ELSE NULL END AS FinalDisposition
	, NewBusinessSubmitDate
	, PAWDate
	, TOADate
	, SuitabilityApprovalDate
	, RejectDate
	, WithdrawnDate
	, IssueDate
	, NIGODate SE2NIGODate
	, NIGOResolvedDate
	, BINGOIndicator
	, (NIGOResolvedDate - NIGODate) SE2NIGOResolution


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
                        AND GROUPTYPE LIKE 'NEW B%'
                        AND NIGODATE >= '2019-01-01') T2 ON COALESCE(T1.AGREEMENTID, T1.ORDERENTRYID) = COALESCE(T2.AGREEMENTID, T2.ORDERENTRYID)
		


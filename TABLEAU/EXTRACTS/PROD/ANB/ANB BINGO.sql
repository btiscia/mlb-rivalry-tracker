-- SELECT DISTINCT DISTRIBUTOR
-- , CHANNEL
-- , PRODUCT
-- , T1.AGREEMENTID
-- , PolicyNumber
-- , T1.ORDERENTRYID
-- , RESIDENCESTATE
-- , T1.AGENTID
-- , T1.AGENCYNUMBER
-- , T1.Firm
-- , T1.FirmNum
-- , FirmName
-- , RegionName
-- , Product Category
-- , T1.ISSUEDATE
-- , NIGODATE
-- , T1.NEWBUSINESSSUBMITDATE
-- , SUITABILITYSUBMITDATE
-- , BINGODATE
-- , BINGOSTATUS
-- , BINGOINDICATOR
-- , (BINGODATE - NIGODATE) NIGOResolution
-- , NIGOCATEGORY
-- , NIGODESCRIPTION
-- , DocumentTypeCode
-- FROM PROD_DMA_VW.ANB_APPLICATION_RPT_VW T1
-- 
-- LEFT JOIN (SELECT DISTINCT AGREEMENTID
-- 							, CAST(MIN(NIGODate) OVER (PARTITION BY AGREEMENTID) AS DATE) AS NIGODate
-- 							, MAX(NIGOResolutionDate) OVER (PARTITION  BY AGREEMENTID) AS NIGOResolvedDate
-- 							, T2.NIGODESCRIPTION
-- 							, NIGOCategory
-- 							, ReasonDescription
-- 							, DocumentTypeCode
-- 						FROM PROD_DMA_VW.ANB_NIGO_FCT_VW T1
-- 						INNER JOIN PROD_DMA_VW.ANN_NIGO_REASON_LOV_VW T2 ON T2.NIGOUUID = T1.NIGOUUID
-- 						WHERE T1.SYSTEMID = 34
-- 						AND GROUPTYPE LIKE 'NEW B%') T10 ON T1.AGREEMENTID = T10.AGREEMENTID
-- 
-- WHERE  T1.ORIGINALORDERSUBMITDATE >= CURRENT_DATE - INTERVAL '1' YEAR -- CHANGE THE INTERVAL AS YOU SEE FIT ;


--INITIAL REVIEW BINGO

SELECT DISTINCT T2.dim_agreement_natural_key_hash_uuid
, T1.state_id
, T5.name AS market_type_nm
, T1.suitability_ind
, T1.igo_ind
, T2.distributor
, T2.product
, T2.product_category
, T2.agent_id
, T2.agency_num
, T2.firm_num AS FIRMNUM
, T2.firm_nm
, T2.channel
, T2.nb_submit_dt
, T2.issue_dt
, T1.nigo_reason
, CAST(T1.created_at AS DATE) nigo_dt
, CAST(T2.issue_dt AS DATE) bingo_dt
, (CAST(T2.issue_dt AS DATE) - CAST(T1.created_at AS DATE)) nigo_resolution
FROM dma_vw.bibt_ir_initial_reviews_token_vw T1
LEFT JOIN dma_vw.sem_dim_anb_application_curr_vw T2 ON T2.initial_review_id = T1.initial_review_id
LEFT JOIN dma.dma_dim_firm_curr T3 ON TRIM(LEADING '0' FROM T1.agency_num) = TRIM(LEADING '0' FROM T3.agency_id)
LEFT JOIN edw_vw.product_translator_current_vw T4 ON CAST(T4.prod_id AS INTEGER)= T1.ir_product_id
LEFT JOIN dma.bibt_ref_ir_market_types T5 ON T5.market_type_id = T1.ir_market_type_id
-- LEFT JOIN dma.bibt_rel_ir_questions T6 ON lower(T6.name) = lower(T1.nigo_reason)
WHERE T2.initial_review_id IS NOT NULL


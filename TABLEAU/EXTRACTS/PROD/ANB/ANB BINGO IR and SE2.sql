/*
FILENAME: ANNUITY NEW BUSINESS IR AND SE2
UPDATED BY: John Avgoustakis, Vince Bonaddio
LAST UPDATED: 05/19/2023
CHANGES MADE: 
08/24/2022 - Vertica Migration
05/19/2023 - added manager and team name field - change made by Bill Tiscia
*/
SELECT
 'IR' AS BINGOType
, T1.policy_num AS "PolicyNumber"
, T1.dim_agreement_natural_key_hash_uuid AS "AgreementID"
, T1.order_entry_id AS "OrderEntryID"
, T1.initial_review_id AS "InitialReviewID"
, T1.channel AS "Channel"
, CASE WHEN UPPER(T1.distributor) = 'SDP' THEN 'MMSD' ELSE T1.distributor END AS "Distributor"
, T1.distributor as "Distributor2"
, T1.product AS "Product"
, T1.product_category AS "ProductCategory"
, T1.resident_state_cde AS ResidenceState
, T1.agency_num as "FirmNum"
, CASE WHEN T1.agency_num is NULL and T1.firm_nm is NULL then '999 - Unknown' ELSE T1.firm_nm END AS "FirmName"
, CAST(T1.agent_id AS VARCHAR(10)) AS "AgentID"
, T1.advisor_nm AS "Advisor"
, T1.doc_type_nm AS "DocType"
, T1.market_category_type_cde AS "MarketTypeCode"
, T1.market_type_category AS "MarketTypeCategory"
, T3.category AS "NIGOCategory"
, T3.nigo_reason AS "NIGOReason"
, T1.nb_submit_dt AS "NewBusinessSubmitDate"
, T1.application_submit_dt AS "ApplicationSubmitDate"
, T1.suitability_approved_dt AS "SuitabilityApprovalDate"
, T1.paw_dt AS "PAWDate"
, T1.toa_dt AS "TOADate"
, T2.reject_dt AS "RejectDate"
, T2.cancel_dt AS "CancelDate"
, T2.approved_dt AS "ApprovedDate"
, T5.nigo_dt AS "IRNIGODate"
, CASE WHEN T3.nigo_reason IS NULL THEN T1.suitability_approved_dt ELSE CAST(COALESCE(T2.reject_dt, T2.cancel_dt, T5.bingo_dt) AS DATE) END AS "IRBINGODate"
, T4.igo_ind::INT AS "BINGOIndicator"
, (IRBINGODate::date - T5.nigo_dt::date) AS "NIGOResolution"
, T1.final_disposition AS "FinalDisposition"
, T1.final_disposition_dt
, T1.row_process_dtm AS "TransDate"
, ((T6.manager_last_nm || ', '::varchar(2)) || T6.manager_first_nm)   AS "Manager"
, T6.team_nm AS "TeamName"
FROM dma_vw.sem_dim_anb_application_curr_vw T1
LEFT JOIN dma_vw.sem_anb_ipipeline_vw T2 ON T2.order_entry_id = T1.order_entry_id
LEFT JOIN dma_vw.bibt_ir_initial_reviews_token_vw T3 ON T3.initial_review_id = T1.initial_review_id
INNER JOIN dma_vw.bibt_rel_initial_reviews_vw T4 ON T4.initial_review_id = T1.initial_review_id
LEFT JOIN(SELECT dim_agreement_natural_key_hash_uuid
                , MIN(nigo_dt) AS nigo_dt
                , MAX(nigo_res_dt) As bingo_dt
          FROM dma_vw.anb_dim_nigo_vw
          WHERE source_system_id = 35
          GROUP BY dim_agreement_natural_key_hash_uuid) T5 ON T1.dim_agreement_natural_key_hash_uuid = T5.dim_agreement_natural_key_hash_uuid
LEFT JOIN dma_vw.sem_fact_anb_suit_activity_vw T6 ON T1.dim_agreement_natural_key_hash_uuid = T6.dim_agreement_natural_key_hash_uuid
WHERE EXTRACT(YEAR FROM T1.final_disposition_dt) >= EXTRACT(YEAR FROM CURRENT_DATE) - 2
LIMIT 1 OVER(PARTITION BY T1.initial_review_id, T3.nigo_reason ORDER BY T4.updated_at DESC)
/*
Name: ANB Suitability Details
Author/Editor: Vince Bonaddio / Bill Trombley
Comments: Converted to Vertica
-- Applications are the process from Original Order Submit Date - Anywhere into the Issue Process
-- Contract is New Business Submit Forward
*/

SELECT T1.original_order_id AS 'Original Order ID'
    , T1.order_entry_id AS 'Order Entry ID'
    , T1.copied_from_trans_id AS 'Parent Order ID'
    , CASE WHEN parent_cancel_dt IS NOT NULL THEN COALESCE(T1.original_order_submit_dt, electronic_submit_dt)
        ELSE electronic_submit_dt END AS "Suitability Submit Date"
    , T1.electronic_submit_dt AS 'Electronic Submit Date'
    , T1.cancel_rework_dt AS 'Cancel Rework Date'
    , T1.suit_comp_dt_transmit AS 'Transmit Date'
    , T1.approved_dt
    , T1.reject_dt AS 'Reject Date'
    , T1.cancel_dt AS 'Cancel Date'
    , T1.final_disposition AS 'Final Disposition'
    , T1.final_disposition_dt as "Final Disposition Date"
    , CAST(final_disposition_dt AS DATE) - CAST("Suitability Submit Date" AS DATE) AS 'Suitability Cycle Time'
    , CAST(T2.cas_ind AS INTEGER) AS 'cas_ind'
    , COALESCE(T3.distributor,'Unknown') AS 'Distributor'
    , COALESCE(T3.channel,'MMFA') AS 'Channel'
    , T1.product AS 'Product Name'
    , T1.product_category AS 'Product Category'
    , T2.business_partner_id AS 'Agent ID'
    , T2.last_nm || ', ' || T2.first_nm AS 'Advisor'
    , T3.agency_id_prefix AS 'Firm'
    , T3.firm_num_annuity AS 'Firm Number'
    , COALESCE(T3.firm_display_nm,'999 - Unknown') AS 'Firm Name'
    , T4.agreement_nr AS 'Agreement Number'
    , CAST(T1.auto_approved_ind AS INTEGER) AS 'Auto Approved Indicator'
    , T1.parent_cancel_dt AS 'Parent Cancel Rework Date'
    , CASE WHEN T1.parent_cancel_dt IS NOT NULL THEN 1 ELSE 0 END AS 'Resubmit Indicator'
    , CAST(T1.electronic_submit_dt AS DATE) - CAST(T1.parent_cancel_dt AS DATE) AS 'Resubmit Lag Time'
    , T5.doc_type_nm AS 'NB Doc Type'
    , CAST(T1.suit_comp_dt_transmit AS DATE) - CAST(T1.electronic_submit_dt AS DATE) AS 'Initial Review Cycle Time'
    , CAST(T6.suitability_ind AS INTEGER) AS 'IGO Indicator'
    , T1.row_process_dtm AS 'TransDate'
FROM dma_vw.sem_anb_ipipeline_vw T1
LEFT JOIN edw_semantic_vw.sem_producer_demographics_current_vw T2 ON TRIM(LEADING '0' FROM T1.agent_id) = TRIM(LEADING '0' FROM T2.business_partner_id)
LEFT JOIN dma_vw.dma_dim_firm_curr_vw T3 ON TRIM(LEADING '0' FROM T1.agency_num) = TRIM(LEADING '0' FROM T3.agency_id)
LEFT JOIN edw_semantic_vw.sem_agreement_current_vw T4 ON T1.dim_agreement_natural_key_hash_uuid = T4.dim_agreement_natural_key_hash_uuid
LEFT JOIN dma_vw.anb_doc_type_vw T5 ON T1.dim_agreement_natural_key_hash_uuid = T5.dim_agreement_natural_key_hash_uuid
LEFT JOIN dma_vw.bibt_rel_initial_reviews_vw T6 ON T1.order_entry_id = T6.application_id
WHERE T1.electronic_submit_dt >= '2019-07-01'
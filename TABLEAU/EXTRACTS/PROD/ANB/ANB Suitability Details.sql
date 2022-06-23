SELECT T1.original_order_id
    , T1.order_entry_id
    , T1.copied_from_trans_id AS parent_order_id
    , CASE WHEN parent_cancel_dt IS NOT NULL THEN COALESCE(T1.original_order_submit_dt,T1.electronic_submit_dt)
        ELSE T1.electronic_submit_dt END AS suitability_submit_dt
    , T1.electronic_submit_dt AS pend_dt
    , CASE WHEN lower(app_status) LIKE 'cancel/rework' THEN T1.app_status_change_dt END AS cancel_rework_dt
    , T1.suit_comp_dt_transmit AS transmit_dt
    , CASE WHEN app_status = 'Fully Approved' THEN T1.app_status_change_dt END AS approved_dt
    , CASE WHEN app_status = 'Cancel/Reject' THEN T1.app_status_change_dt END AS reject_dt
    , CASE WHEN app_status = 'Cancelled' THEN T1.app_status_change_dt END AS cancel_dt
    , CASE WHEN app_status = 'Fully Approved' OR T1.suit_comp_dt_transmit IS NOT NULL THEN 'Approved'
        WHEN app_status = 'Cancel/Reject' THEN 'Rejected'
        WHEN app_status = 'Cancelled' THEN 'Cancelled' END AS final_disposition
    , COALESCE(T1.suit_comp_dt_transmit,CASE WHEN app_status IN ('Fully Approved','Cancel/Reject','Cancelled') THEN T1.app_status_change_dt END) AS final_disposition_dt
    , CAST("final_disposition_dt" AS DATE) - CAST("suitability_submit_dt" AS DATE) AS suitability_cycle_time
    , T2.cas_ind
    , COALESCE(T3.distributor,'Unknown')
    , COALESCE(T3.channel,'MMFA')
    , T1.product_nm
    , CASE WHEN T1.product_nm LIKE ('%Capital Vantage%') THEN 'Capital Vantage'
   		WHEN T1.product_nm LIKE ('%Transitions Select%') THEN 'Transition Select'
  		WHEN T1.product_nm LIKE ('%RetireEase Choice%') THEN 'RetireEase Choice'
   		WHEN T1.product_nm LIKE ('%RetireEase%') THEN 'RetireEase'
   		WHEN T1.product_nm LIKE ('%Stable Voyage%') THEN 'Stable Voyage'
   		WHEN T1.product_nm LIKE ('%Odyssey Select%') THEN 'Odyssey Select'
   		WHEN T1.product_nm LIKE ('%Index Horizons%') THEN 'Index Horizons'
   		WHEN T1.product_nm LIKE ('%Envision%') THEN 'Envision'
        ELSE 'Unknown' END AS product_nm
    , COALESCE(CASE WHEN T1.product_nm LIKE '%RetireEase%' THEN 'Income Annuity'
                        WHEN T1.product_nm LIKE '%Index Horizons%' THEN 'Fixed Indexed' END,T1.product_type) AS "Product Category"
    , T2.business_partner_id
    , T2.last_nm || ', ' || T2.first_nm AS advisor_nm
    , T3.agency_id_prefix AS firm
    , T3.firm_num_annuity
    , COALESCE(T3.firm_display_nm,'999 - Unknown') AS firm_nm
    , T4.agreement_nr
    , T1.auto_approved_ind
    , T1.parent_cancel_dt
    , CASE WHEN T1.parent_cancel_dt IS NOT NULL THEN 1 ELSE 0 END AS resubmit_ind
    , CAST(T1.electronic_submit_dt AS DATE) - CAST(T1.parent_cancel_dt AS DATE) AS resubmit_lag_tm
    , T5.doc_type_nm
    , CAST(T1.suit_comp_dt_transmit AS DATE) - CAST(T1.electronic_submit_dt AS DATE) AS initial_review_cycle_time
    , T1.row_process_dtm
FROM dma.dim_ipipeline_orders_curr T1
LEFT JOIN edw_semantic_vw.sem_producer_demographics_current_vw T2 ON TRIM(LEADING '0' FROM T1.agent_id) = TRIM(LEADING '0' FROM T2.business_partner_id)
LEFT JOIN dma.dma_dim_firm_curr T3 ON TRIM(LEADING '0' FROM T1.agency_num) = TRIM(LEADING '0' FROM T3.agency_id)
LEFT JOIN edw_semantic_vw.sem_agreement_current_vw T4 ON T1.dim_agreement_natural_key_hash_uuid = T4.dim_agreement_natural_key_hash_uuid
LEFT JOIN dma.anb_doc_type T5 ON T1.dim_agreement_natural_key_hash_uuid = T5.dim_agreement_natural_key_hash_uuid
WHERE T1.electronic_submit_dt >= '2019-07-01'
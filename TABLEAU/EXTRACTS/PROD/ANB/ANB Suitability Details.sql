SELECT T1.original_order_id
, T1.order_entry_id  --Case Level
, T1.copied_from_trans_id
, CASE WHEN parent_cancel_dt IS NOT NULL THEN COALESCE(T1.original_order_submit_dt, T1.electronic_submit_dt)
    ELSE T1.electronic_submit_dt END AS suitability_submit_dt
, T1.electronic_submit_dt
, T1.suit_comp_dt_transmit AS transmit_dt
, MAX(CASE WHEN lower(T1.app_status) = 'cancel/rework' THEN T1.app_status_change_dt END) OVER (PARTITION BY T1.order_entry_id) AS cancel_rework_dt
, MAX(CASE WHEN lower(T1.app_status) = 'approved' THEN T1.app_status_change_dt END) OVER (PARTITION BY T1.order_entry_id) AS "approved_dt"
, MAX(CASE WHEN lower(T1.app_status) = 'cancel/reject' THEN T1.app_status_change_dt END) OVER (PARTITION BY T1.order_entry_id) AS reject_dt
, MAX(CASE WHEN lower(T1.app_status) = 'cancelled' THEN T1.app_status_change_dt END) OVER (PARTITION BY T1.order_entry_id) AS cancel_dt
, CASE WHEN lower(T1.app_status) IN ('approved','cancelled') THEN T1.app_status
    WHEN lower(T1.app_status) = 'cancel/reject' THEN 'Rejected' END AS final_disposition --Final Disposition --Suitability Volume is based on a count of final disposition
, COALESCE(T1.suit_comp_dt_transmit, CASE WHEN lower(T1.app_status) IN ('approved','cancelled','cancel/reject') THEN T1.app_status_change_dt END)  AS final_disposition_dt
, CAST((CASE WHEN lower(T1.app_status) IN ('approved','cancelled','cancel/reject') THEN T1.app_status_change_dt END) AS DATE) -
    CAST((CASE WHEN parent_cancel_dt IS NOT NULL THEN COALESCE(T1.original_order_submit_dt, T1.electronic_submit_dt)
            ELSE T1.electronic_submit_dt END) AS DATE) AS suitability_cycle_time
, CASE WHEN CAS_IND = 'N' AND TO_NUMBER(T1.agency_num) IS NOT NULL THEN 'CAB'
        WHEN TO_NUMBER(T1.agency_num) IS NOT NULL THEN 'CAS'
        ELSE 'Unknown' END AS distributor
, CASE WHEN TO_NUMBER(T1.agency_num) IS NULL THEN 'SDP' ELSE 'MMFA' END AS channel
, CASE WHEN lower(T1.product_nm) LIKE ('%capital vantage%') THEN 'Capital Vantage'
   		WHEN lower(T1.product_nm) LIKE ('%transitions select%') THEN 'Transition Select'
  		WHEN lower(T1.product_nm) LIKE ('%retireease choice%') THEN 'RetireEase Choice'
   		WHEN lower(T1.product_nm) LIKE ('%retireease%') THEN 'RetireEase'
   		WHEN lower(T1.product_nm) LIKE ('%stable voyage%') THEN 'Stable Voyage'
   		WHEN lower(T1.product_nm) LIKE ('%odyssey select%') THEN 'Odyssey Select'
   		WHEN lower(T1.product_nm) LIKE ('%index horizons%') THEN 'Index Horizons'
   		WHEN lower(T1.product_nm) LIKE ('%envision%') THEN 'Envision'
        ELSE 'Unknown' END AS product
, COALESCE(CASE WHEN lower(T1.product_nm) LIKE '%retireease%' THEN 'Income Annuity'
                WHEN lower(T1.product_nm) LIKE '%index horizons%' THEN 'Fixed Indexed' END,T1.product_type) AS product_category
, T6.business_partner_id as agent_id
, T6.last_nm||', '||T6.first_nm AS advisor_nm
, 'A' || RIGHT(T7.agency_id,3) AS firm
, CASE WHEN lower(T1.agency_num) = 'fil' THEN '244'
    ELSE lower(T1.agency_num) END AS firm_num
, CASE WHEN lower(T1.agency_num) = 'fil' THEN '999 - Edward Jones'
    WHEN T1.agency_num IS NULL AND T7.agency_id IS NULL THEN '999 - Unknown'
    WHEN T7.agency_id IS NULL THEN '999 - ' || (CASE WHEN lower(T1.agency_num) = 'fil' THEN '244' ELSE lower(T1.agency_num) END)
    ELSE 'A' || RIGHT(T7.agency_id,3) || ' - ' || T7.agency_nm END AS firm_nm
, T2.agreement_nr
, T1.auto_approved_ind
, T1.parent_cancel_dt AS "ParentCancelReworkDate" --(Parent Cancel Rework Date)
, CASE WHEN T1.parent_cancel_dt IS NOT NULL THEN 1 ELSE 0 END AS "ResubmitIndicator" -- Use the Electronic Submit Date to Anchor Resubmit Counts
, CAST(T1.electronic_submit_dt AS DATE) - CAST(parent_cancel_dt AS DATE) AS "Resubmit Lag Time" -- Resubmit Lag Time, Create this metric when talking to Resubmit Volume - Resubmit Lag Time (Time between Parent Cancel Date and Pend Date)
, T3.doc_type_nm
, CAST(T1.suit_comp_dt_transmit AS DATE) - CAST(T1.electronic_submit_dt AS DATE) AS InitialReviewCycleTime
, T8.igo_ind  -- Some are Paper apps, Concerned we may be missing the ones that areot electronically submitted.
, T1.row_process_dtm
FROM dma_vw.dim_ipipeline_orders_curr_vw T1
LEFT JOIN edw_semantic_vw.sem_agreement_current_vw T2 ON T1.dim_agreement_natural_key_hash_uuid = T2.dim_agreement_natural_key_hash_uuid
LEFT JOIN dma.anb_doc_type T3 ON T1.dim_agreement_natural_key_hash_uuid = T3.dim_agreement_natural_key_hash_uuid
LEFT JOIN edw_semantic_vw.sem_producer_demographics_current_vw T6 ON TRIM(LEADING '0' FROM REPLACE(REPLACE(T1.agent_id,'AA',''),'aa','')) = TRIM(LEADING '0' FROM T6.business_partner_id)
LEFT JOIN dma_vw.sem_dim_firm_current_vw T7 ON TRIM(LEADING '0' FROM T1.agency_num) = TRIM(LEADING '0' FROM T7.agency_id)
LEFT JOIN dma_vw.bibt_rel_initial_reviews_vw T8 ON lower(T1.order_entry_id) = lower(T8.application_id)

WHERE CAST(electronic_submit_dt AS DATE) >= '2019-07-01'









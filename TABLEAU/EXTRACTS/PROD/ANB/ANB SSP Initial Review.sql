SELECT  T6.prod_typ_nme AS review_type_cde
    , T6.major_prod_nme
    , T1.application_id AS order_entry_id
    , T1.initial_review_id
    , T1.agency_num
    , T1.agent_id
    , T6.minor_prod_nme
    , T2.name AS submission_type
    , T4.name AS funding_type
    , T12.product_category
    , CASE WHEN T3.name IS NULL THEN 'N/A'
            ELSE T3.name
        END AS replacement_type
    , T1.state_id AS ResidencyState
    , CASE WHEN suitability_ind = 0 THEN 'NIGO'
            WHEN suitability_ind = 1 THEN 'IGO'
        END AS suitability_igo_ind
    , CASE WHEN ownership_ind = 0 THEN 'Personal'
            WHEN ownership_ind = 1 THEN 'Business'
        END AS ownership_ind
    , T10.employee_first_nm
    , T10.employee_last_nm
    , T10.MMID
    , T1.created_at
    , CAST(T1.created_at AS DATE) AS created_dt
    , CASE WHEN T1.igo_ind = 0 THEN 'NIGO'
            WHEN T1.igo_ind = 1 THEN 'IGO'
        END AS initial_review_ind
    , T5.name AS market_type_nm
    , T1.ir_product_id
    , CAST(T12.issue_dt AS DATE) AS issue_dt
    , (SELECT is_holiday FROM dma_vw.dma_dim_date_vw WHERE T12.issue_dt = short_dt) AS issue_dt_is_holiday
    , T12.bingo_status
    , T12.Channel
    , T1.nigo_reason
FROM dma_vw.bibt_rel_initial_reviews_vw T1
LEFT JOIN edw_vw.product_translator_current_vw T6 ON t1.ir_product_id = T6.prod_id
LEFT JOIN dma_vw.bibt_ref_ir_submission_types_vw T2 ON T1.ir_submission_type_id = T2.submission_type_id
LEFT JOIN dma_vw.bibt_ref_ir_replacement_types_vw T3 ON T1.ir_replacement_type_id = T3.replacement_type_id
LEFT JOIN dma_vw.bibt_ref_ir_funding_types_vw T4 ON T1.ir_funding_type_id = T4.funding_type_id
LEFT JOIN dma_vw.bibt_ref_ir_market_types_vw T5 ON T1.ir_market_type_id = T5.market_type_id
LEFT JOIN dma_vw.dma_dim_employee_pit_vw T10 ON T1.created_by = T10.hr_id AND CAST(T1.created_at AS DATE) BETWEEN T10.begin_dt AND T10.end_dt
LEFT JOIN dma_vw.sem_dim_anb_application_curr_vw T12 ON T12.initial_review_id = T1.initial_review_id


SELECT T1.fact_activity_natural_key_hash_uuid,
       T1.source_transaction_id,
       T4.agreement_nr,
       T5.dim_agreement_natural_key_hash_uuid,
       T4.product_category,
       T4.product,
       T4.distributor,
       T4.channel,
       T4.contract_jurisdiction_state_cde,
       coalesce(T4.agent_id, T6.agent_id)                                  AS agent_id,
       T4.advisor_nm,
       coalesce(T4.firm_num, T6.agency_num)                                AS agency_num,
       T4.firm_nm,
       T1.work_event_id,
       T3.work_event_nm,
       T3.division_cd,
       T3.department_cd,
       T3.function_nm,
       T3.segment_nm,
       T1.team_party_id,
       T1.party_employee_id,
       T2.employee_first_nm,
       T2.employee_last_nm,
       ((T2.employee_last_nm || ', '::varchar(2)) || T2.employee_first_nm) AS employee_full_nm,
       T2.manager_last_nm,
       T2.manager_first_nm,
       ((T2.manager_last_nm || ', '::varchar(2)) || T2.manager_first_nm)   AS manager_full_nm,
       T2.organization_nm,
       T2.department_nm,
       T2.team_nm,
       T1.trans_type_id,
       T1.received_dt,
       T1.load_dt,
       T1.completed_dt,
       T1.tat,
       T1.tat_goal,
       T1.days_pending,
       T1.days_past_tat,
       T1.ir_igo_ind,
       T1.suit_igo_ind,
       T1.auto_approved_ind,
       T6.replacement_ind,
       T1.prod_credit,
       T4.application_signed_dt,
       T4.suitability_approved_dt,
       T4.original_order_submit_dt,
       T5.parent_cancel_dt,
       T4.suitability_submit_dt,
       CASE WHEN (lower(T5.app_status) = 'cancel/reject'::varchar(13)) THEN T5.app_status_change_dt
           ELSE NULL::timestamp END                                        AS reject_dt,
       CASE WHEN (lower(T5.app_status) = 'cancelled'::varchar(9)) THEN T5.app_status_change_dt
           ELSE NULL::timestamp END                                        AS cancel_dt,
       CASE WHEN (lower(T5.app_status) = 'cancel/rework'::varchar(13)) THEN T5.app_status_change_dt
           ELSE NULL::timestamp END                                        AS cancel_rework_dt,
       T1.row_process_dtm
FROM dma_vw.fact_anb_suit_activity_vw T1
LEFT JOIN dma_vw.dma_dim_employee_pit_vw T2 ON T1.party_employee_id = T2.party_employee_id AND T1.completed_dt BETWEEN T2.begin_dt AND T2.end_dt
LEFT JOIN dma_vw.dma_dim_work_pit_vw T3 ON T1.work_event_id = T3.work_event_id AND T1.completed_dt BETWEEN T3.begin_dt AND T3.end_dt
LEFT JOIN (SELECT * FROM dma_vw.sem_dim_anb_application_curr_vw
            LIMIT 1 OVER ( PARTITION BY initial_review_id ORDER BY application_signed_dt DESC)) T4 ON T1.initial_review_id = T4.initial_review_id
LEFT JOIN dma_vw.dim_ipipeline_orders_curr_vw T5 ON T1.source_transaction_id = T5.order_entry_id
LEFT JOIN dma_vw.bibt_rel_initial_reviews_vw T6 ON T1.initial_review_id = T6.initial_review_id
LIMIT 1 OVER (PARTITION BY T1.source_transaction_id, T1.work_event_id, T1.trans_type_id ORDER BY T1.load_dt);


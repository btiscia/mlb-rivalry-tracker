SELECT	T1.order_entry_id
    , T1.owner_full_nm
    , T1.owner_first_nm
    , T1.owner_last_nm
    , T1.owner_govt_id
    , T1.annuitant_full_nm
    , T1.annuitant_first_nm
    , T1.annuitant_middle_nm
    , T1.annuitant_last_nm
    , T1.product_type
    , T1.product_nm
    , T1.agency_num
    , T1.agent_id
    , T1.carrier_cd
    , CAST(T1.electronic_submit_dt AS DATE) AS electronic_submit_dt
    , T3.is_holiday AS is_holiday_elec
    , T3.is_weekday AS is_weekday_elec
    , CAST(T1.suit_comp_dt_approved AS DATE) AS suit_comp_dt_approved
    , CAST(T1.suit_comp_dt_transmit AS DATE) AS suit_comp_dt_transmit
    , T2.is_holiday AS is_holiday_suit
    , T2.is_weekday AS is_weekday_suit
    , CAST(T1.app_status_change_dt AS DATE) AS app_status_change_dt
    , T1.total_init_prem
    , T1.app_status
    , T1.copied_from_trans_id
    , T1.auto_approved_ind
    , T1.row_process_dtm
FROM dma_vw.dim_ipipeline_orders_pit_vw T1
LEFT JOIN dma_vw.dma_dim_date_vw T2 ON T2.short_dt = CAST(T1.suit_comp_dt_transmit AS DATE)
LEFT JOIN dma_vw.dma_dim_date_vw T3 ON T3.short_dt = CAST(T1.electronic_submit_dt AS DATE)
WHERE T1.electronic_submit_dt IS NOT NULL   --Count for Katie's Team Work Received
 AND (carrier_cd = '65935' OR carrier_cd = '93432')
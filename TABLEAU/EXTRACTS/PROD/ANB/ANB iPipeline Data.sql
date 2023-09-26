/*
FILENAME: ANNUITY NEW BUSINESS iPIPELINE DATA
UPDATED BY: Jess Madru
LAST UPDATED: 09/26/2023
CHANGES MADE: Vertica Migration, excluded HO products
*/

SELECT	

	  T1.order_entry_id AS "OrderEntryID"
    , T1.product_category AS "ProductType"
    , T1.product AS "ProductName"
    , T1.agency_num AS "AgencyNumber"
    , T1.agent_id AS "AgentID"
    , T1.carrier_cd AS "CarrierCode"
    , CAST(T1.electronic_submit_dt AS DATE) AS "ElectronicSubmitDate"
    , CAST(T3.is_holiday AS INTEGER) AS "IsHolidayElec"
    , CAST(T3.is_weekday AS INTEGER) AS "IsWeekdayElec"
    , CAST(T1.suit_comp_dt_approved AS DATE) AS "SuitCompleteDateApproved"
    , CAST(T1.suit_comp_dt_transmit AS DATE) AS "SuitCompleteDateTransmitted"
    , CAST(T2.is_holiday AS INTEGER) AS "IsHolidaySuit"
    , CAST(T2.is_weekday AS INTEGER) AS "IsWeekdaySuit"
    , CAST(T1.app_status_change_dt AS DATE) AS "ApplicationStatusChangeDate"
    , T1.total_init_prem AS "TotalInitialPremium"
    , T1.app_status AS "ApplicationStatus"
    , T1.copied_from_trans_id AS "CopiedFromTransIdentifier"
    , T1.auto_approved_ind AS "AutoApprovedIndicator"
    , T1.row_process_dtm AS "TRANS_DT"
FROM dma_vw.sem_anb_ipipeline_vw T1
LEFT JOIN dma_vw.dma_dim_date_vw T2 ON T2.short_dt = CAST(T1.suit_comp_dt_transmit AS DATE)
LEFT JOIN dma_vw.dma_dim_date_vw T3 ON T3.short_dt = CAST(T1.electronic_submit_dt AS DATE)
WHERE T1.electronic_submit_dt IS NOT NULL   --Count for Katie's Team Work Received
 AND (carrier_cd = '65935' OR carrier_cd = '93432')
and T1.home_office_ind = 0
 
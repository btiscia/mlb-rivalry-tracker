/*
FILENAME: ANNUITY NEW BUSINESS iPIPELINE DATA
UPDATED BY: John Avgoustakis, Vince Bonaddio 
LAST UPDATED: 06/27/2022
CHANGES MADE: Vertica Migration
*/

SELECT	

	  T1.order_entry_id AS "OrderEntryID"
    , T1.owner_full_nm AS "OwnerFullName"
    --, T1.owner_first_nm AS "OwnerFirstName"
    --, T1.owner_middle_nm AS "OwnerMiddleName"
    --, T1.owner_last_nm AS "OwnerLastName"
    --, T1.owner_govt_id AS "OwnerGovernmentID"
    , T1.annuitant_full_nm AS "AnnuitantFullName"
    --, T1.annuitant_first_nm AS "AnnuitantFirstName"
    --, T1.annuitant_middle_nm AS "AnnuitantMiddleName"
    --, T1.annuitant_last_nm AS "AnnuitantLastName"
    , T1.product_type AS "ProductType"
    , T1.product_nm AS "ProductName"
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
FROM dma_vw.dim_ipipeline_orders_pit_vw T1
LEFT JOIN dma_vw.dma_dim_date_vw T2 ON T2.short_dt = CAST(T1.suit_comp_dt_transmit AS DATE)
LEFT JOIN dma_vw.dma_dim_date_vw T3 ON T3.short_dt = CAST(T1.electronic_submit_dt AS DATE)
WHERE T1.electronic_submit_dt IS NOT NULL   --Count for Katie's Team Work Received
 AND (carrier_cd = '65935' OR carrier_cd = '93432')
 
 
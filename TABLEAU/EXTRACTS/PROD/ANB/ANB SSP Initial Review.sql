/*
* This routine pulls IR NIGO Review Entries
*  Peer Review & Change Log:
*  Peer Review Date:
*  Source for this routine is
*  Author: Zach Dorval/Lorraine Christian
*  Created: 11/3/2020
*  Updated By: John Avgoustakis
*  Updated: 7/5/2022
* Revision by Lorraine:  Added IssueDateIsHoliday and BINGO Status (lines 48,50-52, 64 )
* Revision by Vince:  Removed several joins and added initial review id field.
* Revision by John: Converted to Vertica.
======================================================================


======================================================================*/

SELECT  
	  T6.major_prod_nme AS "ReviewTypeCode"
    , T1.application_id AS "Application ID"
    , T1.initial_review_id AS "InitialReviewID"
    , T1.agency_num AS "AgencyID"
    , T1.agent_id AS "AgentID"
    , trim(replace(T6.prod_typ_nme, 'Massmutual', '')) AS "Product"
    , T12.product_category AS "ProductCategory"
    , T2.name AS "SubmissionType"
    , T4.name AS "FundingType"
    , CASE WHEN T3.name IS NULL THEN 'N/A'
            ELSE T3.name
        END AS "ReplacementType"
    , t12.resident_state_cde AS "ResidencyState"
    , CASE WHEN T1.suitability_ind = 0 THEN 'NIGO'
            WHEN T1.suitability_ind = 1 THEN 'IGO'
        END AS "SuitabilityIGOIndicator"
    , CASE WHEN T1.ownership_ind = 0 THEN 'Personal'
            WHEN T1.ownership_ind = 1 THEN 'Business'
        END AS "OwnershipIndicator"
    , T10.employee_first_nm AS "EmployeeFirstName"
    , T10.employee_last_nm AS "EmployeeLastName"
    , T10.MMID
    , T1.created_at AS "CreatedAt"
    , CAST(T1.created_at AS DATE) AS "Created Date"
    , CASE WHEN T1.igo_ind = 0 THEN 'NIGO'
            WHEN T1.igo_ind = 1 THEN 'IGO'
        END AS "InitialReviewIndicator"
    , T5.name AS "IRMarketTypeName"
    , T1.ir_product_id AS "IRProductID"
    , CAST(T12.issue_dt AS DATE) AS "IssueDate"
    , (SELECT is_holiday FROM dma_vw.dma_dim_date_vw WHERE T12.issue_dt = short_dt) AS "IssueDateIsHoliday"
    , T12.bingo_status AS "BINGOStatus"
    , T12.Channel
    , T1.nigo_reason AS "NigoReason"
FROM dma_vw.bibt_rel_initial_reviews_vw T1
LEFT JOIN edw_vw.product_translator_current_vw T6 ON t1.ir_product_id = T6.prod_id
LEFT JOIN dma_vw.bibt_ref_ir_submission_types_vw T2 ON T1.ir_submission_type_id = T2.submission_type_id
LEFT JOIN dma_vw.bibt_ref_ir_replacement_types_vw T3 ON T1.ir_replacement_type_id = T3.replacement_type_id
LEFT JOIN dma_vw.bibt_ref_ir_funding_types_vw T4 ON T1.ir_funding_type_id = T4.funding_type_id
LEFT JOIN dma_vw.bibt_ref_ir_market_types_vw T5 ON T1.ir_market_type_id = T5.market_type_id
LEFT JOIN dma_vw.dma_dim_employee_pit_vw T10 ON T1.created_by = T10.hr_id AND CAST(T1.created_at AS DATE) BETWEEN T10.begin_dt AND T10.end_dt
LEFT JOIN dma_vw.sem_dim_anb_application_curr_vw T12 ON T12.initial_review_id = T1.initial_review_id
WHERE T1.hold_ind = FALSE
/*
FILENAME: DI CLAIMS RESTRICTED CONTENT RISK
CREATED BY: John Avgoutakis
LAST UPDATED: 5/23/2022
CHANGES MADE: Vertica SQL Creation.
*/

SELECT 
  T1.risk_type_group AS "Risk Type Group"
, T1.fact_risk_inventory_uuid AS "Risk Inventory ID"  
, T1.short_claim_num AS "Short Claim Number"
, T1.claim_num AS "Claim Number"
, T1.current_status AS "Claim Current Status"
, T1.current_substatus AS "Claim Current Substatus" 
, T1.claim_category AS "Claim Category"
, T1.claim_status_category AS "Claim Status Category"
, T1.dibs_customer_nm AS "Claimant Name" 
, T1.claimant_current_age_floor AS "Claimant Age"
, T1.months_since_dod AS "MonthsSinceDateofDisability"
, T1.examiner_nm AS "Examiner"
, T1.examiner_manager_nm AS "Manager"
, T1.team_nm AS "Team"           
, T1.risk_type_nm AS "Risk Type"
, T1.risk_type_id AS "RiskTypeID"
, T1.role_grade_id AS "RoleGradeID"
, T1.risk_cal_tat_goal AS "Risk Calendar TAT Goal" 
, T1.load_dt AS "Load Date" 
, T1.last_item_type AS "Last Item Type"
, T1.last_item_dt AS "Last Item Date"
, T1.supported_through_dt AS "Supported Through Date"
, T1.cal_days_pending AS "Calendar Days Pending" 
, T1.cal_days_past_tat AS "Calendar Days Past TAT"
, T1.expected_complete_dt AS "Expected Completed Date"
, CASE WHEN T1.cal_days_past_tat > 0 THEN 'Past Due' 
        WHEN T1.cal_days_past_tat BETWEEN -30 AND 0 THEN 'Due'
        ELSE 'Missing' 
  END AS "Status"
, CAST(T1.row_process_dtm AS TIMESTAMP) AS "Trans Date"
, CASE WHEN T1.risk_type_id = 9 AND T1.role_grade_id = 11 THEN 0
    WHEN T1.risk_type_id <> 9 AND T1.role_grade_id = 11 THEN 1
    ELSE 0 
  END AS "Suppression Indicator" 
, T1.restricted_claim_ind AS "RestrictedClaimIndicator"
FROM dma_vw.sem_fact_dic_risk_inventory_vw T1
WHERE T1.risk_type_group = 'CONTENT REPORTS' 
AND (T1.cal_days_past_tat >=-30 OR T1.cal_days_past_tat IS NULL) 
AND "Suppression Indicator" = 0
AND T1.claim_category = 'Disability'
AND T1.load_dt = '2022-05-24'
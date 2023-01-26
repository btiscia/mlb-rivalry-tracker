/*
FILENAME: DI CLAIMS RESTRICTED SUPPORTED THROUGH RISK
CREATED BY: John Avgoutakis
UPDATED BY: Jess Madru
LAST UPDATED: 1/26/2023
CHANGES MADE: Vertica SQL Creation, added Admin System field
*/

SELECT 
 T1.risk_type_group AS "Risk Type Group"
, T1.fact_risk_inventory_uuid AS "Risk Inventory ID"
, T1.short_claim_num AS "Short Claim Number"
, T1.claim_num AS "Claim Number"
, T1.admin_sys AS "Admin System"
, CASE 
    WHEN LOWER(T1.last_item_type)  = ('no/uncertain') THEN 'Uncertain'
    WHEN LOWER(T1.last_item_type)  LIKE '%yes%'  AND supported_through_dt IN( '2008-08-08','2010-10-10','2011-11-11') THEN 'Extended Duration' 
    WHEN LOWER(T1.last_item_type)  LIKE '%yes%'  AND T1.cal_days_past_tat <= 0  THEN 'Active Supported'
    WHEN LOWER(T1.last_item_type)  LIKE '%yes%' AND  T1.cal_days_past_tat > 0   THEN 'Past Supported'
    ELSE 'No Review'  
  END AS "Supported Risk Type"
,CASE 
    WHEN T1.claim_status_category = 'Active Pending' THEN 'Pending'
    WHEN T1.claim_status_category  = 'Approved'  THEN 'Approved'
    ELSE 'N/A'  
 END AS "Claim Status"
, T1.claim_category AS "Claim Category"
, T1.dibs_customer_nm AS "Claimant Name"
, T1.claimant_current_age_floor AS "Claimant Age"
, T1.examiner_nm AS "Examiner"
, T1.examiner_manager_nm AS "Manager"
, T1.role_grade_id AS "RoleGradeID"
, T1.role_grade_nm AS "Role Grade Name"
, T1.load_dt AS "Load Date"
, T1.last_item_type AS "Last Item Type"
, T1.last_item_dt AS "Date of Medical Review"
, T1.supported_through_dt AS "Supported Through Date"
, T1.cal_days_past_tat AS "Calendar Days Past TAT"
, CAST(T1.row_process_dtm AS TIMESTAMP) AS "Trans Date"
, T1.icd_1_code AS "Diagnosis Group"
, T1.icd_1_group_nm AS "Diagnosis"
, T1.restricted_claim_ind AS "RestrictedClaimIndicator"

FROM dma_vw.sem_fact_dic_risk_inventory_vw T1
WHERE T1.risk_type_group = 'SUPPORTED THROUGH' 
AND (T1.cal_days_past_tat >=-60 OR T1.cal_days_past_tat IS NULL) 
AND COALESCE(T1.role_grade_id, -99) <> 12
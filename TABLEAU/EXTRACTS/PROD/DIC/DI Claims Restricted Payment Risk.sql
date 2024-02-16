/*
FILENAME: DI CLAIMS RESTRICTED PAYMENT RISK
CREATED BY: John Avgoutakis
LAST UPDATED: 02/12/2024
CHANGES MADE: 
06/01/2022 - Vertica SQL Creation.
02/12/2024 - Added in Litigation Indicator and Approval date - B. Tiscia
*/

SELECT DISTINCT T1.short_claim_num AS "Short Claim Number"
, T1.claim_num AS "Claim Number"
, CASE WHEN T1.last_item_type = 'Payment Transaction - TD' THEN 'Total'
    WHEN T1.last_item_type = 'Payment Transaction - PD' THEN 'Partial' END AS "Base Payment Type"
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
, T1.role_grade_id AS "RoleGradeID"
, T1.risk_cal_tat_goal AS "Risk Calendar TAT Goal"
, T1.load_dt AS "Load Date"
, T1.supported_through_dt AS "Supported Through Date"
, T1.last_item_type AS "Last Item Type"
, T2.last_item_dt AS "Past Due Check Date"
, T3.last_item_dt AS "Past Due Through Date"
, COALESCE(NoPaymentIndicator, 0) AS "No Payment Indicator"
, COALESCE(NoThroughIndicator, 0) AS "No Through Indicator"
, CAST(T1.row_process_dtm AS DATE) AS "Trans Date"
, T1.restricted_claim_ind AS "RestrictedClaimIndicator"
, CASE WHEN T4.in_litigation_ind = True THEN 'Yes' ELSE 'No' END AS 'In Litigation'
, T4.first_approval_dt as 'Approval Date'
FROM dma_vw.sem_fact_dic_risk_inventory_vw T1

-- Left  Join to No Payment Data
LEFT JOIN (SELECT last_item_id, load_dt, claim_num, last_item_dt, risk_type_id, 1 NoPaymentIndicator
                        FROM dma_vw.sem_fact_dic_risk_inventory_vw
                        WHERE risk_type_id = 1
                            AND (cal_days_past_tat > 0 OR cal_days_past_tat IS NULL)) T2 ON T1.claim_num = T2.claim_num AND T1.load_dt = T2.load_dt

-- Left Join to No Through Payment Data
LEFT JOIN  (SELECT last_item_id, load_dt, claim_num, last_item_dt, risk_type_id, 1 NoThroughIndicator
                        FROM dma_vw.sem_fact_dic_risk_inventory_vw
                        WHERE risk_type_id = 8
                            AND (cal_days_past_tat > 0 OR cal_days_past_tat IS NULL)) T3 ON T1.claim_num = T3.claim_num AND T1.load_dt = T3.load_dt

-- Left Join to dic_dim_claim_curr_vw
LEFT JOIN dma_vw.dic_dim_claim_curr_vw T4 on T1.claim_num = T4.claim_num

WHERE T1.risk_type_id IN (1,8)
AND (T1.cal_days_past_tat > 0 OR T1.cal_days_past_tat IS NULL)
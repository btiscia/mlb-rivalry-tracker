/*
FILENAME: DI CLAIMS CYCLE TIME
CREATED BY: John Avgoutakis
LAST UPDATED: 6/01/2022
CHANGES MADE: Vertica SQL Creation.
*/

SELECT
  report_dt AS "Date"
, cycle_time_type AS "Cycle Time Type"
, short_claim_num AS"Short Claim Number" 
, no_forms_ind AS "No Forms Indicator"
, cycle_time AS "Cycle Time"
, met_expected AS "MetExpected"
, goal_val AS "Goal Value"
, row_process_dtm AS "TransDate"
, claim_category AS "Claim Category"
, dibs_customer_nm AS "Claimant"
, occ_desc AS "Occ Description"
, icd_1_group_nm AS "ICD Group Name"
, icd_1_code AS "ICD Code"
, icd_1_desc AS "ICD Description"
, contestable_ind AS "Contestable Indicator"
, appeal_ind AS "Appeal Indicator"
, erisa_ind AS "ERISA Indicator"
, late_notice_ind AS "Late Notice Indicator"
, quick_decision_ind AS "Quick Claim Indicator"
, disability_dt AS "Date of Disability"
, dt_of_notice AS "DateOfNotice"
, dt_of_forms AS "DateOfForms"
, dt_of_decision AS "DateOfDecision"
, preclaim_end_dt "PreclaimEndDate"
, est_ben_duration As "EstimatedBenefitDuration"
, birth_dt AS "Birth Date"
, residence_state AS "Residence State"
, examiner_id AS "ExaminerID"
, COALESCE(employee_last_nm || ',' || employee_first_nm, 'Unknown') AS "Examiner"
, COALESCE(manager_last_nm || ',' || manager_first_nm, 'Unknown') AS "Manager"
, examiner_party_employee_id "ExaminerPartyEmployeeID"
, team_nm AS "Team"
FROM dma_vw.sem_fact_dic_cycle_time_vw
WHERE (restricted_claim_ind = 0 OR restricted_claim_ind IS NULL)
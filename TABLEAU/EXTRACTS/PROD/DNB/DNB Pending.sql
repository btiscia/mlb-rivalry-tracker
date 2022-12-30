/*
DNB Pending
Environment: Vertica
Author: Lorraine Christian
Data Developer: Srinivas Pasumarthy 
Created: 8/25/2022
*/

SELECT 
agency AS "Agency #"
, bus_prcs_code
, bus_prcs_nm
, case_Id AS "Case Id"
, cc_ind AS "CC Indicator"
, client_first_nm AS "Client First Nm"
, client_last_nm AS "Client Last Nm"
, cur_prcr_id
, department_nm AS "Department Name"
, min_req_dt AS "Earliest Reqmt Date"
, last_nm AS "Employee Last_Nm"
, first_nm AS "Employee_First_Nm"
, CASE WHEN masters = 1 THEN 'Y' ELSE 'N' END AS "Masters"
, policy_nr AS "Policy #"
, req_status AS "Requirement Status"
, role_nm AS "Role Nm"
, run_dt AS "Run Dt"
, row_process_dtm
, Status AS "Status"
, sts_code AS "Sts Code"
, team_nm AS "Team"
, trans_type AS "Transaction"
, case_id_cc AS "Case id cc"
, case_id_ccuw AS "Case id ccuw"
, sla AS "SLA"
, tat AS "TAT"
FROM dma_vw.sem_dnb_pending_vw
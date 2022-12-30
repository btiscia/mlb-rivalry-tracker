/*
DNB Completed
Environment:  Vertica
Author: Lorraine Christian
Data Developer: Srinivas Pasumarthy 
Created: 8/25/2022
*/

SELECT 
  case_id AS "Case Id"
, policy_nr AS "Policy Num" 
, case_prcs_nr  AS "Case Prcs No"
, cas_grpg_nr AS "Cas Grpg Nr"
, sts_code AS "Sts Code"
, sts_dt AS "Status Datetime - Completed"
, prty_nr AS "Prty No"
, strt_dt AS "Strt Date"
, estm_compl_dt AS "Estm Compl Date"
, next_actn_dt AS "Next Actn Date"
, bus_prcs_code AS "Bus Prcs Code"
, cur_prcr_id AS "Cur Prcr Id"
, cmnt AS "Cmnt"
, sales_ctg_cde AS "Sales Ctg Cde"
, last_nm AS "Last Name"
, first_nm AS "First Name"
, team_nm AS "Team"
, role_nm AS "Role Nm"
, trans_type AS "Transaction"
, sla AS "SLA"
, cc_ind AS "Cc Ind"
, tat_bus_days AS "TAT Business Days"
, run_dt AS "Run Date"
, department_id AS "Department Id"
, department_nm AS "Department Nm"
, status AS "Status"
, client_last_nm AS "CLIENT_LAST_NM"
, client_first_nm AS "CLIENT_FIRST_NM"
, agency
, CASE WHEN masters = 1 THEN 'Y' ELSE 'N' END AS "Masters"
FROM dma_vw.sem_dnb_completed_vw
/*
FILENAME: LAC HISTORICAL DETAILS CURRENT
CREATED BY: John Avgoutakis
LAST UPDATED: 11/08/2023
CHANGES MADE: 1/18/2022 - Repointed to Vertica and removed pending transactions.
11/07/2022 - Added in product_type_desc
01/30/2023 - Added in face_amt
11/20/2023 - Added in channel
06/07/2024 - Added in Digital Operations Indicator
*/


SELECT
	  T1.transaction_type_nm AS "Transaction Type"
	, T1.fact_integrated_natural_key_hash_uuid AS "Natural Key"
	, T1.source_transaction_id AS "Source Transaction ID"
	, T1.pol_nr AS "Policy Number"
	, T1.report_dt AS "Date"
	, T1.employee_role_nm AS "Employee Role Name"
	, COALESCE(T1.employee_last_nm || ', ' || T1.employee_first_nm, 'Unknown') AS 'Employee'
	, COALESCE(T1.manager_last_nm || ', ' || T1.manager_first_nm , 'Unknown') AS 'Manager'
	, T1.employee_team_nm AS "Team Name"
	, T1.work_event_function_nm AS "Function Name"
	, T1.work_event_segment_nm AS "Segment Name"
	, T1.work_event_nm AS "Work Event Name"
	, T1.priority_nm AS "Priority"
	, T1.admn_sys_cde AS "Admin System"
	, T1.process_nm AS "Process Name"
	, T1.process_id AS "Process ID"
	, T1.process_order AS "Process Order"
	, T1.chnl_dspy_nm AS "Service Channel Code" 
	, T1.party_type_nm AS "Party Type Name"
	, T1.employee_organization_nm AS "Employee Organization Name"
	, T1.employee_department_nm AS "Employee Department Name"
	, T1.site_nm AS "Site Name"
	, T1.work_event_organization_nm AS "Work Event Organization Name"
	, T1.work_event_department_nm AS "Work Event Department Name"
	, T1.work_event_primary_role_nm AS "Primary Role Name"
	, T1.work_event_system_nm AS "System Name"
	, T1.work_event_num AS "Work Event Number"
	, T1.department_cd AS "Department Code"
	, T1.division_cd AS "Division Code"	
	, T1.tat AS "TAT" 
	, T1.long_completed_dt AS "Completed Date Stamp"
	, T1.NIGO_des AS "NIGODescription"
	, CASE WHEN T1.igo_ind = 1 AND T1.nigo_cd = '-99' THEN 1 ELSE 0 END AS "NIGO Count"
	, CASE WHEN T1.igo_ind = 1 AND T1.nigo_cd = '090' THEN 1 ELSE 0 END AS "IGO Count"
	, T1.igo_ind AS "IGO NIGO Count"
	, T1.sht_cmnt_des AS "Short Comments"
	, CASE WHEN T1.met_expected_ind = 1 AND T1.days_past_tat <= 0 THEN 1 ELSE 0 END AS "Met Expected Count"
	, T1.met_expected_ind AS "Met Expected Ind Count"
	, T1.TAT AS "Total TAT Days"
	, 1 AS "Transaction Count"
	, T1.row_process_dtm AS "Transaction Date"
	, T1.prod_credit AS "Productivity Credits"
	, T2.goal_val AS "IGO Goal"
	, T1.flex_ind AS "Flex Count"
	, CASE WHEN T1.days_past_tat <= 0 THEN 1 ELSE 0 END AS "Met TAT Count"
	, CASE WHEN T1.days_past_tat = 1 THEN 1 ELSE 0 END AS "Past TAT 1"
	, CASE WHEN T1.days_past_tat = 2 THEN 1 ELSE 0 END AS "Past TAT 2"
	, CASE WHEN T1.days_past_tat = 3 THEN 1 ELSE 0 END AS "Past TAT 3"
	, CASE WHEN T1.days_past_tat >= 4 THEN 1 ELSE 0 END AS "Past TAT 4+"
    , upper(T1.product_type_desc) AS "Product"
    , T1.face_amt AS "Face Amount"
    , CASE WHEN T1.mmsd_ind = True THEN 'MMSD' ELSE 'MMFA' END AS "Channel"
    , CASE WHEN dig_ops_ind = 0 THEN 'N' ELSE 'Y' END AS "DigOps Ind"
    
FROM dma_vw.fact_integrated_lac_curr_vw T1
LEFT JOIN (SELECT * FROM dma.dma_dim_goal_curr WHERE goal_type_id = 5) T2 ON T1.work_event_function_id = T2.function_id AND T1.employee_department_id = T2.department_id
WHERE T1.trans_type_id IN (1,3)
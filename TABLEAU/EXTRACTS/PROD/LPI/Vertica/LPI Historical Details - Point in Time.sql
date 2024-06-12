/*
FILENAME: LPI HISTORICAL DETAILS PIT
UPDATED BY: Jess Madru
LAST UPDATED: 9/5/2023
CHANGES MADE: Vertica SQL Creation.
9/21/2022 - Productivity credits changed
9/5/2023 - Added fields for Work Distribution reporting
6/12/2024- Added Digital Operations Indicator 
*/

SELECT
  T1.transaction_type_nm AS "Transaction Type"
, T1.dim_agreement_natural_key_hash_uuid AS "Natural Key"
, T1.source_transaction_id AS "Source Transaction ID" 
, T1.pol_nr AS "Policy Number"
, T1.report_dt AS "Date"
, T1.employee_role_nm AS "Employee Role Name"
, COALESCE(T1.employee_last_nm || ', ' || T1.employee_first_nm, 'Unknown') AS "Employee"
, COALESCE(T1.manager_last_nm || ', ' || T1.manager_first_nm , 'Unknown') AS "Manager"
, T1.employee_team_nm AS "Team Name"
, T1.work_event_function_nm AS "Function Name"
, T1.work_event_segment_nm AS "Segment Name"
, T1.work_event_nm AS "Work Event"
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
, T1.work_event_department_id AS "Work Department Event ID"
, T1.department_cd AS "Department Code"
, T1.division_cd AS "Division Code"
, CASE WHEN T1.bcc_ind = 0 THEN 'N' ELSE 'Y' END AS "Society 1851"
, T1.tat AS "TAT"
, T1.long_completed_dt AS "Completed Date Stamp"
, CAST(T1.long_completed_dt AS Date) AS "Completed Date"
, T1.NIGO_des AS "NIGODescription"
, CASE WHEN igo_ind = 1 AND nigo_cd = '-99' THEN 1 ELSE 0 END AS "NIGO Count"
, CASE WHEN igo_ind = 1 AND nigo_cd = '090' THEN 1 ELSE 0 END AS "IGO Count"
, T1.igo_ind AS "IGO NIGO Count"
, T1.sht_cmnt_des AS "Short Comments"
, CASE WHEN T1.met_expected_ind = 1 AND days_past_tat <= 0 THEN 1 ELSE 0 END AS "Met Expected Count"
, T1.met_expected_ind AS "Met Expected Ind Count"
, T1.tat AS "Total TAT Days"
, 1 AS "Transaction Count"
, T1.row_process_dtm AS "Transaction Date"
, T1.prod_credit AS "Productivity Credits"
 , T2.goal_val AS "IGO Goal"
, flex_ind AS "Flex Count"
, CASE WHEN days_past_tat <= 0 THEN 1 ELSE 0 END AS "Met TAT Count"
, CASE WHEN days_past_tat = 1 THEN 1 ELSE 0 END AS "Past TAT 1"
, CASE WHEN days_past_tat = 2 THEN 1 ELSE 0 END AS "Past TAT 2"
, CASE WHEN days_past_tat = 3 THEN 1 ELSE 0 END AS "Past TAT 3"
, CASE WHEN days_past_tat >= 4 THEN 1 ELSE 0 END AS "Past TAT 4+"
, CASE
     when T1.role_grade_id = 14
     then 'Bot'
     when T1.party_type_id = 2
     then 'System Acct'
     when (T1.employee_department_id = 51
        or (COALESCE(T1.employee_department_id, -99) = -99
        and lower(T1.mmid) like 'ot%'))
        and T1.party_type_id <> 2
     then 'Hyderabad Employee'
     when (T1.employee_department_id NOT IN (51, -99)
        or (COALESCE(T1.employee_department_id, -99) = -99
        and left(lower(T1.mmid),2) in ('mm', 'ct')))
        and T1.party_type_id <> 2
     then 'US Employee'
     else 'Unknown'
     end as "Completed By Type"
, COALESCE(T1.logged_by_last_nm || ', ' || T1.logged_by_first_nm, 'Unknown') AS 'Logged By'	
, CASE WHEN dig_ops_ind = 0 THEN 'N'			
	ELSE 'Y' END AS "DigOps Ind"		
FROM dma_vw.fact_integrated_lpi_pit_vw AS T1	
LEFT JOIN (SELECT *  FROM dma.dma_dim_goal_curr WHERE goal_type_id = 5) AS T2 ON T1.work_event_function_id = T2.function_id	AND T1.employee_department_id = T2.department_id	
WHERE	
T1.trans_type_id in (1,3)
AND T1.work_event_num <> 4763
AND YEAR(T1.report_dt) >= YEAR(CURRENT_DATE) - 3 --returns current year and 3 full years
/*
FILENAME: ANNUITY OPERATIONS HISTORICAL DETAILS POINT IN TIME
UPDATED BY: Jess Madru
LAST UPDATED: 9/26/2023
CHANGES MADE: 06/10/2022 - Vertica Migration
11/03/2022 - Added in product_type_desc
9/26/2023 - added fields for Work Distribution reporting
*/


SELECT
	  T1.transaction_type_nm AS "Transaction Type"
	, T1.dim_agreement_natural_key_hash_uuid AS "Natural Key"
	, T1.source_transaction_id AS "Source Transaction ID"
	, T1.agreement_nr AS "Policy Number"
	, T1.report_dt AS "Date"
	, T1.employee_role_nm AS "Employee Role Name"
	, COALESCE(T1.employee_last_nm || ', ' || T1.employee_first_nm, 'Unknown') AS 'Employee'
	, COALESCE(T1.manager_last_nm || ', ' || T1.manager_first_nm , 'Unknown') AS 'Manager'
	, T1.employee_team_nm AS "Team Name"
	, T1.function_nm AS "Function Name"
	, T1.segment_nm AS "Segment Name"
	, T1.work_event_nm AS "Work Event Name"
	, T1.priority_id AS "Priority"
	, T1.admn_sys_cde AS "Admin System"
	, T1.admn_sys_id AS "Admin System ID"
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
	, T1.work_event_department_id AS "Work Event Department ID"
	, T1.primary_role_nm AS "Primary Role Name"
	, T1.work_event_system_nm AS "System Name"
	, T1.work_event_num AS "Work Event Number"
	, T1.department_cd AS "Department Code"
	, T1.division_cd AS "Division Code"
	, CASE WHEN T1.trans_type_id = 3 THEN 1 ELSE 0 END AS "Completed Indicator"	
	, T1.system_division_nm AS "Line of Business"
	, T1.tat AS "TAT" 
	, T1.days_past_tat AS "Days Past TAT"
	, T1.days_past_tat AS "Total TAT Days" --Should be reviewed
	, T1.trans_type_id "TransactionTypeId"
	, T1.long_completed_dt AS "Completed Time Stamp"
	, T1.completed_dt AS "Completed Date"	
	, T1.NIGO_des AS "NIGODescription"
	, CASE WHEN T1.igo_ind = 1 AND T1.nigo_cd = '-99' THEN 1 ELSE 0 END AS "NIGO Count"
	, CASE WHEN T1.igo_ind = 1 AND T1.nigo_cd IN ('090','361') THEN 1 ELSE 0 END AS "IGO Count"
	, T1.igo_ind AS "IGO NIGO Count"
	, T1.short_comment AS "Short Comments"
	, CASE WHEN T1.work_event_met_expected = 1 AND days_past_tat <= 0 THEN 1 ELSE 0 END AS "Met Expected Count"
	, T1.work_event_met_expected AS "Met Expected Ind Count"
	, T1.row_process_dtm AS "Transaction Date"
	, T1.prod_credit AS "Productivity Credits"
	, T1.flex_ind AS "Flex Count"
	, T1.bcc_ind AS "Society 1851"
	, CASE WHEN days_past_tat <= 0 THEN 1 ELSE 0 END AS "Met TAT Count"
	, CASE WHEN days_past_tat = 1 THEN 1 ELSE 0 END AS "Past TAT 1"
	, CASE WHEN days_past_tat = 2 THEN 1 ELSE 0 END AS "Past TAT 2"
	, CASE WHEN days_past_tat = 3 THEN 1 ELSE 0 END AS "Past TAT 3"
	, CASE WHEN days_past_tat >= 4 THEN 1 ELSE 0 END AS "Past TAT 4+"
	,  CASE WHEN T1.major_product_type_desc IS NULL AND T1.primary_log_id IN (6,10) THEN 'Unknown'
			WHEN T1.major_product_type_desc IS NULL AND T1.primary_log_id NOT IN (6,10) THEN NULL
			ELSE T1.major_product_type_desc
	   END AS "Contract Type"
	, T1.item_ct AS "Transaction Count"
	, T2.goal_val AS "IGO Goal"
    , upper(T1.product_type_desc) AS "Product"
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
FROM dma_vw.fact_integrated_ano_pit_vw T1
LEFT OUTER JOIN (SELECT goal_val, department_id, function_id FROM dma_vw.dma_dim_goal_pit_vw WHERE end_dt = '9999-12-31' AND goal_type_id = 5) T2
ON T1.function_id = T2.function_id AND T1.employee_department_id = T2.department_id
WHERE (work_event_department_id IN (9,11) OR employee_department_id IN (9,11))
AND T1.trans_type_id IN (1,3)
AND YEAR(T1.report_dt) >= YEAR(CURRENT_DATE) - 3 --returns current year and 3 full years
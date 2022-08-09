/*
FILENAME: ANNUITY OPERATIONS HISTORICAL DETAILS POINT IN TIME
CREATED BY: John Avgoustakis, William Trombley
LAST UPDATED: 06/10/2022
CHANGES MADE: Vertica Migration
*/


SELECT
	  T1.transaction_type_nm AS "Transaction Type"
	, T1.fact_integrated_natural_key_hash_uuid AS "Natural Key"
	, T1.source_transaction_id AS "Source Transaction ID"
	, T1.agreement_nr AS "Policy Number"
	, T1.report_dt AS "Date"
	, T1.employee_role_nm AS "Employee Role Name"
	, COALESCE(employee_last_nm || ', ' || employee_first_nm, 'Unknown') AS 'Employee'
	, COALESCE(manager_last_nm || ', ' || manager_first_nm , 'Unknown') AS 'Manager'
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
	--, T1.mmid AS "MMID"
	, T1.site_nm AS "Site Name"
	, T1.work_event_organization_nm AS "Work Event Organization Name"
	, T1.work_event_department_nm AS "Work Event Department Name"
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
	, T1.NIGO_des AS "NIGODescription"
	, CASE WHEN T1.igo_ind = 1 AND T1.nigo_cd = '-99' THEN 1 ELSE 0 END AS "NIGO Count"
	, CASE WHEN T1.igo_ind = 1 AND T1.nigo_cd IN ('090','361') THEN 1 ELSE 0 END AS "IGO Count"
	, T1.igo_ind AS "IGO NIGO Count"
	, T1.short_comment AS "Short Comments"
	--, T1.rqstr_des AS "Requestor Type Name"
	--, T1.ProductTypeName AS "Product Type Name"
	, CASE WHEN T1.work_event_met_expected = 1 AND days_past_tat <= 0 THEN 1 ELSE 0 END AS "Met Expected Count"
	, T1.work_event_met_expected AS "Met Expected Ind Count"
	, T1.row_process_dtm AS "Transaction Date"
	, CASE WHEN T1.source_system_id = 24 THEN T1.prod_credit ELSE T1.current_prod_credit END AS "Productivity Credits"
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
FROM dma_vw.fact_integrated_ano_pit_vw T1

LEFT OUTER JOIN (SELECT goal_val, department_id, function_id FROM dma_vw.dma_dim_goal_pit_vw WHERE end_dt = '9999-12-31' AND goal_type_id = 5) T2
ON T1.function_id = T2.function_id AND T1.employee_department_id = T2.department_id

WHERE (work_event_department_id IN (9,11) OR employee_department_id IN (9,11))
AND T1.trans_type_id IN (1,3)
--AND CAST(T1.load_dt AS DATE)>= (Add_Months(CURRENT_DATE(), -36))
/*
FILENAME: DI OPS DAILY TRANSACTIONS
CREATED BY: John Avgoutakis
LAST UPDATED: 06/27/2023
CHANGES MADE: 
05/16/2022 - Repointed to Vertica
07/05/2023 - Added in Group Number, created Pol Num/Group Num field, added in System Name - by Bill Tiscia
*/


SELECT
	  T1.transaction_type_nm AS "Transaction Type"
	, T1.fact_integrated_natural_key_hash_uuid AS "Natural Key"
	, T1.source_transaction_id AS "Source Transaction ID"
	, T1.pol_nr AS "Policy Number"
	, CASE WHEN T1.trans_type_id = 3 THEN T1.long_completed_dt ELSE T1.report_dt END AS "Date"
	, T1.logged_dt AS "Logged Date"
	, COALESCE(T1.employee_last_nm || ', ' || T1.employee_first_nm, 'Unknown') AS "Employee"
	, COALESCE(T1.manager_last_nm || ', ' || T1.manager_first_nm , 'Unknown') AS "Manager"
	, T1.employee_role_nm AS "Employee Role Name"
	, T1.employee_team_nm AS "Team Name"
	, T1.work_event_function_nm AS "Function Name"
	, T1.work_event_segment_nm AS "Segment Name"
	, T1.work_event_nm AS "Work Event Name"
	, T1.work_event_system_nm AS "System Name"
	, T1.priority_nm AS "Priority"
	, T1.admn_sys_id AS "Admin System ID"
	, T1.admn_sys_cde AS "Admin System"
	, T1.chnl_dspy_nm AS "Service Channel Code" 
	, T1.party_type_nm AS "Party Type Name"
	, T1.ProductTypeName "Product Type Name"
	, T1.site_nm AS "Site Name"
	, T1.work_event_num AS "Work Event Number"
	, T1.expected_completed_dt AS "Expected Completed Date"
	, T1.tat AS "TAT" 
	, T1.days_past_tat AS "Days Past TAT"
	, T1.met_expected_ind AS "Met Expected Indicator"
	, T1.met_expected AS "Met Expected"
	, CASE WHEN T1.source_system_id = 24 THEN T1.prod_credit ELSE T1.current_prod_credit END AS "Productivity Credits"
	, T1.NIGO_des AS "NIGODescription"
	, T1.nigo_cd AS "NIGO Code"
	, T1.igo_ind AS "IGO Indicator"
	, T1.flex_ind AS "Flex Indicator"
	, T1.admn_sys_cde AS "Admin System Code"
	, T1.expected_completed_dt AS "Follow Up Date"
	, CAST(T1.actionable_ind AS INT) AS "Actionable Indicator"
	, CASE WHEN T1.source_transaction_id IS NULL THEN 0 ELSE 1 END AS "Completed Flag"
	, T1.sht_cmnt_des AS "Comments"
	, T1.row_process_dtm AS "Transaction Date"
	, trim(t2.group_num) as 'Group Number'
	, case 
		when T1.pol_nr is null and t2.group_num is not null then trim(t2.group_num)
		when T1.pol_nr = '-99' and t2.group_num is not null then trim(t2.group_num)
		else T1.pol_nr 
		END as 'Policy / Group #'
FROM dma_vw.fact_integrated_dio_pit_vw T1
left join (select distinct source_transaction_id, group_num from dma_vw.dipms_curr_pend_vw) t2 on T1.source_transaction_id = t2.source_transaction_id
WHERE "Date" >= (Current_Date - INTERVAL '3' MONTH)
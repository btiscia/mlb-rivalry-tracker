/*
FILENAME: DI CLAIMS HISTORICAL DETAILS CURRENT
CREATED BY: John Avgoutakis
LAST UPDATED: 03/05/2024
CHANGES MADE: 
01/25/2023 - Pointed to Vertica and added item_count, added admin system field - Jess Madru
03/05/2024 - added channel field - Bill Tiscia
*/

SELECT
	  T1.transaction_type_nm AS "Transaction Type"
	, T1.row_process_dtm AS "Transaction Date"
	, T1.source_transaction_id AS "Source Transaction ID"
	, T1.fact_integrated_natural_key_hash_uuid AS "Natural Key"
	, T1.short_claim_num AS "Short Claim Number"
	, base_claim_num AS "Base Claim Number"
	, T1.claim_num AS "Claim Number"
	, T1.admin_sys AS "Admin System"
	, T1.report_dt AS "Date"
	, T1.employee_role_nm AS "Employee Role Name"
	, COALESCE(T1.employee_last_nm || ', ' || T1.employee_first_nm, 'Unknown') AS "Employee"
	, COALESCE(T1.manager_last_nm || ', ' || T1.manager_first_nm , 'Unknown') AS "Manager"
	, T1.employee_team_nm AS "Team Name"
	, T1.work_event_function_nm AS "Function Name"
	, T1.work_event_segment_nm AS "Segment Name"
	, T1.work_event_nm AS "Work Event Name"	
	, T1.source_system_nm AS "System Name"	
	, T1.employee_organization_nm AS "Employee Organization Name"
	, T1.employee_department_nm AS "Employee Department Name"	
	, T1.work_event_organization_nm AS "Work Event Organization Name"
	, T1.work_event_department_nm AS "Work Event Department Name"	
	, T1.work_event_primary_role_nm AS "Primary Role Name"
	, T1.work_event_num AS "Work Event Number"
	, T1.department_cd AS "Department Code"
	, T1.division_cd AS "Division Code"		
	, T1.logged_by_team_party_id AS "Logged By Team Party ID"
	, T1.logged_by_party_employee_id AS "Logged By Party Employee ID"
	, CASE WHEN T1.trans_type_id = 2 THEN COALESCE(T1.demand_credit,T1.prod_credit) ELSE T1.prod_credit END AS "Productivity Credits"	
	, T1.tat AS "TAT" 	
	, T1.work_event_department_id AS WorkEventDepartmentID
	, 1 AS "Transaction Count"	
	, T1.tat AS "Total TAT Days"	
	,CASE WHEN T1.trans_type_id = 3 THEN 
	  	  CASE WHEN T1.work_event_met_expected_ind = 1 AND T1.met_expected = 1 THEN 1 ELSE 0 END   
		   	   WHEN T1.trans_type_id = 2 THEN 
	  	  CASE WHEN T1.work_event_met_expected_ind = 1 AND T1.days_past_tat <= 0 THEN 1 ELSE 0 END   
	END AS "Met Expected Count"
	, CASE WHEN T1.trans_type_id = 3 or T1.trans_type_id = 2 THEN 1 ELSE 0 
	END AS "Met Expected Ind Count"	
	, CASE WHEN T1.days_past_tat <= 0 THEN 1 ELSE 0 END AS "Met TAT Count"
	, CASE WHEN T1.days_past_tat = 1 THEN 1 ELSE 0 END AS "Past TAT 1"
	, CASE WHEN T1.days_past_tat = 2 THEN 1 ELSE 0 END AS "Past TAT 2"
	, CASE WHEN T1.days_past_tat = 3 THEN 1 ELSE 0 END AS "Past TAT 3"
	, CASE WHEN T1.days_past_tat >= 4 THEN 1 ELSE 0 END AS "Past TAT 4+"	
	, CASE WHEN upper(T1.source_system_nm) = 'CATS' THEN 'CATS'
		   WHEN upper(T1.system_department_nm) = 'DIARY'THEN 'DIBS Diary'
		   WHEN upper(T1.system_department_nm) = 'PAYMENT'THEN 'DIBS Payment'
		   WHEN upper(T1.system_department_nm) = 'TREX CONTENT CLOSURE LETTER'THEN 'TREX Closure Letter'
		   WHEN upper(T1.system_department_nm) = 'TREX CONTENT STATUS LETTER'THEN 'TREX Status Letter'
		   WHEN upper(T1.system_department_nm) = 'TREX CONTENT'THEN 'TREX Content'
		   WHEN upper(T1.system_department_nm) = 'TREX MAIL'THEN 'TREX Mail'
		   WHEN upper(T1.system_department_nm) = 'TREX WORK'THEN 'TREX Work'
		   WHEN upper(T1.source_system_nm) = 'MEDVOC'THEN 'MEDVOC'	
	  ELSE 'UNKNOWN' END AS "Processing System"		
    , COALESCE(T1.logged_by_employee_last_nm || ', ' || T1.logged_by_employee_first_nm, 'Unknown') AS "Logged by Employee" 
	, T1.medical_review_rnl AS "Medical Review"
	, CAST(T1.medical_review_support_dt AS DATE) AS "Medical Review Support Date"
	, T1.received_dt AS "Received Date"
	, T1.completed_dt AS "Completed Date"
	, T1.check_dt AS "Payment Check Date"
	, T1.dibs_customer_nm AS "Claimant Name"
	, T1.priority_nm AS "Priority Name"	
	, CASE WHEN T1.mmsd_ind = True THEN 'MMSD' ELSE 'MMFA' END AS "Channel"
	--No Longer Needed EOD Pending Indicator
FROM dma_vw.fact_integrated_dic_curr_vw T1
WHERE (T1.restricted_row_ind = 0 OR T1.restricted_row_ind IS NULL)
AND (T1.work_event_department_id = 6 OR T1.employee_department_id  = 6)
AND "Date" >= CURRENT_DATE - INTERVAL '3' YEAR
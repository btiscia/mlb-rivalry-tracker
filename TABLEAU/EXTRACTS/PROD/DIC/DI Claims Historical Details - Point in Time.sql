/*
FILENAME: DI CLAIMS HISTORICAL DETAILS - POINT IN TIME
CREATED BY: Jess Madru
LAST UPDATED: 03/05/2024
CHANGES MADE:  
01/26/2023 - Pointed to Vertica, added Admin System field
10/05/2023 - Added fields for Work Distribution Reporting
10/20/2023 - Logged by now in mart removed join to dma_vw.dma_dim_employee_pit_vw AS T4
03/05/2024 - added channel field - Bill Tiscia
*/

SELECT
	  T1.transaction_type_nm AS "Transaction Type"
	, T1.row_process_dtm AS "Transaction Date"
	, T1.source_transaction_id AS "Source Transaction ID"
	, T1.fact_integrated_natural_key_hash_uuid AS "Natural Key"
	, T1.short_claim_num AS "Short Claim Number"
	, T1.base_claim_num AS "Base Claim Number"
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
	, T1.work_event_department_id AS "Work Event Department ID"
	, 1 AS "Transaction Count"
	, T1.tat AS "Total TAT Days"
	,CASE WHEN T1.trans_type_id = 3 THEN 
	  	  CASE WHEN T1.work_event_met_expected_ind = 1 AND T1.met_expected = 1 THEN 1 ELSE 0 END   
		   	   WHEN T1.trans_type_id = 2 THEN 
	  	  CASE WHEN T1.work_event_met_expected_ind = 1 AND T1.days_past_tat <= 0 THEN 1 ELSE 0 END   
	END AS "Met Expected Count"
	, CASE WHEN T1.trans_type_id = 3 OR T1.trans_type_id = 2 THEN T1.work_event_met_expected_ind END AS "Met Expected Ind Count"
	, CASE WHEN T1.days_past_tat <= 0 THEN 1 ELSE 0 END AS "Met TAT Count"
	, CASE WHEN T1.days_past_tat = 1 THEN 1 ELSE 0 END AS "Past TAT 1"
	, CASE WHEN T1.days_past_tat = 2 THEN 1 ELSE 0 END AS "Past TAT 2"
	, CASE WHEN T1.days_past_tat = 3 THEN 1 ELSE 0 END AS "Past TAT 3"
	, CASE WHEN T1.days_past_tat >= 4 THEN 1 ELSE 0 END AS "Past TAT 4+"
	, CASE WHEN T1.work_event_group_id = 8  THEN 1 ELSE 0 END "Referral Indicator"
	, CASE WHEN T3.filter_group IS NOT NULL THEN 1 ELSE 0 END "TAT Indicator"
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
	, T1.days_past_tat AS "Days Past TAT"
	, T1.work_event_group_id AS "Work Event Group ID"
	, T1.work_event_group_nm AS "Work Event Group Name"
	, T1.work_event_group_type_nm AS "Work Event Group Type Name"
	, T1.role_grade_nm AS "Employee Role Grade Name"
	, CASE 
		when T1.role_grade_id = 14 then 'Bot'
     	when T1.party_type_id = 2  then 'System Acct'
     	when (T1.employee_department_id = 51 or (COALESCE(T1.employee_department_id, -99) = -99 and lower(T1.mmid) like 'ot%')) and T1.party_type_id <> 2 then 'Hyderabad Employee'
    	when (T1.employee_department_id NOT IN (51, -99) or (COALESCE(T1.employee_department_id, -99) = -99 and left(lower(T1.mmid),2) in ('mm', 'ct'))) and T1.party_type_id <> 2 then 'US Employee'
     	else 'Unknown' 
	 end as "Completed By Type"
     , COALESCE(T1.logged_by_employee_last_nm || ', ' || T1.logged_by_employee_first_nm, 'Unknown') AS 'Logged By'        
    --, COALESCE(T4.employee_last_nm || ', ' || T4.employee_first_nm, 'Unknown') AS 'Logged By'
    , CASE WHEN T1.mmsd_ind = True THEN 'MMSD' ELSE 'MMFA' END AS "Channel"
FROM dma_vw.fact_integrated_dic_pit_vw T1
--LEFT OUTER JOIN dma_vw.dma_dim_employee_pit_vw AS T4 ON T1.logged_by_team_party_id = T4.team_party_id
LEFT JOIN (SELECT * FROM dma_vw.dma_rel_filter_conv_vw WHERE filter_group =30) T3 ON T1.work_event_id = T3.search_id
WHERE (T1.restricted_row_ind = 0 OR T1.restricted_row_ind IS NULL)
AND (T1.work_event_department_id = 6 OR T1.employee_department_id  = 6)
AND "Date" >= CURRENT_DATE - INTERVAL '3' YEAR
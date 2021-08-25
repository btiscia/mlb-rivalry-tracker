select T1.transaction_type_nm
	, T1.source_transaction_id 
	, T1.agreement_nr 
	, T1.report_dt
	, T1.employee_role_nm 
	, COALESCE(employee_last_nm || ', ' || employee_first_nm, 'Unknown') AS 'Employee'
	, COALESCE(manager_last_nm || ', ' || manager_first_nm , 'Unknown') AS 'Manager'
	, T1.employee_team_nm 
	, T1.work_event_function_nm 
	, T1.work_event_segment_nm 
	, T1.work_event_nm 
	, T1.priority_nm 
	, T1.admn_sys_cde 
	, T1.process_nm
	, T1.process_id
	, T1.process_order
	, T1.chnl_dspy_nm 
	, T1.party_type_nm 
	, T1.employee_department_nm 
	, T1.employee_organization_nm 
	, T1.site_nm 
	, T1.work_event_department_nm 
	, T1.work_event_organization_nm 
	, T1.work_event_primary_role_nm 
	, T1.work_event_system_nm 
	, T1.work_event_num 
	, T1.department_cd 
	, T1.division_cd 
	, T1.tat 
	, T1.NIGO_des 
	, T1.row_process_dtm 
	, T1.sht_cmnt_des 
	, CASE WHEN T1.met_expected_ind = 1 AND days_past_tat <= 0 THEN 1 ELSE 0 END AS met_expected_ct
	, T1.met_expected_ind 
	, T1.current_prod_credit 
	, CASE WHEN igo_ind = 1 AND nigo_cd = '-99' THEN 1 ELSE 0 END AS nigo_ct
	, CASE WHEN igo_ind = 1 AND nigo_cd = '090' THEN 1 ELSE 0 END AS igo_ct
	, T1.igo_ind 
	, T2.goal_val
	, flex_ind 
	, CASE WHEN days_past_tat <= 0 THEN 1 ELSE 0 END AS met_tat_ct
	, CASE WHEN days_past_tat = 1 THEN 1 ELSE 0 END AS past_tat_1
	, CASE WHEN days_past_tat = 2 THEN 1 ELSE 0 END AS past_tat_2
	, CASE WHEN days_past_tat = 3 THEN 1 ELSE 0 END AS past_tat_3
	, CASE WHEN days_past_tat >= 4 THEN 1 ELSE 0 END AS past_tat_4_up
from dma_vw.fact_integrated_psc_curr_vw T1
left join (SELECT * FROM dma.dma_dim_goal_curr WHERE goal_type_id = 5) T2 ON T1.work_event_function_id = T2.function_id AND T1.employee_department_id = T2.department_id 
where (T1.work_event_department_id = 5 OR T1.employee_department_id = 5)

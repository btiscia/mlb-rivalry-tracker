

/*
FILENAME: LPI CURRENT PENDING INVENTORY - VERTICA TESTING
CREATED BY: John Avgoutakis
*/

SELECT 
--ref_wrk_ident_natural_key_hash_uuid
 source_transaction_id AS SourceTransactionID
--, ref_party_natural_key_hash_uuid
--, employee_first_nm || ' ' || employee_last_nm AS Employee
, employee_nm AS Employee
--, ref_org_natural_key_hash_uuid
--, ref_department_natural_key_hash_uuid
--, ref_role_natural_key_hash_uuid
, organization_nm AS EmployeeOrganizationName  
, department_nm AS EmployeeDepartmentName
, role_nm AS Role
--, manager_last_nm
--, manager_first_nm
, manager_nm AS Manager
, team_nm AS 'Team Name'
--, ref_work_event_natural_key_hash_uuid
, work_event_nm as 'Work Event'
--, ref_work_event_org_natural_key_hash_uuid
--, ref_work_event_department_natural_key_hash_uuid
, employee_department_id AS EmployeeDepartmentID
, employee_role_id AS EmployeeRoleID
, work_event_organization_nm AS WorkEventOrganizationName
, work_event_department_nm AS WorkEventDepartmentName
, function_nm AS FunctionName --had to add "Name" because of vertica
, segment_nm AS Segment
--, insured_last_nm
--, insured_first_nm
--, insured_middle_nm
, insured_nm AS "Insured's Name"
, pol_nr AS 'Policy Number'
--, fk_wrk_evntevnt_nr
--, fk_rsrcusr_ident
--, apm_grp_ident
, rcvd_dt AS 'Received Date'
, expected_completed_dt AS 'Target Complete Date'
, cats_expected_completed_dt AS 'CATS Expected Completed Date'
, days_pending AS 'Days Pending'
, days_past_tat AS 'Days Past TAT'
, tat_goal AS 'TAT Goal'
, prod_credit AS 'Productivity Credits'
, bcc_ind AS 'Society 1851'
, sht_cmnt_des AS Comments
--, fk_svcchnl_src_cde
, chnl_dspy_nm AS ChannelDisplayName
--, ref_admn_sys_id_key_hash_uuid
, admn_sys_cde AS AdminSystemCode
--, fk_div_cde
--, fk_dept_cde
, system_division_nm AS SystemDivisionName
, system_department_nm AS SystemDepartmentName
, log_dt AS LoggedDate
, group_nm AS GroupName
, group_type_nm AS GroupTypeName
--, begin_dt
--, begin_dtm
--, row_process_dtm
--, audit_id
--, check_sum
--, current_row_ind
--, end_dt
--, end_dtm
--, source_system_id
--, restricted_row_ind
--, update_audit_id
FROM dma_vw.rpt_cats_curr_pend_vw
WHERE employee_department_id = 5
OR employee_role_id = 5
AND function_nm <> 'Flags/Blockers'
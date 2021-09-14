/*
FILENAME: Advisor Ops CURRENT PENDING INVENTORY
CREATED BY: John Avgoutakis
LAST UPDATED: 09/14/2021
CHANGES MADE: Updated Group Number, Added policy number and group number fields.
*/

SELECT 
 source_transaction_id AS SourceTransactionID
 ,party_employee_id
, employee_nm AS Employee
, organization_nm AS EmployeeOrganizationName  
, department_nm AS EmployeeDepartmentName
, role_nm AS Role
, manager_nm AS Manager
, team_nm AS 'Team Name'
, work_event_nm as 'Work Event'
, employee_department_id AS EmployeeDepartmentID
, employee_role_id AS EmployeeRoleID
, work_event_organization_nm AS WorkEventOrganizationName
, work_event_department_nm AS WorkEventDepartmentName
, function_nm AS FunctionName --had to add "Name" because of vertica
, segment_nm AS Segment
, insured_last_nm AS "Insured's Name"
, pol_nr AS 'Policy Number'
, apm_grp_ident AS 'Group Number'
,CASE WHEN 
	pol_nr IS NULL AND apm_grp_ident IS NOT NULL 
	THEN apm_grp_ident 
	ELSE pol_nr
	END AS "Policy / Group #"
, rcvd_dt AS 'Received Date'
, expected_completed_dt AS 'Target Complete Date'
, cats_expected_completed_dt AS 'CATS Expected Completed Date'
, days_pending AS 'Days Pending'
, days_past_tat AS 'Days Past TAT'
, tat_goal AS 'TAT Goal'
, prod_credit AS 'Productivity Credits'
, bcc_ind AS 'Society 1851'
, sht_cmnt_des AS Comments
, chnl_dspy_nm AS 'Service Channel'
, admn_sys_cde AS 'Admin System'
, system_division_nm AS 'Line of Business'
, system_department_nm AS SystemDepartmentName
, log_dt AS LoggedDate
, group_nm AS GroupName
, group_type_nm AS GroupTypeName
, row_process_dtm AS 'Trans Date'
FROM dma_vw.rpt_cats_curr_pend_vw
WHERE (employee_department_id = 48
OR work_event_department_id = 48)
AND COALESCE(function_nm,'Unknown') <> 'Flags/Blockers'
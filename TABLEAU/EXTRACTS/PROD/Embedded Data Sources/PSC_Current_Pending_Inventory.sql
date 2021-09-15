/*
FILENAME: PSC CURRENT PENDING INVENTORY
CREATED BY: John Avgoutakis
LAST UPDATED: 08/24/2021
CHANGES MADE: Created.
*/

SELECT 
 source_transaction_id AS SourceTransactionID
, employee_nm AS Employee
, organization_nm AS EmployeeOrganizationName  
, department_nm AS EmployeeDepartmentName
, role_nm AS Role
, manager_nm AS Manager
, team_nm AS "Team Name"
, work_event_nm as "Work Event"
, employee_department_id AS EmployeeDepartmentID
, employee_role_id AS EmployeeRoleID
, work_event_organization_nm AS WorkEventOrganizationName
, work_event_department_nm AS WorkEventDepartmentName
, function_nm AS FunctionName --had to add "Name" because of vertica
, segment_nm AS Segment
, insured_nm AS "Insured's Name"
, pol_nr AS "Policy Number"
, rcvd_dt AS "Received Date"
, expected_completed_dt AS "Target Complete Date"
, cats_expected_completed_dt AS "CATS Expected Completed Date"
, days_pending AS "Days Pending"
, days_past_tat AS "Days Past TAT"
, tat_goal AS "TAT Goal"
, prod_credit AS "Productivity Credits"
, bcc_ind AS "Society 1851"
, sht_cmnt_des AS Comments
, chnl_dspy_nm AS ChannelDisplayName
, admn_sys_cde AS AdminSystemCode
, system_division_nm AS SystemDivisionName
, system_department_nm AS SystemDepartmentName
, log_dt AS LoggedDate
, group_nm AS GroupName
, group_type_nm AS GroupTypeName
, row_process_dtm AS "Trans Date"
,CASE WHEN 
	pol_nr IS NULL AND group_nm IS NOT NULL 
	THEN group_nm 
	ELSE pol_nr
	END AS "Policy / Group #"
FROM dma_vw.rpt_cats_curr_pend_vw
WHERE (employee_department_id = 4
OR work_event_department_id = 4)
AND function_nm <> 'Flags/Blockers'
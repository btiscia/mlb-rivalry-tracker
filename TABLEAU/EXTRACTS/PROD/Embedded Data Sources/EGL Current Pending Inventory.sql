/*
FILENAME: EGL CURRENT PENDING INVENTORY
CREATED BY: He who shall not be named.
LAST UPDATED: 4/22/2024
CHANGES MADE: Changed work_event_department_id to 12 and removed the employee_organization_id filter.
*/

SELECT 
  source_transaction_id AS SourceTransactionID
, employee_nm AS Employee
, organization_nm AS EmployeeOrganizationName 
, employee_organization_id AS "Org ID" 
, department_nm AS EmployeeDepartmentName
, role_nm AS Role
, manager_nm AS Manager
, team_nm AS "Team Name"
, work_event_nm as "Work Event"
, employee_department_id AS EmployeeDepartmentID
, employee_role_id AS EmployeeRoleID
, work_event_organization_nm AS WorkEventOrganizationName
, work_event_department_nm AS WorkEventDepartmentName
, function_nm AS FunctionName
, segment_nm AS Segment
, insured_last_nm AS "Insured's Name"
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

FROM dma_vw.rpt_cats_curr_pend_vw
WHERE (employee_department_id = 12
OR work_event_department_id = 12)
AND COALESCE(function_nm,'Unknown') <> 'Flags/Blockers'
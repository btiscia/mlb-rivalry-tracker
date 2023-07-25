/*
FILENAME: HYDERABAD CURRENT PENDING INVENTORY
UPDATED BY: Jess Madru
LAST UPDATED: 7/10/2023
CHANGES MADE: Updated to add DIPMS data
*/

SELECT 
 source_transaction_id AS SourceTransactionID
, party_employee_id
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
, insured_last_nm AS "Insured's Name"
, pol_nr AS "Policy Number"
, apm_grp_ident AS "Group Number"
, CASE WHEN 
	pol_nr IS NULL AND apm_grp_ident IS NOT NULL 
	THEN apm_grp_ident 
	ELSE pol_nr
	END AS "Policy / Group #"
, rcvd_dt AS "Received Date"
, expected_completed_dt AS "Target Complete Date"
, cats_expected_completed_dt AS "Expected Completed Date"
, days_pending AS "Days Pending"
, days_past_tat AS "Days Past TAT"
, tat_goal AS "TAT Goal"
, prod_credit AS "Productivity Credits"
, case when bcc_ind is true then 'Y'
  else 'N' end  as "Society 1851"
, sht_cmnt_des AS Comments
, chnl_dspy_nm AS "Service Channel"
, admn_sys_cde AS "Admin System"
, system_division_nm AS "Line of Business"
, system_department_nm AS SystemDepartmentName
, log_dt AS LoggedDate
, group_nm AS GroupName
, group_type_nm AS GroupTypeName
, 'CATS' as "Data Source"
, row_process_dtm AS "Trans Date"
FROM dma_vw.rpt_cats_curr_pend_vw
WHERE (employee_department_id = 51
OR work_event_department_id = 51)
AND team_nm NOT IN ('Data Management and CRM', 'Learning & Performance', 'Business Content Management & Communications')
UNION
select
source_transaction_id as SourceTransactionID,
party_employee_id,
employee_nm as Employee,
employee_organization_nm as EmployeeOrganizationName,
employee_department_nm as EmployeeDepartmentName,
employee_role_nm as Role,
manager_nm as Manager,
team_nm as "Team Name",
work_event_nm as "Work Event",
employee_department_id as EmployeeDepartmentID,
employee_role_id EmployeeRoleID,
work_event_organization_nm as WorkEventOrganizationName,
work_event_department_nm as WorkEventDepartmentName,
function_nm as FunctionName,
segment_nm as Segment,
insured_last_nm as "Insured's Name",
pol_nr as "Policy Number",
group_num as "Group Number",
CASE WHEN 
	pol_nr IS NULL AND group_num IS NOT NULL 
	THEN group_num 
	ELSE pol_nr
	END AS "Policy / Group #",
cast(received_dt as date) as "Received Date",
cast(expected_completed_dt as date) as "Target Complete Date",
cast(source_expected_completed_dt as date) as "Expected Complete Date", 
days_pending as "Days Pending",
days_past_tat as "Days Past TAT",
tat_goal as "TAT Goal",
prod_credit as "Productivity Credits",
case when bcc_ind is NULL then 'N'
  else 'Y' end  as "Society 1851",
short_comments as Comments,
chnl_dspy_nm as "Service Channel",
admn_sys_cde as "Admin System",
system_division_nm as "Line of Business",
system_department_nm as "SystemDepartmentName",
log_dt as LoggedDate,
NULL as GroupName,
group_type_nm as GroupTypeName,
'DIPMS' as "Data Source",
row_process_dtm as "Trans Date"
from dma_vw.dipms_curr_pend_vw   
WHERE (employee_department_id = 51
OR work_event_department_id = 51)
AND team_nm NOT IN ('Data Management and CRM', 'Learning & Performance', 'Business Content Management & Communications')
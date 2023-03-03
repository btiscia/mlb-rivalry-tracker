/*
FILENAME: LIFE AND ANNUITY CURRENT PENDING INVENTORY
CREATED BY: John Avgoutakis
LAST UPDATED: 11/15/2022
CHANGES MADE: 09/16/2021 - Created
11/15/2022 - Added in product_type_desc
3/2/2023 - Added in face_amt
*/

SELECT 
 source_transaction_id AS SourceTransactionID
 ,party_employee_id
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
, pol_nr AS "Policy Number"
, apm_grp_ident AS "Group Number"
,CASE WHEN 
	pol_nr IS NULL AND apm_grp_ident IS NOT NULL 
	THEN apm_grp_ident 
	ELSE pol_nr
	END AS "Policy / Group #"
,CASE WHEN  sht_cmnt_des Like '%DNT%'
	THEN 'DNT' ELSE 'Non DNT'
	END AS "DNT Indicator"
, initcap(product_type_desc) AS "Product"
, face_amt AS "Face Amount"
FROM dma_vw.rpt_cats_curr_pend_vw
WHERE (employee_department_id IN (7,8)
OR work_event_department_id IN (7,8))
AND COALESCE(function_nm,'Unknown') <> 'Flags/Blockers'
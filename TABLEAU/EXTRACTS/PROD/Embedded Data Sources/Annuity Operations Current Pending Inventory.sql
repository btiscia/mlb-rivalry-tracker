/*
FILENAME: ANNUITY OPERATIONS CURRENT PENDING INVENTORY
CREATED BY: John Avgoutakis
LAST UPDATED: 09/22/2021
CHANGES MADE: Created.
*/

SELECT  
  T1.source_transaction_id AS SourceTransactionID
, T1.party_employee_id
, T1.employee_nm AS Employee
, T1.organization_nm AS EmployeeOrganizationName  
, T1.department_nm AS EmployeeDepartmentName
, T1.role_nm AS Role
, T1.manager_nm AS Manager
, T1.team_nm AS "Team Name"
, T1.work_event_nm as "Work Event"
, T1.employee_department_id AS EmployeeDepartmentID
, T1.employee_role_id AS EmployeeRoleID
, T1.work_event_organization_nm AS WorkEventOrganizationName
, T1.work_event_department_nm AS WorkEventDepartmentName
, T1.function_nm AS FunctionName --had to add "Name" because of vertica
, T1.segment_nm AS Segment
, T1.insured_last_nm AS "Insured's Name"
, pol_nr AS "Policy Number"
, apm_grp_ident AS "Group Number"
,CASE WHEN pol_nr IS NULL AND apm_grp_ident IS NOT NULL 
    THEN apm_grp_ident 
    ELSE pol_nr END AS "Policy / Group #"
,CASE
    WHEN T1.group_nm = 'Internal Replacement' THEN 'High'
    WHEN T1.major_prod_nm = 'Ann&&Va' AND T1.group_nm = 'Gain/Loss' THEN  'High'
    WHEN T1.major_prod_nm = 'Ann&&Va' AND T1.group_nm = 'Conditional Gain/Loss' THEN  'High'
    WHEN T1.major_prod_nm = 'Ann&&Va' AND T1.group_nm = 'No Gain/Loss' THEN 'Low'
    WHEN T1.major_prod_nm = 'Ann&&Fa' AND T1.group_nm = 'No Gain/Loss' THEN 'Medium'
    WHEN T1.major_prod_nm = 'Ann&&Fa' AND T1.group_nm = 'Conditional Gain/Loss' THEN  'Medium'
    ELSE 'Low' 
END AS Priority    
    
,CASE
    WHEN T1.group_nm = 'Internal Replacement' THEN 1
    WHEN T1.major_prod_nm = 'Ann&&Va' AND T1.group_nm = 'Gain/Loss' THEN 1
    WHEN T1.major_prod_nm = 'Ann&&Va' AND T1.group_nm = 'Conditional Gain/Loss' THEN 1
    WHEN T1.major_prod_nm = 'Ann&&Va' AND T1.group_nm = 'No Gain/Loss' THEN 3
    WHEN T1.major_prod_nm = 'Ann&&Fa' AND T1.group_nm = 'No Gain/Loss' THEN 2
    WHEN T1.major_prod_nm = 'Ann&&Fa' AND T1.group_nm = 'Conditional Gain/Loss' THEN 2
    ELSE 3 
END    AS "Priority Order"
, T1.rcvd_dt AS "Received Date"
, T1.expected_completed_dt AS "Target Complete Date"
, T1.cats_expected_completed_dt AS "CATS Expected Completed Date"
, T1.days_pending AS "Days Pending"
, T1.days_past_tat AS "Days Past TAT"
, T1.tat_goal AS "TAT Goal"
, T1.prod_credit AS "Productivity Credits"
, T1.bcc_ind AS "Society 1851"
, T1.sht_cmnt_des AS Comments
, T1.chnl_dspy_nm AS "Service Channel"
, T1.admn_sys_cde AS "Admin System"
, T1.system_division_nm AS "Line of Business"
, T1.system_department_nm AS SystemDepartmentName
, T1.log_dt AS LoggedDate
, T1.group_nm AS GroupName
, T1.group_type_nm AS GroupTypeName
, T1.row_process_dtm AS "Trans Date"
, T1.major_prod_nm AS MajorProductName
FROM dma_vw.rpt_cats_curr_pend_vw T1
WHERE (T1.employee_department_id = 11 OR T1.work_event_department_id = 11)
AND (COALESCE(T1.function_nm,'Unknown') <> 'Flags/Blockers' or T1.function_nm IS NULL)
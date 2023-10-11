/*
FILENAME: DI WORKSITE CURRENT PENDING INVENTORY
CREATED BY: BILL TISCIA 07/11/2023
LAST UPDATED: 08/08/2023
CHANGES MADE: 
08/08/2023 - Code creation
*/

SELECT
t1.source_transaction_id,
t1.party_employee_id,
CONCAT((t1.employee_last_nm||', '),t1.employee_first_nm) AS 'employee_nm',
t1.employee_organization_id,
t1.organization_nm,
t1.employee_department_id,
t1.department_nm,
t1.employee_role_id,
t1.role_nm,
CONCAT((t1.manager_last_nm||', '),t1.manager_first_nm) AS 'manager_nm',
t1.team_nm,
t1.work_event_nm,
t1.work_event_ORganization_id,
t1.work_event_ORganization_nm,
t1.work_event_department_id,
t1.work_event_department_nm,
t1.function_nm,
t1.segment_nm,
t1.insured_last_nm,
t1.insured_first_nm,
t1.insured_middle_nm,
TRIM(TRIM(LEADING '0' FROM t1.pol_nr)) AS 'pol_nr',
TRIM(t1.apm_grp_ident) AS 'group_num',
CAST(t1.rcvd_dt AS DATE) AS 'Received Date',
CAST(t1.expected_completed_dt AS DATE) AS 'expected_completed_dt',
CAST(t1.cats_expected_completed_dt AS DATE) AS 'source_expected_completed_dt',
t1.days_pending,
t1.days_past_tat,
CASE WHEN t1.days_past_tat > 0 THEN 'Past TAT' ELSE 'Within TAT' END AS 'Past TAT Flag',
CASE WHEN t1.days_past_tat > 10 THEN '11+ Days Past Due'
WHEN t1.days_past_tat = 1 THEN '1 Day Past Due'
WHEN t1.days_past_tat = 2 THEN '2 Days Past Due'
WHEN t1.days_past_tat = 3 THEN '3 Days Past Due'
WHEN t1.days_past_tat = 4 THEN '4 Days Past Due'
WHEN t1.days_past_tat = 5 THEN '5 Days Past Due'
WHEN t1.days_past_tat >= 6 AND t1.days_past_tat < 11 THEN '6-10 Days Past Due'
WHEN t1.days_past_tat = 0 THEN 'Due Today'
WHEN t1.days_past_tat = -1 THEN 'Due Tomorrow'
WHEN t1.days_past_tat = -2 THEN 'Due In 2 Days'
WHEN t1.days_past_tat = -3 THEN 'Due In 3 Days' 
WHEN t1.days_past_tat = -4 THEN 'Due In 4 Days'
WHEN t1.days_past_tat = -5 THEN 'Due In 5 Days'
WHEN t1.days_past_tat <= -6 OR t1.days_past_tat IS NULL THEN 'Due In 6+ Days'
END AS 'Pending Buckets',
t1.tat_goal,
t1.prod_credit,
t1.sht_cmnt_des,
t1.chnl_dspy_nm,
t1.admn_sys_cde,
CAST(t1.source_system_id AS INT) AS 'source_system_id',
t1.log_dt,
t1.group_type_nm,
NULL AS group_id,
NULL AS major_prod_nm,
CASE WHEN t1.bcc_ind=0 THEN'N'
  WHEN t1.bcc_ind=1 THEN 'Y'
   END AS 'Society 1851',
CASE WHEN t1.pol_nr IS NULL AND t1.apm_grp_ident  IS NOT NULL THEN TRIM(t1.apm_grp_ident ) ELSE TRIM(TRIM(LEADING '0' FROM t1.pol_nr)) END AS 'Policy / Group #',
t1.row_process_dtm,
t2.system_nm AS 'Data Source'
FROM dma_vw.rpt_cats_curr_pend_vw t1
LEFT JOIN (SELECT DISTINCT ref_work_event_natural_key_hash_uuid, system_nm FROM dma_vw.dma_dim_work_curr_vw) t2 ON t1.ref_work_event_natural_key_hash_uuid = t2.ref_work_event_natural_key_hash_uuid
WHERE (t1.employee_department_id = 3 OR t1.work_event_department_id = 3) AND (t1.function_nm <> 'Flags/Blockers' OR t1.function_nm IS NULL)

UNION

SELECT
t1.source_transaction_id,
t1.party_employee_id,
t1.employee_nm,
t1.employee_ORganization_id,
t1.employee_ORganization_nm,
t1.employee_department_id,
t1.employee_department_nm,
t1.employee_role_id,
t1.employee_role_nm,
t1.manager_nm,
t1.team_nm,
t1.work_event_nm,
t1.work_event_ORganization_id,
t1.work_event_ORganization_nm,
t1.work_event_department_id,
t1.work_event_department_nm,
t1.function_nm,
t1.segment_nm,
t1.insured_last_nm  ,
t1.insured_first_nm,
t1.insured_middle_nm,
TRIM(TRIM(LEADING '0' FROM t1.pol_nr)) AS 'pol_nr',
TRIM(t1.group_num) AS 'group_num',
CAST(t1.received_dt AS DATE) AS 'Received Date',
CAST(t1.expected_completed_dt AS DATE) AS 'expected_completed_dt',
CAST(t1.source_expected_completed_dt AS DATE) AS 'source_expected_completed_dt',
t1.days_pending,
t1.days_past_tat,
CASE WHEN t1.days_past_tat > 0 THEN 'Past TAT' ELSE 'Within TAT' END AS 'Past TAT Flag',
CASE WHEN t1.days_past_tat > 10 THEN '11+ Days Past Due'
WHEN t1.days_past_tat = 1 THEN '1 Day Past Due'
WHEN t1.days_past_tat = 2 THEN '2 Days Past Due'
WHEN t1.days_past_tat = 3 THEN '3 Days Past Due'
WHEN t1.days_past_tat = 4 THEN '4 Days Past Due'
WHEN t1.days_past_tat = 5 THEN '5 Days Past Due'
WHEN t1.days_past_tat >= 6 AND t1.days_past_tat < 11 THEN '6-10 Days Past Due'
WHEN t1.days_past_tat = 0 THEN 'Due Today'
WHEN t1.days_past_tat = -1 THEN 'Due Tomorrow'
WHEN t1.days_past_tat = -2 THEN 'Due In 2 Days'
WHEN t1.days_past_tat = -3 THEN 'Due In 3 Days' 
WHEN t1.days_past_tat = -4 THEN 'Due In 4 Days'
WHEN t1.days_past_tat = -5 THEN 'Due In 5 Days'
WHEN t1.days_past_tat <= -6 OR t1.days_past_tat IS NULL THEN 'Due In 6+ Days'
END AS 'Pending Buckets',
t1.tat_goal ,
t1.prod_credit,
t1.short_comments,
t1.chnl_dspy_nm,
t1.admn_sys_cde,
CAST(t1.admn_sys_id AS INT) AS 'source_system_id',
t1.log_dt,
t1.group_type_nm,
t1.group_id,
t1.majOR_prod_nm,
CASE WHEN t1.bcc_ind IS NULL  THEN'N'
  WHEN t1.bcc_ind IS NOT NULL THEN 'Y'
   END  AS 'Society 1851',
CASE WHEN t1.pol_nr IS NULL AND t1.group_num IS NOT NULL THEN TRIM(t1.group_num) ELSE TRIM(TRIM(LEADING '0' FROM t1.pol_nr)) END AS 'Policy / Group #',
t1.row_process_dtm,
t2.system_nm AS 'Data Source'
FROM dma_vw.dipms_curr_pend_vw t1
LEFT JOIN (SELECT DISTINCT dim_work_natural_key_hash_uuid, system_nm FROM dma_vw.dma_dim_work_curr_vw) t2 ON t1.dim_work_natural_key_hash_uuid = t2.dim_work_natural_key_hash_uuid
WHERE (t1.employee_department_id = 3 OR t1.work_event_department_id = 3) AND (t1.function_nm <> 'Flags/Blockers' OR t1.function_nm IS NULL)
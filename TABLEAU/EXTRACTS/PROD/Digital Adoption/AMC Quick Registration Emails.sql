/*
FILENAME: AMC Quick Registration Emails
CREATED BY: Paul Gyasi
DATE CREATED: 04/10/2023
CHANGES MADE: 
*/


SELECT
T1.amc_quick_registration_email_natural_key_hash_uuid AS fact_activity_natural_key_hash_uuid
, 41 AS system_id
, T1.message_id AS source_transaction_id
, T1.message_dtm
, CAST(T1.message_dtm as date) AS message_dt
, T1.employee_preferred_username
, UPPER(LEFT(T1.employee_preferred_username, (instr(T1.employee_preferred_username, '@')-1))) as source_mmid
, T1.event_desc
, T1.event_desc AS work_event_nm
, T1.amc_guid
, CAST(T1.message_dtm as date) AS load_dt
, CAST(T1.message_dtm as date) AS logged_dt
, CAST(T1.message_dtm as date) AS received_dt
, CAST(T1.message_dtm as date) AS completed_dt
, CAST(T1.message_dtm as date) AS report_dt
, T2.dim_employee_natural_key_hash_uuid
, T2.team_party_id
, T2.ref_party_natural_key_hash_uuid
, T2.party_employee_id
, T2.mmid
, T2.employee_last_nm
, T2.employee_first_nm
, T2.ref_party_type_natural_key_hash_uuid
, T2.party_type_id
, T2.party_type_nm
, T2.ref_role_natural_key_hash_uuid
, T2.role_id
, T2.role_nm
, T2.ref_role_grade_natural_key_hash_uuid
, T2.role_grade_id
, T2.role_grade_nm
, T2.ref_site_natural_key_hash_uuid
, T2.site_id
, T2.site_nm
, T2.ref_org_natural_key_hash_uuid
, T2.organization_id
, T2.organization_nm
, T2.ref_department_natural_key_hash_uuid
, T2.department_id
, T2.department_nm
, T2.ref_team_natural_key_hash_uuid
, T2.team_id
, T2.team_nm
, T2.parent_ref_party_natural_key_hash_uuid
, T2.parent_party_id
, T2.manager_mmid
, T2.manager_last_nm
, T2.manager_first_nm
, T2.internal
, T2.hr_id
, T2.active_ind
, T2.hire_dt
, T2.effective_dt
, T2.termination_dt
, T2.begin_dt AS employee_begin_dt
, T2.end_dt AS employee_end_dt
, cast(NULL as varchar(20)) as "LOB Name"

FROM dma_vw.dma_dim_employee_pit_vw AS T2

LEFT OUTER JOIN
dma_vw.amc_quick_registration_email_vw AS T1
ON UPPER(LEFT(T1.employee_preferred_username, (instr(T1.employee_preferred_username, '@')-1))) = UPPER(T2.mmid)
AND T1.message_dtm BETWEEN T2.begin_dt AND T2.end_dt

LIMIT 1 OVER(PARTITION BY source_mmid, message_dt, amc_guid ORDER BY message_dtm, message_id)
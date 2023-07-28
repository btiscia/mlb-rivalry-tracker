/*
FILENAME: DI WORKSITE CURRENT PENDING INVENTORY
CREATED BY: BILL TISCIA 07/11/2023
LAST UPDATED: 07/11/2023
CHANGES MADE: 
07/11/2023 - Code creation
*/

select
t1.source_transaction_id,
t1.party_employee_id,
concat((t1.employee_last_nm||', '),t1.employee_first_nm) as 'employee_nm',
t1.employee_organization_id,
t1.organization_nm,
t1.employee_department_id,
t1.department_nm,
t1.employee_role_id,
t1.role_nm,
concat((t1.manager_last_nm||', '),t1.manager_first_nm) as 'manager_nm',
t1.team_nm,
t1.work_event_nm,
t1.work_event_organization_id,
t1.work_event_organization_nm,
t1.work_event_department_id,
t1.work_event_department_nm,
t1.function_nm,
t1.segment_nm,
t1.insured_last_nm,
t1.insured_first_nm,
t1.insured_middle_nm,
t1.pol_nr,
t1.apm_grp_ident,
t1.rcvd_dt,
t1.expected_completed_dt,
t1.cats_expected_completed_dt,
t1.days_pending,
t1.days_past_tat,
t1.tat_goal,
t1.prod_credit,
t1.sht_cmnt_des,
t1.chnl_dspy_nm,
t1.admn_sys_cde,
cast(t1.source_system_id as int) as 'source_system_id',
t1.log_dt,
t1.group_type_nm,
null as group_id,
null as major_prod_nm,
case when t1.bcc_ind=0 then'N'
  when t1.bcc_ind=1 then 'Y'
   end AS 'Society 1851',
case when t1.pol_nr is null and t1.group_nm is not null then t1.group_nm else t1.pol_nr end as 'Policy / Group #',
t1.row_process_dtm,
t2.system_nm as 'Data Source'
from dma_vw.rpt_cats_curr_pend_vw t1
left join (select distinct ref_work_event_natural_key_hash_uuid, system_nm from dma_vw.dma_dim_work_curr_vw) t2 on t1.ref_work_event_natural_key_hash_uuid = t2.ref_work_event_natural_key_hash_uuid
where (t1.employee_department_id = 3) and (t1.function_nm <> 'Flags/Blockers' or t1.function_nm is null)

union

select
t1.source_transaction_id,
t1.party_employee_id,
t1.employee_nm,
t1.employee_organization_id,
t1.employee_organization_nm,
t1.employee_department_id,
t1.employee_department_nm,
t1.employee_role_id,
t1.employee_role_nm,
t1.manager_nm,
t1.team_nm,
t1.work_event_nm,
t1.work_event_organization_id,
t1.work_event_organization_nm,
t1.work_event_department_id,
t1.work_event_department_nm,
t1.function_nm,
t1.segment_nm,
t1.insured_last_nm  ,
t1.insured_first_nm,
t1.insured_middle_nm,
trim(t1.pol_nr) as 'pol_nr',
trim(t1.group_num) as 'group_num',
cast(t1.received_dt as date) as 'received_dt',
cast(t1.expected_completed_dt as date) as 'expected_completed_dt',
cast(t1.source_expected_completed_dt as date) as 'source_expected_completed_dt',
t1.days_pending,
t1.days_past_tat,
t1.tat_goal ,
t1.prod_credit,
t1.short_comments,
t1.chnl_dspy_nm,
t1.admn_sys_cde,
cast(t1.admn_sys_id as int) as 'source_system_id',
t1.log_dt,
t1.group_type_nm,
t1.group_id,
t1.major_prod_nm,
case when t1.bcc_ind is null  then'N'
  when t1.bcc_ind is not null then 'Y'
   end  as 'Society 1851',
case when t1.pol_nr is null and t1.group_num is not null then trim(t1.group_num) else trim(t1.pol_nr) end as 'Policy / Group #',
t1.row_process_dtm,
t2.system_nm as 'Data Source'
from dma_vw.dipms_curr_pend_vw t1
left join (select distinct dim_work_natural_key_hash_uuid, system_nm from dma_vw.dma_dim_work_curr_vw) t2 on t1.dim_work_natural_key_hash_uuid = t2.dim_work_natural_key_hash_uuid
where (t1.employee_department_id = 3) and (t1.function_nm <> 'Flags/Blockers' or t1.function_nm is null)
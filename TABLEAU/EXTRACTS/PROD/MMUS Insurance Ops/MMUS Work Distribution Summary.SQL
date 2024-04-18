/*
FILENAME: MMUS Work Allocation Summary
CREATED BY: Nicolaus Nisula
LAST UPDATED: 04/02/2024
CHANGES MADE: New Data Source
LAST UPDATED: 
*/

SELECT -- item count on view, productivity credit includes worktracking count in data.
      t1.completed_dt as "Completed Date"
    , t3.division_cd as "Division Code"
    , t3.department_cd as "Department Code"
    , t3.department_id as "Department ID"
    , t3.department_nm as "Department Name"
    , t3.function_nm as "Function Name"
    , t3.segment_nm as "Segment Name"
    , t3.work_event_nm as "Work Event Name"
    , t3.work_event_num as "Work Event Number"
    , t3.system_nm as "System Name"
    , CASE
        when T2.role_grade_id = 14
        then 'Bot'
        when T2.party_type_id = 2
        then 'System Acct'
        when (T2.department_id = 51
            or (COALESCE(T2.department_id, -99) = -99
            and lower(T2.mmid) like 'ot%'))
            and T2.party_type_id <> 2
        then 'Hyderabad Employee'
        when (T2.department_id NOT IN (51, -99)
            or (COALESCE(T2.department_id, -99) = -99
            and left(lower(T2.mmid),2) in ('mm', 'ct')))
            and T2.party_type_id <> 2
        then 'US Employee'
        else 'Unknown'
        end as "Completed By Type"
    , t6.admn_sys_cde as "Admin System Code"
	, sum(item_count) as trans_count_wt
    , count(t1.fact_activity_natural_key_hash_uuid) as trans_count_other
    , sum(t1.prod_credit) as prod_credit
    , 0 as calculated_productivity
    , case when trans_count_wt is not null then trans_count_wt else trans_count_other end as "Transaction Count"
    , sum(t1.prod_credit) as "Productivity Credit"
FROM dma_vw.fact_integrated_psc_vw t1
JOIN dma_vw.dma_dim_employee_pit_vw t2 ON t1.team_party_id = t2.team_party_id
JOIN dma_vw.dma_dim_work_pit_vw t3 ON t1.work_id = t3.work_id
JOIN dma_vw.dma_ref_admn_sys_cde_vw T6 ON T1.ref_admn_sys_id_key_hash_uuid = T6.ref_admn_sys_id_key_hash_uuid
WHERE T1.trans_type_id in (3) AND YEAR(T1.completed_dt) >= YEAR(CURRENT_DATE) - 3 AND T3.department_id = 4
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12

UNION

SELECT -- item_ct not in ANO view and prod credits are not calculated.
      t1.completed_dt as "Completed Date"
    , t3.division_cd as "Division Code"
    , t3.department_cd as "Department Code"
    , t3.department_id as "Department ID"
    , t3.department_nm as "Department Name"
    , t3.function_nm as "Function Name"
    , t3.segment_nm as "Segment Name"
    , t3.work_event_nm as "Work Event Name"
    , t3.work_event_num as "Work Event Number"
    , t3.system_nm as "System Name"
    , CASE
        when T2.role_grade_id = 14
        then 'Bot'
        when T2.party_type_id = 2
        then 'System Acct'
        when (T2.department_id = 51
            or (COALESCE(T2.department_id, -99) = -99 
            and lower(T2.mmid) like 'ot%'))
            and T2.party_type_id <> 2
        then 'Hyderabad Employee'
        when (T2.department_id NOT IN (51, -99)
            or (COALESCE(T2.department_id, -99) = -99
            and left(lower(T2.mmid),2) in ('mm', 'ct')))
            and T2.party_type_id <> 2
        then 'US Employee'
        else 'Unknown'
        end as "Completed By Type"
    , t6.admn_sys_cde as "Admin System Code"
	, sum(item_ct) as trans_count_wt
    , count(t1.fact_activity_natural_key_hash_uuid) as trans_count_other
    , sum(t1.prod_credit) as prod_credit
    , sum(item_ct * t1.prod_credit) as calculated_productivity
    , case when trans_count_wt is not null then trans_count_wt else trans_count_other end as "Transaction Count"
    , case when T3.system_nm = 'WORKTRACKING' then calculated_productivity else sum(t1.prod_credit) end as "Productivity Credit"
FROM dma.fact_integrated_ano t1
JOIN dma_vw.dma_dim_employee_pit_vw t2 ON t1.dim_employee_natural_key_hash_uuid = t2.dim_employee_natural_key_hash_uuid
JOIN dma_vw.dma_dim_work_pit_vw t3 ON t1.dim_work_natural_key_hash_uuid = t3.dim_work_natural_key_hash_uuid
JOIN dma_vw.dma_ref_admn_sys_cde_vw T6 ON T1.ref_admn_sys_id_key_hash_uuid = T6.ref_admn_sys_id_key_hash_uuid
WHERE T1.trans_type_id in (3) AND YEAR(T1.completed_dt) >= YEAR(CURRENT_DATE) - 3 AND T3.department_id = 11
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
 
UNION 

SELECT -- item count on view, productivity credit includes worktracking count in data.
      t1.completed_dt as "Completed Date"
    , t3.division_cd as "Division Code"
    , t3.department_cd as "Department Code"
    , t3.department_id as "Department ID"
    , t3.department_nm as "Department Name"
    , t3.function_nm as "Function Name"
    , t3.segment_nm as "Segment Name"
    , t3.work_event_nm as "Work Event Name"
    , t3.work_event_num as "Work Event Number"
    , t3.system_nm as "System Name"
    , CASE
        when T2.role_grade_id = 14
        then 'Bot'
        when T2.party_type_id = 2
        then 'System Acct'
        when (T2.department_id = 51
            or (COALESCE(T2.department_id, -99) = -99
            and lower(T2.mmid) like 'ot%'))
            and T2.party_type_id <> 2
        then 'Hyderabad Employee'
        when (T2.department_id NOT IN (51, -99)
            or (COALESCE(T2.department_id, -99) = -99
            and left(lower(T2.mmid),2) in ('mm', 'ct')))
            and T2.party_type_id <> 2
        then 'US Employee'
        else 'Unknown'
        end as "Completed By Type"
    , t6.admn_sys_cde as "Admin System Code"
	, sum(item_count) as trans_count_wt
    , count(t1.fact_activity_natural_key_hash_uuid) as trans_count_other
    , sum(t1.prod_credit) as prod_credit
    , 0 as calculated_productivity
    , case when trans_count_wt is not null then trans_count_wt else trans_count_other end as "Transaction Count"
    , sum(t1.prod_credit) as "Productivity Credit"
FROM dma_vw.fact_integrated_dms_vw t1
JOIN dma_vw.dma_dim_employee_pit_vw t2 ON t1.team_party_id = t2.team_party_id
JOIN dma_vw.dma_dim_work_pit_vw t3 ON t1.work_id = t3.work_id
JOIN dma_vw.dma_ref_admn_sys_cde_vw T6 ON T1.ref_admn_sys_id_key_hash_uuid = T6.ref_admn_sys_id_key_hash_uuid
WHERE T1.trans_type_id in (3) AND YEAR(T1.completed_dt) >= YEAR(CURRENT_DATE) - 3 AND T3.department_id = 13
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12

UNION

SELECT -- No worktracker
      t1.completed_dt as "Completed Date"
    , t3.division_cd as "Division Code"
    , t3.department_cd as "Department Code"
    , t3.department_id as "Department ID"
    , t3.department_nm as "Department Name"
    , t3.function_nm as "Function Name"
    , t3.segment_nm as "Segment Name"
    , t3.work_event_nm as "Work Event Name"
    , t3.work_event_num as "Work Event Number"
    , t3.system_nm as "System Name"
    , CASE
        when T2.role_grade_id = 14
        then 'Bot'
        when T2.party_type_id = 2
        then 'System Acct'
        when (T2.department_id = 51
            or (COALESCE(T2.department_id, -99) = -99
            and lower(T2.mmid) like 'ot%'))
            and T2.party_type_id <> 2
        then 'Hyderabad Employee'
        when (T2.department_id NOT IN (51, -99)
            or (COALESCE(T2.department_id, -99) = -99
            and left(lower(T2.mmid),2) in ('mm', 'ct')))
            and T2.party_type_id <> 2
        then 'US Employee'
        else 'Unknown'
        end as "Completed By Type"
    , t6.admn_sys_cde as "Admin System Code"
	, 0 as trans_count_wt
    , count(t1.fact_activity_natural_key_hash_uuid) as trans_count_other
    , sum(t1.prod_credit) as prod_credit
    , 0 as calculated_productivity
    , trans_count_other as "Transaction Count"
    , sum(t1.prod_credit) as "Productivity Credit"
FROM dma_vw.fact_integrated_dio_vw t1
JOIN dma_vw.dma_dim_employee_pit_vw t2 ON t1.team_party_id = t2.team_party_id
JOIN dma_vw.dma_dim_work_pit_vw t3 ON t1.work_id = t3.work_id
JOIN dma_vw.dma_ref_admn_sys_cde_vw T6 ON T1.ref_admn_sys_id_key_hash_uuid = T6.ref_admn_sys_id_key_hash_uuid
WHERE T1.trans_type_id in (3) AND YEAR(T1.completed_dt) >= YEAR(CURRENT_DATE) - 3 AND T3.department_id = 2
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12

UNION

SELECT -- No worktracker.
      t1.completed_dt as "Completed Date"
    , t3.division_cd as "Division Code"
    , t3.department_cd as "Department Code"
    , t3.department_id as "Department ID"
    , t3.department_nm as "Department Name"
    , t3.function_nm as "Function Name"
    , t3.segment_nm as "Segment Name"
    , t3.work_event_nm as "Work Event Name"
    , t3.work_event_num as "Work Event Number"
    , t3.system_nm as "System Name"
    , CASE
        when T2.role_grade_id = 14
        then 'Bot'
        when T2.party_type_id = 2
        then 'System Acct'
        when (T2.department_id = 51
            or (COALESCE(T2.department_id, -99) = -99
            and lower(T2.mmid) like 'ot%'))
            and T2.party_type_id <> 2
        then 'Hyderabad Employee'
        when (T2.department_id NOT IN (51, -99)
            or (COALESCE(T2.department_id, -99) = -99
            and left(lower(T2.mmid),2) in ('mm', 'ct')))
            and T2.party_type_id <> 2
        then 'US Employee'
        else 'Unknown'
        end as "Completed By Type"
    , t6.admn_sys_cde as "Admin System Code"
	, 0 as trans_count_wt
    , count(t1.fact_activity_natural_key_hash_uuid) as trans_count_other
    , sum(t1.prod_credit) as prod_credit
    , 0 as calculated_productivity
    , trans_count_other as "Transaction Count"
    , sum(t1.prod_credit) as "Productivity Credit"
FROM dma_vw.fact_integrated_dic_vw t1
JOIN dma_vw.dma_dim_employee_pit_vw t2 ON t1.team_party_id = t2.team_party_id
JOIN dma_vw.dma_dim_work_pit_vw t3 ON t1.work_id = t3.work_id
JOIN dma_vw.dma_ref_admn_sys_cde_vw T6 ON T1.ref_admn_sys_id_key_hash_uuid = T6.ref_admn_sys_id_key_hash_uuid
WHERE T1.trans_type_id in (3) AND YEAR(T1.completed_dt) >= YEAR(CURRENT_DATE) - 3 AND T3.department_id = 6
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12

UNION

SELECT -- No item count from work tracker.
      t1.completed_dt as "Completed Date"
    , t3.division_cd as "Division Code"
    , t3.department_cd as "Department Code"
    , t3.department_id as "Department ID"
    , t3.department_nm as "Department Name"
    , t3.function_nm as "Function Name"
    , t3.segment_nm as "Segment Name"
    , t3.work_event_nm as "Work Event Name"
    , t3.work_event_num as "Work Event Number"
    , t3.system_nm as "System Name"
    , CASE
        when T2.role_grade_id = 14
        then 'Bot'
        when T2.party_type_id = 2
        then 'System Acct'
        when (T2.department_id = 51
            or (COALESCE(T2.department_id, -99) = -99
            and lower(T2.mmid) like 'ot%'))
            and T2.party_type_id <> 2
        then 'Hyderabad Employee'
        when (T2.department_id NOT IN (51, -99)
            or (COALESCE(T2.department_id, -99) = -99
            and left(lower(T2.mmid),2) in ('mm', 'ct')))
            and T2.party_type_id <> 2
        then 'US Employee'
        else 'Unknown'
        end as "Completed By Type"
    , t6.admn_sys_cde as "Admin System Code"
	, 0 as trans_count_wt
    , count(t1.fact_activity_natural_key_hash_uuid) as trans_count_other
    , sum(t1.prod_credit) as prod_credit
    , 0 as calculated_productivity
    , trans_count_other as "Transaction Count"
    , sum(t1.prod_credit) as "Productivity Credit"
FROM dma_vw.fact_integrated_lpi_vw t1
JOIN dma_vw.dma_dim_employee_pit_vw t2 ON t1.team_party_id = t2.team_party_id
JOIN dma_vw.dma_dim_work_pit_vw t3 ON t1.work_id = t3.work_id
JOIN dma_vw.dma_ref_admn_sys_cde_vw T6 ON T1.ref_admn_sys_id_key_hash_uuid = T6.ref_admn_sys_id_key_hash_uuid
WHERE T1.trans_type_id in (3) AND YEAR(T1.completed_dt) >= YEAR(CURRENT_DATE) - 3 AND T3.work_event_num <> 4763 AND T3.department_id = 5
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12

UNION

SELECT -- No item count from work tracker.
      t1.completed_dt as "Completed Date"
    , t3.division_cd as "Division Code"
    , t3.department_cd as "Department Code"
    , t3.department_id as "Department ID"
    , t3.department_nm as "Department Name"
    , t3.function_nm as "Function Name"
    , t3.segment_nm as "Segment Name"
    , t3.work_event_nm as "Work Event Name"
    , t3.work_event_num as "Work Event Number"
    , t3.system_nm as "System Name"
    , CASE
        when T2.role_grade_id = 14
        then 'Bot'
        when T2.party_type_id = 2
        then 'System Acct'
        when (T2.department_id = 51
            or (COALESCE(T2.department_id, -99) = -99
            and lower(T2.mmid) like 'ot%'))
            and T2.party_type_id <> 2
        then 'Hyderabad Employee'
        when (T2.department_id NOT IN (51, -99)
            or (COALESCE(T2.department_id, -99) = -99
            and left(lower(T2.mmid),2) in ('mm', 'ct')))
            and T2.party_type_id <> 2
        then 'US Employee'
        else 'Unknown'
        end as "Completed By Type"
    , t6.admn_sys_cde as "Admin System Code"
	, 0 as trans_count_wt
    , count(t1.fact_activity_natural_key_hash_uuid) as trans_count_other
    , sum(t1.prod_credit) as prod_credit
    , 0 as calculated_productivity
    , trans_count_other as "Transaction Count"
    , sum(t1.prod_credit) as "Productivity Credit"
FROM dma_vw.fact_integrated_lac_vw t1
JOIN dma_vw.dma_dim_employee_pit_vw t2 ON t1.team_party_id = t2.team_party_id
JOIN dma_vw.dma_dim_work_pit_vw t3 ON t1.work_id = t3.work_id
JOIN dma_vw.dma_ref_admn_sys_cde_vw T6 ON T1.ref_admn_sys_id_key_hash_uuid = T6.ref_admn_sys_id_key_hash_uuid
JOIN dma.dma_rel_process T7 ON t1.dim_process_natural_key_hash_uuid = T7.dim_process_natural_key_hash_uuid
JOIN dma.dma_ref_process T8 ON T7.ref_process_natural_key_hash_uuid = T8.ref_process_natural_key_hash_uuid 
WHERE T1.trans_type_id in (3) AND YEAR(T1.completed_dt) >= YEAR(CURRENT_DATE) - 3 AND T3.department_id IN (7,8,10)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12

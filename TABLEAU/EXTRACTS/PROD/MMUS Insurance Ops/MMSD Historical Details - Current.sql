/*
This routine provides Historical  Current  Completed for MMSD related Transactions
Source for this routine is PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
Created: 6/1/2021 
Created by John Avgoustakis
Revisions: 10/13/2022 - repointed to Vertica 
Revised by: Christina Valenti
*/

SELECT 
'Completed' as "Transaction Type"
,btrim(agency_nm) as "Firm Name"
,region as "Region"
,source_transaction_id as "Source Transaction ID"
,trim(LEADING '0' FROM agreement_nr) as "Policy Number"
,CASE WHEN bcc_ind = 0
	THEN 'N'
	ELSE 'Y'
END AS "Society 1851"
,completed_dt as "Date"
,role_nm as "Employee Role Name"
,coalesce(employee_last_nm || ', ' || employee_first_nm, 'Unknown') as "Employee"
,coalesce(manager_last_nm || ', ' || manager_first_nm, 'Unknown') as "Manager"
,team_nm as "Team Name"
,function_nm as "Function Name"
,segment_nm	as "Segment Name"
,work_event_nm as "Work Event Name"
,priority_nm AS Priority
,admn_sys_cde as "Admin System"
,process_nm"Process Name"
,process_id as "Process ID"
,process_order as "Process Order"
,chnl_dspy_nm as "Service Channel Code"
,party_type_nm as "Party Type Name"
,organization_nm as "Employee Organization Name"
,department_nm as "Employee Department Name"
,site_nm as "Site Name"
,work_event_organization_nm	as "Work Event Organization Name"
,work_event_department_nm as "Work Event Department Name"
,primary_role_nm as "Primary Role Name"
,system_nm as "System Name"
,work_event_num	as "Work Event Number"
,department_cd as "Department Code"
,division_cd as "Division Code"
,tat as "TAT"
,long_completed_dt AS "Completed Time Stamp"
,NIGO_des AS NIGODescription
,short_comment AS ShortComment
,requestor_type_cd AS "Requestor Type Code"
,rqstr_des AS "Requestor Type Name"
,MAX(load_dt)	as "Max Trans Date"
,COUNT(distinct fact_cats_activity_natural_key_hash_uuid) as "Transaction Count"
,TAT * "Transaction Count" as "Total TAT Days"
,SUM(CASE WHEN met_expected_ind = True AND met_expected = true THEN 1 ELSE 0 END) as "Met Expected Count"
,SUM(CASE WHEN met_expected_ind = TRUE THEN 1 ELSE 0 END) as "Met Expected Ind Count"
,SUM(current_prod_credit) as "Productivity Credits"
,SUM(CASE WHEN igo_ind = True AND nigo_cd = '-99' THEN 1 ELSE 0 END) as "NIGO Count"
,SUM(CASE WHEN igo_ind = True AND nigo_cd = '090' THEN 1 ELSE 0 END) as "IGO Count"
,SUM(CASE WHEN igo_ind = TRUE THEN 1 ELSE 0 END) as "IGO NIGO Count"
,SUM(CASE WHEN flex_ind = TRUE THEN 1 ELSE 0 END)  as "Flex Count"
,SUM(CASE WHEN days_past_tat <= 0 THEN 1 ELSE 0 END) as "Met TAT Count"
,SUM(CASE WHEN days_past_tat = 1 THEN 1 ELSE 0 END) as "Past TAT 1"
,SUM(CASE WHEN days_past_tat = 2 THEN 1 ELSE 0 END) as "Past TAT 2"
,SUM(CASE WHEN days_past_tat = 3 THEN 1 ELSE 0 END) as "Past TAT 3"
,SUM(CASE WHEN days_past_tat >= 4 THEN 1 ELSE 0 END) as "Past TAT 4+"
FROM dma_vw.sem_mmsd_current_vw
WHERE trans_type_id = 3
AND completed_dt >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33, 34, 35, 36, 37
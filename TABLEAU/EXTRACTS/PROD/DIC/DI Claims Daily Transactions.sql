/*
FILENAME: DIC DAILY TRANSACTIONS
CREATED BY: John Avgoutakis
UPDATED BY: Jess Madru
LAST UPDATED: 10/27/2022
CHANGES MADE: Added Admin System field
*/
SELECT
	  T1.transaction_type_nm AS "Transaction Type"
	, T1.fact_integrated_natural_key_hash_uuid AS "IntegratedActivityID"
	, T1.source_transaction_id AS "Source Transaction ID"
	, T1.dim_agreement_nr AS "Policy Number"
	,short_claim_num AS "Short Claim Number"
	,base_claim_num AS "Base Claim Number"
	,claim_num AS "Claim Number"
	,1 AS "Transaction Count"
	,CASE
     WHEN trans_type_id = 1 THEN received_dt
     WHEN trans_type_id = 2 THEN load_dt
     WHEN trans_type_id = 3 THEN completed_dt
     WHEN trans_type_id = 4 THEN logged_dt
	  END ::DATE AS "Date"
	, T1.logged_dt AS "Logged Date"
	, COALESCE(employee_last_nm || ', ' || employee_first_nm, 'Unknown') AS 'Employee'
	, COALESCE(manager_last_nm || ', ' || manager_first_nm , 'Unknown') AS 'Manager'
	, T1.employee_role_nm AS "Role Name"
	, T1.employee_team_nm AS "Team Name"
	, T1.work_event_function_nm AS "Function Name"
	, T1.work_event_segment_nm AS "Segment Name"
	, T1.work_event_nm AS "Work Event Name"
	, T1.work_event_system_nm AS "Data Source"
	, T1.work_event_num AS "Work Event Number"
	, T1.expected_completed_dt AS "Expected Completed Date"
	, T1.tat AS "TAT"
	, T1.days_past_tat AS "Days Past TAT"
	, T1.work_event_met_expected_ind AS "Met Expected Indicator"
	, T1.met_expected AS "Met Expected"
	, T1.medical_review_rnl as MedicalReviewRNL
	, T1.priority_nm AS "Priority"
	, T1.claim_category as "Category"
	,T1.review_status as "Work Status"
	,CASE
    	WHEN trans_type_id = 2 THEN Coalesce(demand_credit,prod_credit)
    	ELSE prod_credit
		END AS "Productivity Credits"
	, CAST(T1.actionable_ind AS INT) AS "Actionable Indicator"
	, CASE WHEN T1.source_transaction_id IS NULL THEN 0 ELSE 1 END AS "Completed Flag"
	, T1.row_process_dtm AS "Trans Date"
	, T1.check_dt as "Payment Check Date"
	, T2.admn_sys_cde as "Admin System"
FROM dma_vw.fact_integrated_dic_pit_vw T1
LEFT JOIN dma_vw.dma_ref_admn_sys_cde_vw T2 on T1.ref_admn_sys_id_key_hash_uuid = T2.ref_admn_sys_id_key_hash_uuid 
WHERE "Date" >= (Current_Date - INTERVAL '3' MONTH)
AND trans_type_id in ('2','3','4')
AND (work_event_department_id = 6 OR employee_department_id = 6)
AND (restricted_claim_ind = 0 OR restricted_claim_ind IS NULL)
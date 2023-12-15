/*
Name: LA Claims First Notices
Author: Jess Madru
Updated: 12/14/2023
Comments: Pulls received CATs events for Life and LCM for the Life 1st Notice Function
*/

WITH /*+ENABLE_WITH_CLAUSE_MATERIALIZATION*/ notices AS ( 
	SELECT source_transaction_id
	,received_dt
	,dim_agreement_natural_key_hash_uuid
	,trim(leading '0' from pol_nr) as pol_nr
	,coalesce(employee_role_nm, 'Unknown') as employee_role_nm
	,coalesce(employee_last_nm || ', ' || employee_first_nm, 'Unknown') as employee_nm   
	,coalesce(mmid, 'Unknown') as employee_mmid
	,coalesce(employee_organization_nm, 'Unknown') as employee_org_nm
	,coalesce(employee_department_nm, 'Unknown') as employee_dept_nm
	,work_event_function_nm 
	,work_event_segment_nm
	,work_event_nm
	,work_event_num
	,work_event_organization_nm
	,work_event_department_nm
	,department_cd
	,division_cd
	,admn_sys_cde    
	,chnl_dspy_nm
	,sht_cmnt_des
	,row_process_dtm
	,'1' as transaction_ct
	FROM dma_vw.fact_integrated_lac_curr_vw
	WHERE work_event_function_nm = 'Life 1st Notice'
	AND trans_type_id = 1 
	AND received_dt = >= CURRENT_DATE - INTERVAL '3' YEAR
	),

	agreement AS (
	SELECT DISTINCT trim(leading '0' from agreement_nr) as policy_num
    ,COALESCE(trim(leading '0' from agreement_nr||agreement_nr_sfx),trim(leading '0' from agreement_nr))  as policy_num_suffix
    ,agreement_nr_sfx
    ,agreement_source_cde
    ,t1.dim_agreement_natural_key_hash_uuid
    ,face_amt
    ,COALESCE(line_of_business_desc, 'Unknown') AS line_of_business
    ,CASE WHEN major_product_type_desc IN ('Non-Traditional Life', 'Traditional Permanent', 'Traditional Term', 'Group Non-Traditional Life', 'Worksite Products' ) 
          THEN major_product_type_desc
          ELSE 'Unknown' END AS product_type
     ,COALESCE(product_type_desc, 'Unknown') AS product_type_nm
     ,COALESCE(agreement_status_reason_nm, 'Unknown') AS status
     FROM edw_semantic_vw.sem_agreement_current_vw t1
     INNER JOIN notices t2 on trim(leading '0' from t2.pol_nr) = trim(leading '0' from t1.agreement_nr) and t2.admn_sys_cde = UPPER(t1.agreement_source_cde)
     WHERE agreement_source_cde <> 'Univ'
     ),

	cats_insd AS (
	SELECT wrk_ident::int as wrk_ident
	,insd_lst_nm||', '||insd_frst_nm AS insured_nm
	FROM cats_vw.cats_wrk_vw t1
	INNER JOIN notices t2 on t1.wrk_ident::int = t2.source_transaction_id
	)

SELECT 
	'Received' as "Transaction Type"
	,'Policy Count' as "Group 1"
	,'Face Amount' as "Group 2"
	,source_transaction_id as "Source Transaction ID"
	,policy_num as "Policy Number"
	,policy_num_suffix as "Policy Number w Suffix"
	,received_dt as "Received Date"
	,employee_role_nm as "Employee Role Name"
	,employee_nm as "Employee Name"    
	,employee_mmid as "Employee MMID"
	,employee_org_nm as "Employee Organization Name"
	,employee_dept_nm as "Employee Department Name"
	,work_event_function_nm as "Function Name"
	,work_event_segment_nm as "Segment Name"
	,work_event_nm as "Work Event Name"
	,work_event_num as "Work Event Number"
	,work_event_organization_nm as "Work Event Organization Name"
	,work_event_department_nm as "Work Event Department Name"
	,department_cd as "Department Code"
	,division_cd as "Division Code"
	,admn_sys_cde as "Admin System"    
	,chnl_dspy_nm as "Service Channel Code"
	,sht_cmnt_des as "Short Comment"
	,insured_nm as "Insured Name"
	,face_amt as "Face Amount"
	,line_of_business AS "Line of Business"
	,product_type as "Product Type"
	,product_type_nm as "Product Type Name"
	,status as "Status"
	,row_process_dtm
	,transaction_ct as "Transaction Count"
FROM notices t1
	JOIN agreement ON agreement.policy_num = t1.pol_nr and UPPER(agreement.agreement_source_cde) = t1.admn_sys_cde --joining on agreement and admin to remove NULLs based on gap in cats source table
	JOIN cats_insd ON t1.source_transaction_id = cats_insd.wrk_ident

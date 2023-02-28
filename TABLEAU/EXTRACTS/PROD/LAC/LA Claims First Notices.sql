/*
Name: LA Claims First Notices
Author: Jess Madru
Created: 2/28/2023
Comments: Pulls received CATs events for Life and LCM for the Life 1st Notice Function
*/

SELECT 
'Received' as "Transaction Type"
,'Policy Count' as "Group 1"
,'Face Amount' as "Group 2"
,a.source_transaction_id as "Source Transaction ID"
,COALESCE(AGMT.PolicyNumber, 'Unknown') as "Policy Number"
,COALESCE(AGMT.PolicyNumberwSufix, 'Unknown') as "Policy Number w Suffix"
,a.received_dt as "Received Date"
,coalesce(a.employee_role_nm, 'Unknown') as "Employee Role Name"
,coalesce(a.employee_last_nm || ', ' || a.employee_first_nm, 'Unknown') as "Employee Name"    
,coalesce(a.mmid, 'Unknown') as "Employee MMID"
,coalesce(a.employee_organization_nm, 'Unknown') as "Employee Organization Name"
,coalesce(a.employee_department_nm, 'Unknown') as "Employee Department Name"
,a.work_event_function_nm    as "Function Name"
,a.work_event_segment_nm    as "Segment Name"
,a.work_event_nm    as "Work Event Name"
,a.work_event_num    as "Work Event Number"
,a.work_event_organization_nm    as "Work Event Organization Name"
,a.work_event_department_nm    as "Work Event Department Name"
,a.department_cd     as "Department Code"
,a.division_cd    as "Division Code"
,a.admn_sys_cde as "Admin System"    
,a.chnl_dspy_nm    as "Service Channel Code"
,a.sht_cmnt_des  as "Short Comment"
,cwv.insd_lst_nm||', '||cwv.insd_frst_nm AS "Insured Name"
,AGMT.face_amt as "Face Amount"
,COALESCE(AGMT.line_of_business_desc, 'Unknown') AS "Line of Business"
,COALESCE(AGMT."Product Type", 'Unknown') AS "Product Type"
,COALESCE(AGMT."Product Type Name", 'Unknown') AS "Product Type Name"
,COALESCE(AGMT."Status", 'Unknown') AS "Status"
,a.row_process_dtm
,COUNT(distinct a.source_transaction_id) as "Transaction Count"

FROM dma_vw.fact_integrated_lac_curr_vw a

LEFT JOIN cats_vw.cats_wrk_vw AS cwv
ON a.source_transaction_id = cwv.wrk_ident

LEFT JOIN 
            (
            SELECT DISTINCT 
            trim(leading '0' from agreement_nr) as PolicyNumber
            ,COALESCE(trim(leading '0' from agreement_nr||agreement_nr_sfx),trim(leading '0' from agreement_nr))  as PolicyNumberwSufix
            ,agreement_nr_sfx
            ,agreement_source_cde
            ,dim_agreement_natural_key_hash_uuid
            ,face_amt
            ,line_of_business_desc
            ,line_of_business_cde
            ,CASE WHEN major_product_type_desc IN ('Non-Traditional Life', 'Traditional Permanent', 'Traditional Term', 'Group Non-Traditional Life', 'Worksite Products' ) 
                                THEN major_product_type_desc
                                ELSE 'Unknown' END AS "Product Type"
            ,product_type_desc as "Product Type Name"
            ,agreement_status_reason_nm as "Status"
                                   
            FROM edw_semantic_vw.sem_agreement_current_vw
            where agreement_source_cde <> 'Univ'
            ) AGMT
            ON AGMT.PolicyNumber = trim (leading '0' from a.pol_nr) and UPPER(AGMT.agreement_source_cde) = a.admn_sys_cde --joining on agreement and admin to remove NULLs based on gap in cats source table 
   
WHERE  
a.work_event_function_nm = 'Life 1st Notice'
AND a.trans_type_id = 1 
AND "Received Date" >= CURRENT_DATE - INTERVAL '3' YEAR
 
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30

/*
FILENAME: DI CLAIMS CLOSURE REASONS
CREATED BY: John Avgoutakis
UPDATED BY: Jess Madru
LAST UPDATED: 1/25/2023
CHANGES MADE: Vertica SQL Creation, added medical review fields, add admin system field
*/

SELECT

	  T1.claim_no AS "Claim Number"
	, T2.dim_claim_natural_key_hash_uuid AS "ClaimDimensionUniqueID"
	, T2.short_claim_num AS "Short Claim Number"
	, T2.policy_num AS "Policy Number"
	, T2.admin_sys AS "Admin System"
	, T2.claim_category AS "Claim Category"
	, T2.examiner_party_employee_id AS "ExaminerPartyEmployeeID"
	, T4.employee_last_nm ||','|| T4.employee_first_nm AS "Examiner"
	, T4.manager_last_nm || ','|| T4.manager_first_nm AS "Manager"
	, T2.disability_dt AS "Disability Date"
	, T1.dt AS "Closed Date"
	, T1.code AS "Status Code"
	, T1.close_reclose_reason AS "Close Reason Code"
	, T3.dt AS "Last Approved Date"
	, T2.icd_1_desc AS "Diagnosis"
	, T2.icd_1_group_nm AS "Diagnosis Group"
	, T5.close_reason_nm AS "Close Reason Name"
	, T5.close_reason_cat AS "Close Reason Category"
	, T6.med_review_renewal AS "Med Review Renewal"
	, T6.med_review_support_dt AS "Med Review Support Date"
	, T2.row_process_dtm AS "Transaction Date"
	
FROM dibs.claim_status T1

INNER JOIN dma_vw.dic_dim_claim_curr_vw T2 ON T1.claim_no = T2.claim_num 

LEFT JOIN 
		(SELECT *
		 FROM dibs.claim_status T1
		 WHERE UPPER(T1.code) = 'AC' AND T1.type2_current_flag = 1 AND T1.dt >= '2016-01-01'
		 LIMIT 1 OVER(PARTITION BY T1.claim_no ORDER BY dt DESC)) T3 ON T1.claim_no = T3.claim_no

LEFT JOIN dma_vw.dma_dim_employee_curr_vw T4 ON T2.examiner_party_employee_id = T4.party_employee_id 

LEFT JOIN dma_vw.dic_ref_close_reason_vw T5 ON T1.close_reclose_reason = T5.close_reason_cd

LEFT JOIN (SELECT claim_num, med_review_renewal, med_review_support_dt, begin_dt, current_row_ind, end_dt
FROM dma_vw.dic_dim_medical_review_vw
LIMIT 1 OVER (PARTITION BY claim_num ORDER BY begin_dt DESC)
) T6
ON T1.claim_no = T6.claim_num

WHERE UPPER(T1.code) IN ('CL','RC')
AND T2.open_dt >= '2016-01-01'  --Nothing opened prior to 1/1/2016
AND T1.type2_current_flag = 1
AND (UPPER(T2.current_substatus) like '%AC%' OR UPPER(T2.current_substatus) like '%DN%')
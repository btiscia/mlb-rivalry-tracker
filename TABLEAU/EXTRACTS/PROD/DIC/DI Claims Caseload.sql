/*
FILENAME: DI CLAIMS CASELOAD DETAILS
CREATED BY: John Avgoutakis
LAST UPDATED: 2/2/2022
CHANGES MADE: Vertica SQL Creation.
*/

SELECT T5.short_dt AS "Load Date"
	, T1.dim_claim_natural_key_hash_uuid AS "Natural Key"
	, T1.claim_num AS "Claim Number"
	, T1.short_claim_num AS "Short Claim Number"
	, T1.policy_num AS "Policy Number"
	, T3.full_name AS "Insured"
	, T3.zip AS "Insured Zip Code"
	, T3.st AS "Insured State"
	, CASE WHEN lower(T1.claim_status_category) = 'approved' AND T6.role_grade_id = 12 THEN 'Stable and Mature'
    	   WHEN lower(T1.claim_status_category) LIKE '%stable and mature' THEN 'Stable and Mature'
      	   ELSE T1.claim_status_category
      END AS "Claim Status"
	, T1.current_substatus AS "Claim Substatus"
	, T1.claim_category AS "Claim Category"
	, CASE WHEN T1.base_claim_ind = 1 THEN 'Claim'
		ELSE 'Additional Policy' END AS 'Claim/Add''l Policy'
	, T1.dibs_customer_id AS "DIBS Customer ID"
	, T4.med_review_category "Med Review Category"
	, T4.med_review_support_dt "MedReviewSupportDate"
	, T1.examiner_party_employee_id
	, COALESCE(T4.med_review_category, 'No Review') AS "Category"
	, T1.disability_dt AS "Disability Date"
	, T1.late_notice_ind AS "LateNoticeIndicator"
	, T1.erisa_ind AS "ERISAIndicator"
	, T1.contestable_ind AS "ContestableIndicator"
	, CASE WHEN T1.in_litigation_ind = 0 THEN 'Not in Litigation' ELSE 'In Litigation' END AS "InLitigationIndicator"
	, T1.own_occ_ind AS "OwnOccupationIndicator"
	, T1.reservation_of_rights_ind AS "ReservationOfRightsIndicator"
	, CASE WHEN T4.med_review_support_dt IS NOT NULL THEN 1 ELSE 0 END AS "SupportIndicator"
	, T1.worksite_ind AS "WorksiteIndicator"
	, T1.eft_ind AS "EFTIndicator"
	, T1.ssdi_approved_ind AS "SSDIApprovedIndicator"
	, T1.benefit_end_dt AS "Max Benefit Date"
	, T1.attorney_rep_ind AS "AttorneyRepIndicator"
	, T1.recovery_benefit_ind AS "RecoveryBenefitIndicator"
	, T1.est_ben_duration AS "EstimatedBenefitDuration"
	, T1.health_dt AS "HealthDate"
	, T1.waiver_only_ind AS "WaiverOnlyIndicator"
	, T1.birth_dt AS "Birth Date"
	, T1.age_at_dod AS "AgeAtDOD"
	, T1.preclaim_ind AS "PreClaimIndicator"
	, T1.quick_decision_ind AS "QuickDecisionIndicator"
	, T2.last_pc_subst_dt AS "LastPreClaimSubstatusDate"
	, T2.pc_del_dt AS "PreClaimDeleteDate"
	, T2.ac_subst_dt AS "ApprovedSubstatusDate"
	, T2.wo_subst_dt AS "WaiverOnlySubstatusDate"
	, T2.ri_subst_dt AS "ReinsuranceReportDate"
	, T1.restricted_claim_ind AS "RestrictedClaimIndicator"
	, T1.appeal_ind AS "AppealIndicator"
	, T1.icd_1_code AS "ICD1Code"
	, T1.icd_1_desc AS "ICD1Description"
	, T1.icd_1_ref_icd_group_natural_key_hash_uuid AS "ICD1GroupID"
	, T1.icd_1_group_nm AS "ICD1GroupName"
	, T1.notice_dt AS "Notice Date"
	, T1.open_dt AS "Open Date"
	, T1.row_process_dtm AS "TransDate"
    , COALESCE(CASE WHEN T1.claim_status_category = 'Preclaim' THEN T5.short_dt - T1.notice_dt
                WHEN T1.claim_status_category = 'Active Pending' THEN T5.short_dt - CAST(COALESCE(T2.ro_subst_dt,T2.pc_del_dt,T2.last_pe_subst_dt) AS DATE)
                ELSE T5.short_dt - CAST(T1.disability_dt AS DATE) END,0) AS "Days Aging"
	, FLOOR("Days Aging"/30) AS "Months Aging"
	, T6.manager_last_nm || ', ' || T6.manager_first_nm AS "Manager"
	, COALESCE((T6.employee_last_nm || ', ' || T6.employee_first_nm),'Unknown') AS "Examiner"
FROM dma.dic_dim_claim_pit T1
LEFT JOIN (SELECT DISTINCT T1.claim_no
			, MAX(CASE WHEN upper(T1.code) = 'PC' THEN T1.dt END) AS last_pc_subst_dt
			, MAX(CASE WHEN upper(T1.code) = 'PE' THEN T1.dt END) AS last_pe_subst_dt
			, MAX(CASE WHEN upper(T1.code) = 'PR' THEN T1.dt END) AS last_pr_subst_dt
			, MAX(CASE WHEN upper(T1.code) = 'AC' AND T1.delete_date IS NULL THEN T1.dt END) AS ac_subst_dt
			, MAX(CASE WHEN upper(T1.code) = 'WO' THEN T1.dt END) AS wo_subst_dt
			, MAX(CASE WHEN upper(T1.code) = 'RI' THEN T1.dt END) AS ri_subst_dt
			, MAX(CASE WHEN upper(T1.code) = 'OP' THEN T1.dt END) AS op_subst_dt
			, MAX(CASE WHEN upper(T1.code) = 'RO' THEN T1.dt END) AS ro_subst_dt
			, MAX(CASE WHEN upper(T1.code) = 'PC' THEN T1.delete_date END) AS pc_del_dt
			, MAX(CASE WHEN upper(T1.code) = 'PE' THEN T1.delete_date END) AS pe_del_dt
			, MAX(CASE WHEN upper(T1.code) = 'PR' THEN T1.delete_date END) AS pr_del_dt
		FROM (SELECT T1.claim_no, T1.dt, T1.code, T1.delete_date
				FROM dibs.claim_status T1
				WHERE T1.type2_current_flag = 1
				LIMIT 1 OVER (PARTITION BY T1.claim_no,T1.code ORDER BY T1.dt DESC,T1.delete_date DESC)) T1
		GROUP BY 1) T2 ON T1.claim_num = T2.claim_no
LEFT JOIN (SELECT * FROM dibs.customer
			WHERE type2_current_flag = 1
			LIMIT 1 OVER (PARTITION BY customer_id ORDER BY claim_no DESC)) T3 ON T1.dibs_customer_id = T3.customer_id
LEFT JOIN dma.dma_dim_date T5 ON T5.short_dt BETWEEN T1.begin_dt AND T1.end_dt
LEFT JOIN dma.dic_dim_medical_review T4 ON T1.short_claim_num = T4.claim_num AND T5.short_dt BETWEEN T4.begin_dt AND T4.end_dt
LEFT JOIN dma.dma_dim_employee_pit T6 ON T1.examiner_party_employee_id = T6.party_employee_id AND T5.short_dt BETWEEN t6.begin_dt AND T6.end_dt
WHERE lower(T1.claim_status_category) NOT IN ('closed','unknown')
	AND T5.short_dt = coalesce(:date, CAST(CURRENT_DATE AS Date))
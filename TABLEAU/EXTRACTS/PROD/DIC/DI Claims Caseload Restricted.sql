/*
FILENAME: DI CLAIMS CASELOAD RESTRICTED
UPDATED BY: Vince Bonnadio
LAST UPDATED: 8/28/2023
CHANGES MADE: 01/25/2023 - Added Admin System field - J Madru
06/15/2023 - Updated Indicator references - B Tiscia
08/28/2023 - query restructure for optimization - V Bonnadio
*/

with /*+ENABLE_WITH_CLAUSE_MATERIALIZATION */ claims as (
    select t2.short_dt
         , t1.dim_claim_natural_key_hash_uuid
         , t1.claim_num
         , t1.begin_dt
         , t1.end_dt
    from dma.dic_dim_claim_pit t1
             left join dma.dma_dim_date t2 on t2.short_dt between t1.begin_dt and t1.end_dt
    where lower(T1.claim_status_category) not in ('closed', 'unknown')
      and t2.short_dt between cast(current_date as date) - 60 AND cast(current_date as date)
)

, claim_dim as (
    select t1.short_dt
        , T1.dim_claim_natural_key_hash_uuid
        , T1.claim_num
        , t2.short_claim_num
        , t2.policy_num
        , t2.admin_sys
        , t2.claim_status_category
        , t2.current_substatus
        , t2.claim_category
        , t2.base_claim_ind
        , t2.dibs_customer_id
        , t2.examiner_party_employee_id
        , t2.disability_dt
        , t2.late_notice_ind
        , t2.erisa_ind
        , t2.contestable_ind
        , t2.in_litigation_ind
        , t2.own_occ_ind
        , t2.reservation_of_rights_ind
        , t2.worksite_ind
        , t2.eft_ind
        , t2.ssdi_approved_ind
        , t2.benefit_end_dt
        , t2.attorney_rep_ind
        , t2.recovery_benefit_ind
        , t2.est_ben_duration
        , t2.health_dt
        , t2.waiver_only_ind
        , t2.birth_dt
        , t2.age_at_dod
        , t2.preclaim_ind
        , t2.quick_decision_ind
        , t2.icd_1_code
        , t2.icd_1_desc
        , t2.icd_1_ref_icd_group_natural_key_hash_uuid
        , t2.icd_1_group_nm
        , t2.notice_dt
        , t2.open_dt
        , t2.row_process_dtm
        , t2.restricted_claim_ind
        , t2.appeal_ind
        , t4.role_grade_id
        , t2.load_dt
        , t4.manager_last_nm
        , t4.manager_first_nm
        , t4.employee_last_nm
        , t4.employee_first_nm
    from claims t1
    join dma.dic_dim_claim_pit t2 on t1.dim_claim_natural_key_hash_uuid = t2.dim_claim_natural_key_hash_uuid
    left join dma.dma_dim_employee_pit t4 on t2.examiner_party_employee_id = t4.party_employee_id and t1.short_dt between t4.begin_dt and t4.end_dt
)

, claim_med as (
    select t1.*
        , t3.med_review_category
        , t3.med_review_support_dt
    from claim_dim t1
    left join dma.dic_dim_medical_review t3 on t1.short_claim_num = t3.claim_num and t1.short_dt between t3.begin_dt and t3.end_dt
)


, status as (
    SELECT DISTINCT T1.claim_no
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
    join dma.dic_dim_claim_pit T2 on t1.claim_no = t2.claim_num
    GROUP BY 1
)

SELECT t1.short_dt AS "Load Date"
	, T1.dim_claim_natural_key_hash_uuid AS "Natural Key"
	, T1.claim_num AS "Claim Number"
	, T1.short_claim_num AS "Short Claim Number"
	, T1.policy_num AS "Policy Number"
	, T1.admin_sys AS "Admin System"
	, T3.full_name AS "Insured"
	, T3.zip AS "Insured Zip Code"
	, T3.st AS "Insured State"
	, CASE WHEN lower(T1.claim_status_category) = 'approved' AND t1.role_grade_id = 12 THEN 'Stable and Mature'
    	   WHEN lower(T1.claim_status_category) LIKE '%stable and mature' THEN 'Stable and Mature'
      	   ELSE T1.claim_status_category
          END AS "Claim Status"
	, T1.current_substatus AS "Claim Substatus"
	, T1.claim_category AS "Claim Category"
	, CASE WHEN T1.base_claim_ind = 1 THEN 'Claim'
		ELSE 'Additional Policy' END AS 'Claim/Add''l Policy'
	, T1.dibs_customer_id AS "DIBS Customer ID"
	, T1.med_review_category "Med Review Category"
	, T1.med_review_support_dt "MedReviewSupportDate"
	, T1.examiner_party_employee_id
	, COALESCE(T1.med_review_category, 'No Review') AS "Category"
	, T1.disability_dt AS "Disability Date"
	, CASE WHEN T1.late_notice_ind = True THEN 'Yes' ELSE 'No' END AS "LateNoticeIndicator"
	, CASE WHEN T1.erisa_ind = True THEN 'Yes' ELSE 'No' END AS "ERISAIndicator"
	, CASE WHEN T1.contestable_ind = True THEN 'Yes' ELSE 'No' END AS "ContestableIndicator"
	, CASE WHEN T1.in_litigation_ind = True THEN 'Yes' ELSE 'No' END AS "InLitigationIndicator"
	, CASE WHEN T1.own_occ_ind = True THEN 'Yes' ELSE 'No' END AS "OwnOccupationIndicator"
	, CASE WHEN T1.reservation_of_rights_ind = True THEN 'Yes' ELSE 'No' END AS "ReservationOfRightsIndicator"
	, CASE WHEN T1.med_review_support_dt IS NOT NULL THEN 1 ELSE 0 END AS "SupportIndicator"
	, T1.worksite_ind AS "WorksiteIndicator"
	, CASE WHEN T1.eft_ind = True THEN 1 ELSE 0 END AS "EFTIndicator"
	, CASE WHEN T1.ssdi_approved_ind = True THEN 'Yes' ELSE 'No' END AS "SSDIApprovedIndicator"
	, T1.benefit_end_dt AS "Max Benefit Date"
	, CASE WHEN T1.attorney_rep_ind = True THEN 'Yes' ELSE 'No' END AS "AttorneyRepIndicator"
	, CASE WHEN T1.recovery_benefit_ind = True THEN 'Yes' ELSE 'No' END AS "RecoveryBenefitIndicator"
	, T1.est_ben_duration AS "EstimatedBenefitDuration"
	, T1.health_dt AS "HealthDate"
	, CASE WHEN T1.waiver_only_ind = True THEN 'Yes' ELSE 'No' END AS "WaiverOnlyIndicator"
	, T1.birth_dt AS "Birth Date"
	, T1.age_at_dod AS "AgeAtDOD"
	, CASE WHEN T1.preclaim_ind = True THEN 'Yes' ELSE 'No' END AS "PreClaimIndicator"
	, CASE WHEN T1.quick_decision_ind = True THEN 'Yes' ELSE 'No' END AS "QuickDecisionIndicator"
	, T2.last_pc_subst_dt AS "LastPreClaimSubstatusDate"
	, T2.pc_del_dt AS "PreClaimDeleteDate"
	, T2.ac_subst_dt AS "ApprovedSubstatusDate"
	, T2.wo_subst_dt AS "WaiverOnlySubstatusDate"
	, T2.ri_subst_dt AS "ReinsuranceReportDate"
	, CASE WHEN T1.restricted_claim_ind = True THEN 'Restricted' ELSE 'Unrestricted' END AS "RestrictedClaimIndicator"
	, CASE WHEN T1.appeal_ind = True THEN 'Yes' ELSE 'No' END AS "AppealIndicator"
	, T1.icd_1_code AS "ICD1Code"
	, T1.icd_1_desc AS "ICD1Description"
	, T1.icd_1_ref_icd_group_natural_key_hash_uuid AS "ICD1GroupID"
	, T1.icd_1_group_nm AS "ICD1GroupName"
	, T1.notice_dt AS "Notice Date"
	, T1.open_dt AS "Open Date"
	, T1.row_process_dtm AS "TransDate"
    , COALESCE(CASE WHEN T1.claim_status_category = 'Preclaim' THEN t1.short_dt - T1.notice_dt
                WHEN T1.claim_status_category = 'Active Pending' THEN t1.short_dt - CAST(COALESCE(T2.ro_subst_dt,T2.pc_del_dt,T2.last_pe_subst_dt) AS DATE)
                ELSE T1.load_dt - CAST(T1.disability_dt AS DATE) END,0) AS "Days Aging"
	, FLOOR("Days Aging"/30) AS "Months Aging"
	, T1.manager_last_nm || ', ' || t1.manager_first_nm AS "Manager"
	, COALESCE((T1.employee_last_nm || ', ' || T1.employee_first_nm),'Unknown') AS "Examiner"
FROM claim_med T1
LEFT JOIN status T2 ON T1.claim_num = T2.claim_no
LEFT JOIN (SELECT * FROM dibs.customer
			WHERE type2_current_flag = 1
			LIMIT 1 OVER (PARTITION BY customer_id ORDER BY claim_no DESC)) T3 ON T1.dibs_customer_id = T3.customer_id
/*
FILENAME: LA Claims Evadata
CREATED BY: Bill Trombley
LAST UPDATED: 03/20/2024
CHANGES MADE: Adjusted query to work with the production dashboard.
*/

SELECT t1.party_id AS 'Party ID'
     , t1.party_role_cde AS 'Customer Agreement Role'
     , t1.line_of_business_cde AS 'Agreement LOB Code'
     , t1.agreement_source_cde AS 'Agreement Source Code'
     , t1.agreement_nr_pfx AS 'Agreement Prefix'
     , t1.agreement_nr AS 'Agreement Number'
     , t1.agreement_nr_sfx AS 'Agreement Suffix'
     , t1.minor_product_type_desc AS 'Agreement Product Type'
     , t1.issue_dt AS 'Agreement Issue Date'
     , CASE 
     	WHEN t1.contract_val IS NULL THEN 0
     	ELSE t1.contract_val 
       END AS 'Contract Value'
     , t1.case_state_cde AS 'Resident State Code'
     , t1.case_status_cde AS 'Case Status Code'
     , t1.case_disposition_id AS 'Case Disposition ID'
     , t1.case_disposition_cde AS 'Case Disposition Code'
     , t1.case_disposition_nm AS 'Case Disposition Name'
     , t1.case_disposition_desc AS 'Case Disposition Description'
     , CAST(t1.case_disposition_dtm AS DATE) AS 'Case Disposition Date'
     , CAST(t1.case_auto_status_ind AS INTEGER) AS 'Case Auto Status Indicator'
     , CASE WHEN t1.case_disposition_cde = 'CASEMATCH' THEN 1 ELSE 0 END AS 'Customer Match Indicator'
     , t1.story_status_id AS 'Story Status ID'
     , t1.story_status_cde AS 'Story Status Code'
     , INITCAP(t1.story_status_nm) AS 'Story Status Name'
     , t1.story_status_desc AS 'Story Status Description'
     , t1.story_auto_status_ind AS 'Story Auto Status Indicator'
     , t1.evadata_match_id AS 'Source Transaction ID'
     , t1.match_source AS 'Match Source'
     , t1.match_category AS 'Match Category'
     , CAST(t1.death_dt AS DATE) AS 'Match Death Date'
     , t1.case_verified_death_dt AS 'Death Date'
     , CAST(t1.match_notification_dt AS DATE) AS 'Match Notification Date'
     , CAST(t1.first_notice_dt AS DATE) AS 'Notification Date'
     , t1.death_to_first_notice_days AS 'Death to Notification Days'
     , CAST(t1.case_created_at_dtm AS DATE) AS 'Case Created Date'
     , CAST(t1.case_updated_at_dtm AS DATE) AS 'Case Updated Date'
     , t1.case_updated_by_id AS 'Case Updated By ID'
     , CAST(t1.story_status_dtm AS DATE) AS 'Story Status Date'
     , CAST(t1.story_created_at_dtm AS DATE) AS 'Story Created Date'
     , CAST(t1.story_updated_at_dtm AS DATE) AS 'Story Updated Date'
     , t1.story_updated_by_id AS 'Story Updated By ID'
     , t1.dim_agreement_natural_key_hash_uuid AS 'Dim Agr Nat Key'
     , CAST(t1.story_updated_at_dtm AS DATE) AS 'Story Updated Date Time'
     , t1.case_row_process_dtm AS 'Data Last Updated'
     , CAST(T3.is_holiday AS INT) AS 'Is Holiday'
     , CAST(T3.is_weekday AS INT) AS 'Is Weekday'
     , t2.employee_last_nm||', '||t2.employee_first_nm AS 'Employee Name'
     , t3.short_dt AS 'Short Date'
     , t3.business_day AS 'Business Day'
     , t4.business_day - t3.business_day AS 'Business Days'
FROM dmf_vw.sem_lens_dmf_curr_vw t1
LEFT JOIN dma_vw.dma_dim_employee_curr_vw t2 ON t1.story_updated_by_id = t2.hr_id
LEFT JOIN dma_vw.dma_dim_date_vw t3 ON t3.short_dt = DATE(t1.case_created_at_dtm)
LEFT JOIN dma_vw.dma_dim_date_vw t4 ON CURRENT_DATE = t4.short_dt
LIMIT 1 OVER (PARTITION BY party_id, dim_agreement_natural_key_hash_uuid ORDER BY first_notice_dt, match_category)
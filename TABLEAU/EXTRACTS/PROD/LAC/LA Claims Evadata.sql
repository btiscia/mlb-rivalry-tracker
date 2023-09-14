/*
FILENAME: LA Claims Evadata
CREATED BY: Bill Trombley
LAST UPDATED: 09/14/2023
CHANGES MADE: 
*/

SELECT party_id AS 'Party ID'
     , party_role_cde AS 'Customer Agreement Role'
     , line_of_business_cde AS 'Agreement LOB Code'
     , agreement_source_cde AS 'Agreement Source Code'
     , agreement_nr_pfx AS 'Agreement Prefix'
     , agreement_nr AS 'Agreement Number'
     , agreement_nr_sfx AS 'Agreement Suffix'
     , minor_product_type_desc AS 'Agreement Product Type'
     , issue_dt AS 'Agreement Issue Date'
     , CASE 
     	WHEN contract_val IS NULL THEN 0
     	ELSE contract_val 
       END AS 'Contract Value'
     , case_state_cde AS 'Resident State Code'
     , case_status_cde AS 'Case Status Code'
     , case_disposition_id AS 'Case Disposition ID'
     , case_disposition_cde AS 'Case Disposition Code'
     , case_disposition_nm AS 'Case Disposition Name'
     , case_disposition_desc AS 'Case Disposition Description'
     , CAST(case_disposition_dtm AS DATE) AS 'Case Disposition Date'
     , CAST(case_auto_status_ind AS INTEGER) AS 'Case Auto Status Indicator'
     , CASE
           WHEN
                       UPPER(case_disposition_cde) = 'CASEMATCH' OR
                       (
                                   UPPER(case_disposition_cde) = 'CASEAUTO' AND
                                   UPPER(story_status_cde) IN ('DTHPE', 'DTHPD')
                           )
               THEN 1
           ELSE 0
       END   AS 'Customer Match Indicator'
     , story_status_id AS 'Story Status ID'
     , story_status_cde AS 'Story Status Code'
     , INITCAP(story_status_nm) AS 'Story Status Name'
     , story_status_desc AS 'Story Status Description'
     , story_auto_status_ind AS 'Story Auto Status Indicator'
     , evadata_match_id AS 'Source Transaction ID'
     , match_source AS 'Match Source'
     , match_category AS 'Match Category'
     , CAST(death_dt AS DATE) AS 'Match Death Date'
     , case_verified_death_dt AS 'Death Date'
     , CAST(match_notification_dt AS DATE) AS 'Match Notification Date'
     , CAST(first_notice_dt AS DATE) AS 'Notification Date'
     , death_to_first_notice_days AS 'Death to Notification Days'
     , case_created_at_dtm AS 'Case Created Date'
     , case_updated_at_dtm AS 'Case Updated Date'
     , case_updated_by_id AS 'Case Updated By ID'
     , CAST(story_status_dtm AS DATE) AS 'Story Status Date'
     , CAST(story_created_at_dtm AS DATE) AS 'Story Created Date'
     , CAST(story_updated_at_dtm AS DATE) AS 'Story Updated Date'
     , story_updated_by_id AS 'Story Updated By ID'
     , dim_agreement_natural_key_hash_uuid AS 'Dim Agr Nat Key'
     , story_updated_at_dtm AS 'Story Updated Date Time'
     , case_row_process_dtm AS 'Data Last Updated'
FROM dmf_vw.sem_lens_dmf_curr_vw
LIMIT 1 OVER (PARTITION BY party_id, dim_agreement_natural_key_hash_uuid ORDER BY first_notice_dt, match_category)
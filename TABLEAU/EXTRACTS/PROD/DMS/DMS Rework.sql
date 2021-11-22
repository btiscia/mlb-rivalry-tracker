SELECT         
  T1.request_id AS ID
, T1.client_id AS "Client ID"
, T1.document_id AS "Document ID"
, T1.document_dt AS "Document Date"
, T1.rework_queue_id  AS "Rework Queue ID"
, T1.rework_service_channel_id   AS "Rework Service Channel ID"
, T1.rework_error_source_id AS "Rework Error Source ID"
, T1.exclude_request_ind   AS "Exclude Request IND"
, T1.delete_image_ind AS "Delete Image IND"
, T1.research_only_ind     AS "Research Only IND"
, T1.sec_ind    AS SEC_IND
, T1.request_description   AS "Request Description"
, T1.created_by AS "Created By ID"
, T1.created_at AS "Created Date Time"
,cast(t1.created_at as date) AS "Created Date"
, T8.party_type_nm AS "Creator Party Type Name"
, coalesce(T8.organization_nm, 'Unknown') AS "Creator Organization Name"
, coalesce(T8.department_nm, 'Unknown') AS "Creator Department Name"
, coalesce(T8.team_nm, 'Unknown') AS "Creator Team Name"
, T8.role_nm AS "CreatorRoleName"
, coalesce(T8.Employee_Last_NM || ', ' || T8.Employee_First_NM, 'Unknown') AS "Creator Employee Name"
, coalesce(T8.Manager_Last_NM || ', '  || T8.Manager_First_NM, 'Unknown') AS "Creator Manager Name"
, T7.hr_id AS HRID
, T2.queues_name AS "Que Name"
, T2.queues_description    AS "Que Description"
, T2.internal_ind AS "Internal Indicator"
, T3.channel_name AS "Channel Name"
, T3.channel_description AS "Channel Description"
, T4.sources_name AS "Source Name"
, T4.sources_description AS "Source Description"
, T4.created_at AS T4CreatedDateTime
, T4.updated_at AS "Updated Date Time"
, T5.rework_request_id     AS "Rework Request ID"
, T5.rework_error_reason_id AS "Rework Error Reason ID"
, T6.reasons_name AS "Reason Name"
, T6.reasons_description AS "Reason Description"
, T6.internal_ind AS T6InternalIndicator
, T11.party_type_nm AS "Error Party Type Name"
, T11.organization_nm AS "Error Organization Name"
, T11.department_nm AS "Error Department Name"
, T11.team_nm AS "Error Team Name"
, T11.role_nm AS "Error Role Name"
, coalesce(T11.Employee_Last_NM || ', ' ||  T11.Employee_First_NM, 'Unknown') AS "Error Employee Name"
, coalesce(T11.Manager_Last_NM || ', ' ||  T11.Manager_First_nm, 'Unknown') AS "Error Manager Name"
, T12.work_count AS "Research Work Count"
, T15.prod_credit AS "Correction Production Credit"
, CASE WHEN T12.Work_Count IS NOT NULL THEN 1 ELSE NULL END AS "Correction Work Count"
FROM dma.bibt_rel_rework_request T1
JOIN dma.bibt_ref_rework_queues T2 ON T1.rework_queue_id = T2.queues_id
LEFT JOIN dma.bibt_ref_rework_service_channels T3 ON T1.rework_service_channel_id = T3.channel_id
LEFT JOIN dma.bibt_ref_rework_error_sources T4 ON T1.rework_error_source_id = T4.sources_id
LEFT JOIN dma.bibt_ref_rework_request_errors T5 ON T1.request_id = T5.rework_request_id 
LEFT JOIN dma.bibt_rel_rework_error_reasons T6 ON T5.rework_error_reason_id = T6.reasons_id 
LEFT JOIN dma.dma_ref_party_employee T7 ON T1.created_by = T7.hr_id 
LEFT JOIN dma.dma_dim_employee_pit T8 ON T7.party_employee_id = T8.party_employee_id AND T8.begin_dt <= T1.created_at AND T8.end_dt >= T1.created_at 
LEFT JOIN dma.bibt_ref_rework_request_error_users T9 ON T9.rework_request_error_id = T5.errors_id 
LEFT JOIN dma.dma_ref_party_employee T10 ON T10.hr_id = T9.user_hr_id
LEFT JOIN dma.dma_dim_employee_pit T11 ON T10.party_employee_id = T11.party_employee_id AND T11.begin_dt <= T9.created_at AND T11.end_dt >= T9.created_at 
LEFT JOIN (SELECT * FROM dma.bibt_works WHERE workable_type ='rewo.research') T12 ON T1.request_id = T12.workable_id
LEFT JOIN (     SELECT workable_id, work_iot_work_id, SUM(work_count) AS WorkCount 
                FROM dma.bibt_works 
                WHERE workable_type ='rewo.correction' GROUP BY workable_id, work_iot_work_id) T14 ON T5.errors_id = T14.workable_id
LEFT JOIN dma.dma_dim_work_pit T15 ON T14.work_iot_work_id = T15.work_id
WHERE T1.deleted_at IS NULL
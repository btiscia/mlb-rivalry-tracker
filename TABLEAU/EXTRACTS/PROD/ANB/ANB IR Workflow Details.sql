/*
FILENAME: ANNUITY NEW BUSINESS IR WORKFLOW DETAILS
UPDATED BY: John Avgoustakis, Vince Bonaddio 
LAST UPDATED: 07/18/2022
CHANGES MADE: Vertica Migration
*/

SELECT 

	T1.fact_activity_natural_key_hash_uuid AS "Natural Key"
    , T1.source_transaction_id AS "OrderEntryID"
    , T1.product_category AS "Product Category"
    , T1.product AS "Product"
    --, CASE WHEN UPPER(T1.product) like 'MASSMUTUAL%' then substring(T1.product, 12) ELSE T1.product END AS "Product"	
    , T1.distributor AS "Distributor"
    , T1.channel AS "Channel"
    , T1.contract_jurisdiction_state_cde AS "Contract State"
    , coalesce(T1.agent_id, T1.agent_id) AS "AgentID"
    , T1.advisor_nm AS "Advisor"
    , T1.agency_num AS "FirmNum"
    , T1.firm_nm AS "Firm Name"
    , T1.work_event_id AS "WorkEventID"
    , T1.work_event_nm AS "WorkEventName"
    , T1.division_cd AS "DivisionCode"
    , T1.department_cd AS "DepartmentCode"
    , T1.function_nm AS "FunctionName"
    , T1.segment_nm AS "SegmentName"
    , T1.team_party_id AS "TeamPartyID"
    , T1.party_employee_id AS "PartyEmployeeID"
    , ((T1.employee_last_nm || ', '::varchar(2)) || T1.employee_first_nm) AS "Employee"
    , ((T1.manager_last_nm || ', '::varchar(2)) || T1.manager_first_nm)   AS "Manager"
    , T1.organization_nm AS "OrganizationName"
    , T1.department_nm AS "DepartmentName"
    , T1.team_nm AS "TeamName"
    , T1.trans_type_id AS "TransactionTypeID"
    , T1.received_dt AS "ReceivedDate"
    , T1.load_dt AS "LoadDate"
    , T1.completed_dt AS "CompletedDate"
    , T1.tat AS "TAT"
    , T1.tat_goal AS "TATGoal"
    , T1.days_pending AS "DaysPending"
    , T1.days_past_tat AS "Days Past TAT"
    , CAST(T1.ir_igo_ind AS INTEGER) AS "IGOIndicator"
    , T1.suit_igo_ind AS "SuitabilityIGOIndicator"
    , CAST(T1.auto_approved_ind AS INTEGER) AS "AutoApprovedIndicator"
    , T1.replacement_ind AS "ReplacementIndicator"
    , T1.prod_credit AS "ProductivityCredits"
    , T1.application_signed_dt AS "ApplicationSignDate"
    , T1.suitability_approved_dt AS "SuitabilityApprovalDate"
    , T1.original_order_submit_dt AS "OriginalOrderSubmitDate"
    , T5.parent_cancel_dt AS "ParentCancelDate"
    , T1.suitability_submit_dt AS "SuitabilitySubmitDate"
    , CASE WHEN (lower(T5.app_status) = 'cancel/reject'::varchar(13)) THEN T5.app_status_change_dt
           ELSE NULL::timestamp END                                        AS "RejectDate"
    , CASE WHEN (lower(T5.app_status) = 'cancelled'::varchar(9)) THEN T5.app_status_change_dt
           ELSE NULL::timestamp END                                        AS "CancelDate"
    , CASE WHEN (lower(T5.app_status) = 'cancel/rework'::varchar(13)) THEN T5.app_status_change_dt
           ELSE NULL::timestamp END                                        AS "CancelReworkDate"
    , T1.row_process_dtm as "TransDate"
FROM dma_vw.sem_fact_anb_suit_activity_vw T1
LEFT JOIN dma_vw.dim_ipipeline_orders_curr_vw T5 ON T1.source_transaction_id = T5.order_entry_id
WHERE T1.work_event_id IN (27834,27836,27837)
LIMIT 1 OVER (PARTITION BY T1.source_transaction_id, T1.work_event_id, T1.trans_type_id ORDER BY T1.load_dt)


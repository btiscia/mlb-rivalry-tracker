/*
FILENAME: ANB CURRENT PENDING INVENTORY
CREATED BY: Jess Madru
UPDATED BY: John Avgoustakis
LAST UPDATED: 7/6/2022
CHANGES MADE: Repoint to Vertica.
*/

SELECT 
	  T1.r_wobnum  AS "SourceTransactionID"
	, T1.contractnumber AS "Contract"
	, T1.pe_sspolicyprefix AS "Contract Prefix"
	, T1.controlid AS OrderEntryID
	, CAST(T1.r_createdate AS DATE) AS "Received Date"
	, CAST(T1.r_statustime AS DATE) AS "Trans Date"
	, T1.r_statustime AS "Report Date"
	, CAST(T1.t_pendtime AS DATE) AS "Pend Date"
	, T1.worktype AS "Work Type"
	, T1.trantype AS "Transaction Type"
	, T1.document_type AS "Document Type"
	, T3.function_nm AS "Function"
	, T3.segment_nm AS "Segment"
	, T3.work_event_id AS "WorkEventID"
	, T3.tat_goal AS "TAT Goal"
	, T1.t_stepname AS "Work Status"
	, CAST(CURRENT_DATE AS DATE) - CAST(T1.r_statustime AS DATE) AS "Trans Days Pending"
	, CAST(CURRENT_DATE AS DATE) - CAST(T1.r_createdate AS DATE) AS "Days Pending"
	, CAST(CURRENT_DATE AS DATE) - CAST(T1.t_pendtime AS DATE) AS "Pend Days Pending"
    , UPPER(T1.assignedto) AS "AssignedToMMID"
	, T2.organization_nm AS "Organization"
	, T2.department_nm AS "Department"
	, T2.team_nm AS "Team"
	, T2.employee_last_nm||', '||T2.employee_first_nm AS "Employee"
	, T2.role_nm AS "Role"
	, T2.manager_last_nm||', '||T2.manager_first_nm AS "Manager"
	, T1.producerid AS "AgentID"
	, T1.agency AS "Firm"
	, T1.product AS "Product Name"
	, T1.contractstate AS "Contract State"
FROM dma_vw.anb_trex_work_object_vw T1
LEFT JOIN dma_vw.dma_dim_employee_pit_vw T2 ON UPPER(T1.assignedto) = T2.mmid AND T1.r_createdate BETWEEN T2.begin_dt AND T2.end_dt
LEFT JOIN dma_vw.dma_dim_work_curr_vw T3 ON T3.work_event_nm = T1.worktype

WHERE UPPER(T1.t_stepname) IN ('ACTIVE','PEND','NEW')
	AND T1.worktype <> ''
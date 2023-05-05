/*
FILENAME: Hyderabad - DI Claims Pending Inventory
CREATED BY: Jess Madru
CREATED DATE: 5/5/2023 - Contains DI Claims TREX and CATS work for pending inventory reporting
*/

SELECT
T1.Load_dt
,T1.source_transaction_id AS SourceTransactionID
,T1.work_event_system_nm AS "System Name"
,T2.policy_num AS "Policy Number"
,T2.admin_sys AS "Admin System"
,T2.short_claim_num AS "Claim #"
,T1.received_dt AS "Received Date"
,T1.expected_completed_dt  AS "Target Complete Date"
,T1.days_pending  AS "Days Pending"
,T1.days_past_tat AS "Days Past TAT" 
,T1.tat_goal AS "TAT Goal"
,T1.prod_credit as "Productivity Credits"
,COALESCE(T1.employee_role_nm , 'Unknown') AS Role
,COALESCE(T1.employee_last_nm || ', ' || T1.employee_first_nm, 'Unknown') AS Employee	
,COALESCE(T1.manager_last_nm || ', ' || T1.manager_first_nm, 'Unknown') AS Manager
,COALESCE(T1.employee_team_nm, 'Unknown') AS "Team Name"
,COALESCE(T1.work_event_function_nm, 'Unknown') AS FunctionName
,COALESCE(T1.work_event_segment_nm, 'Unknown') AS Segment
,COALESCE(T1.work_event_nm, 'Unknown') AS "Work Event"
,COALESCE(T1.employee_organization_nm, 'Unknown') AS EmployeeOrganizationName
,COALESCE(T1.employee_department_nm, 'Unknown') AS EmployeeDepartmentName
,COALESCE(T1.work_event_organization_nm, 'Unknown') AS WorkEventOrganizationName
,COALESCE(T1.work_event_department_nm	, 'Unknown') AS  WorkEventDepartmentName
,COALESCE(T2.dibs_customer_nm, 'Unknown') AS "Claimant Name" 
,COALESCE(T3.employee_last_nm || ', ' || T3.employee_first_nm, 'Unknown') AS "Logged By" 
,CASE WHEN T1.work_event_system_nm = 'CATS'  THEN 'CATS' 
WHEN	T1.system_department_nm = 'Diary'  THEN 'DIBS Diary' 
WHEN	T1.system_department_nm = 'Payment'   THEN 'DIBS Payment' 
WHEN  T1.system_department_nm = 'TREX CONTENT CLOSURE LETTER'   THEN 'TREX Closure Letter' 
WHEN  T1.system_department_nm = 'TREX CONTENT STATUS LETTER'   THEN 'TREX Status Letter' 
WHEN  T1.system_department_nm = 'TREX CONTENT'   THEN 'TREX Content'
WHEN  T1.system_department_nm = 'TREX MAIL'   THEN 'TREX Mail'
WHEN  T1.system_department_nm = 'TREX WORK'   THEN 'TREX Work'
WHEN T1.work_event_system_nm = 'MEDVOC' THEN 'MEDVOC' 
ELSE 'UNKNOWN' END AS "System"
,T4.review_status as "Work Status"
,T2.appeal_ind AS "Appeal Indicator"
,T2.contestable_ind AS "Contestable Indicator"
,T2.erisa_ind AS "ERISA Indicator"
,T2.late_notice_ind AS "Late Notice Indicator"
,T2.quick_decision_ind AS "Quick Decision Indicator"
,T2.restricted_claim_ind AS "RestrictedClaimIndicator" 
,COUNT(DISTINCT T1.fact_activity_natural_key_hash_uuid) AS "Transaction Count"
,MAX(T1.row_process_dtm)	AS "Transaction Date"    
FROM dma_vw.fact_integrated_gcc_curr_vw T1
LEFT JOIN dma_vw.dic_dim_claim_curr_vw T2 on T1.claim_num = T2.claim_num
LEFT JOIN dma_vw.dma_dim_employee_curr_vw T3 on T1.logged_by_party_employee_id = T3.party_employee_id
LEFT JOIN dma_vw.fact_integrated_dic_curr_vw T4 on T1.fact_integrated_natural_key_hash_uuid = T4.fact_integrated_natural_key_hash_uuid
WHERE T1.trans_type_id = 2
AND T1.Load_dt = CURRENT_DATE
AND T1.work_event_department_nm = 'DI Claims'
GROUP BY  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33
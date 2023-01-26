/*
FILENAME: DI CLAIMS - Current Restricted Pending Inventory
UPDATED BY: Jess Madru
LAST UPDATED: 1/25/2023
Revision: 1/5/2022 - Bill Trombley - Removed Restricted Claim filter.
Revision: 9/27/2022 - Bill Tiscia - converted to Vertica
Revision: 1/25/2023 - Jess Madru - Added Admin System field
*/

SELECT
T1.Load_dt
,T1.fact_activity_natural_key_hash_uuid AS "Integrated Activity ID"
,T1.source_transaction_id AS "Source Transaction ID"
,T1.work_event_system_nm AS "System Name"
,T2.policy_num AS "Policy Number"
,T2.admin_sys AS "Admin System"
,T1.base_claim_num AS "Base Claim Number"
,T1.short_claim_num AS "Claim #"
,T1.received_dt AS "Received Date"
,T1.expected_completed_dt  AS "Expected Completed Date"
,T1.days_pending  AS "Days Pending"
,T1.days_past_tat AS "Days Past TAT" 
,T1.TAT
,T1.tat_goal AS "TAT Goal"
,COALESCE(T1.demand_credit, T1.prod_credit) AS "Productivity Credits"
,COALESCE(T1.employee_role_nm , 'Unknown') AS "Role"
,COALESCE(T1.employee_last_nm || ', ' || T1.employee_first_nm, 'Unknown') AS "Employee Name"	
,COALESCE(T1.manager_last_nm || ', ' || T1.manager_first_nm, 'Unknown') AS "Manager Name"
,COALESCE(T1.employee_team_nm, 'Unknown') AS "Team Name"
,COALESCE(T1.work_event_function_nm, 'Unknown') AS "Function Name"
,COALESCE(T1.work_event_segment_nm, 'Unknown') AS "Segment Name"
,COALESCE(T1.work_event_nm, 'Unknown') AS "Work Event Name"
,COALESCE(T1.employee_organization_nm, 'Unknown') AS "Employee Organization Name"
,COALESCE(T1.employee_department_nm, 'Unknown') AS "Employee Department Name"
,COALESCE(T1.work_event_organization_nm, 'Unknown') AS "Work Event Organization Name"
,COALESCE(T1.work_event_department_nm	, 'Unknown') AS  "Work Event Department Name"
,COALESCE(T1.work_event_primary_role_nm, 'Unknown') AS "Work Event Primary Role Name"
,COALESCE(T1.dibs_customer_nm, 'Unknown') AS "Claimaint Name" 
,COALESCE(T1.logged_by_employee_last_nm || ', ' || T1.logged_by_employee_first_nm, 'Unknown') AS "Logged By"
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
,T1.priority_nm AS "Prioirty"
,T1.review_status as "Work Status"
,T2.appeal_ind AS "Appeal Indicator"
,T1.contestable_ind AS "Contestable Indicator"
,T1.erisa_ind AS "ERISA Indicator"
,T1.late_notice_ind AS "Late Notice Indicator"
,T1.quick_decision_ind AS "Quick Decision Indicator"
,T1.restricted_claim_ind AS "RestrictedClaimIndicator"
,COUNT(DISTINCT T1.fact_activity_natural_key_hash_uuid) AS "Transaction Count"
,MAX(T1.row_process_dtm)	AS "Transaction Date"    
FROM DMA_VW.FACT_INTEGRATED_DIC_CURR_VW T1
INNER JOIN DMA_VW.DIC_DIM_CLAIM_CURR_VW T2 on T1.CLAIM_NUM = T2.CLAIM_NUM 
WHERE T1.trans_type_id = 2
AND T1.Load_dt = CURRENT_DATE
GROUP BY  1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38
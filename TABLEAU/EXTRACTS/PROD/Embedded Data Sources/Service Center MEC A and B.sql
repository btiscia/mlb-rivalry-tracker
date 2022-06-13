/*
FILENAME: Service Center MEC A and B
CREATED BY: Bill Trombley
LAST UPDATED: 4/21/2022
CHANGES MADE: Added WRK.division_cd SE
*/

SELECT DISTINCT
	W1.source_transaction_id
	, trim(LEADING '0' FROM W1.agreement_nr) AS "Policy Number"
	, W1. work_event_nm AS "Work Event"
	, W1.admn_sys_cde AS "Platform"
	, W1.logged_dt AS "Logged Date/Time"
	, W1.Resource AS "Associate"
	, W1.department_cd AS "Department Code"
	, W1.work_event_num AS "Work Event Number"
	, CASE WHEN W1.work_event_num IN (1000, 1004, 1005, 1011, 1030, 1035, 1042, 3113, 3114, 3117, 3118) THEN 'MEC A'
		ELSE 'MEC B' END AS "MEC Type"
	FROM 
		(SELECT DISTINCT WRK.source_transaction_id
			, WRK.agreement_nr
			, EVNT.work_event_nm
			, WRK.admn_sys_cde
			, WRK.logged_dt
			, RSRC.employee_last_nm || ', ' || RSRC.employee_first_nm AS "Resource"
			, WRK.department_cd
			, WRK.work_event_num
		FROM dma_vw.sem_fact_cats_activity_current_vw AS WRK
		INNER JOIN cats_vw.cats_wrk_xtn_vw AS XTN ON WRK.source_transaction_id = XTN.fk_wrk_ident
		INNER JOIN dma_vw.dma_dim_employee_curr_vw AS RSRC ON WRK.logged_by_party_employee_id = RSRC.party_employee_id
		INNER JOIN dma_vw.dma_ref_work_event_vw AS EVNT ON WRK.work_event_num = EVNT.work_event_num
	WHERE WRK.received_dt >= ADD_MONTHS(CURRENT_DATE, -6)
	AND WRK.division_cd = 'CS' AND WRK.department_cd IN ('PA', 'DS', 'SE')
	AND WRK.work_event_num IN (1000, 1004, 1005, 1011, 1030, 1035, 1042, 3113, 3114, 3117, 3118, 626, 629, 632, 1001, 1045, 3243, 3561, 1164, 3560)) W1
	INNER JOIN (SELECT MAX(XTN.MEC_ind) AS MaxMEC
		, WRK.agreement_nr
		, WRK.admn_sys_cde
	FROM dma_vw.sem_fact_cats_activity_current_vw AS WRK
	INNER JOIN cats_vw.cats_wrk_xtn_vw AS XTN ON WRK.source_transaction_id = XTN.fk_wrk_ident 
	WHERE XTN.MEC_ind = 'Y'
	GROUP BY WRK.agreement_nr
		, WRK.admn_sys_cde) W2 	
	ON W1.agreement_nr = W2.agreement_nr AND W1.admn_sys_cde = W2.admn_sys_cde
		
--MEC A = WRK.work_event_num IN (1000, 1004, 1005, 1011, 1030, 1035, 1042, 3113, 3114, 3117, 3118)
--MEC B = WRK.work_event_num IN (626, 629, 632, 1001, 1045, 3243, 3561, 1164, 3560)
/*
Name: Surr_1035_TermCancel
Author: Christina Valenti
Updated By: Jess Madru
Last Updated: 11/3/2022
Updated By:  Lorraine Christian 3/3/2023 - Contract State added
Comments: Repoint to Vertica
*/
SELECT  
a."Function",
a."Segment",
a."Work Event",
a."Work Event Number",
a."Work Event Grouping",
a."Source Transaction Id",
a."Agreement Number",
a."Policy Number",
a."Admin System",
a."Service Channel",
a."Servicing Firm",
a."Logged DateTime",
a."Logged Date",
a."Completed Date",
a."Employee Name",
a."Employee MMID",
a."Issue Date",
a."Policy Age",
a."LOB",
a."Major Product Name",
a."Minor Product Name",
a."Face Amount",
a."Current Status",
a."Turnaround Time",
a."TAT Goal",
a."Met Expected Indicator",
a."Met Expected",
a."CATS Amount",
a."Contract State",
CASE WHEN a."Policy Age"  IS NULL THEN  'Unknown'
	WHEN a."Policy Age"  BETWEEN 0 AND 4 THEN '0-4'
	WHEN a."Policy Age"  BETWEEN 5 AND 9 THEN '5-9'
    WHEN a."Policy Age"  BETWEEN 10 AND 14 THEN '10-14'
    WHEN a."Policy Age"  BETWEEN 15 AND 19 THEN '15-19'							   
	WHEN a."Policy Age"  BETWEEN 20 AND 24 THEN '20-24'
	WHEN a."Policy Age"  BETWEEN 25 AND 29 THEN '25-29'							   
	WHEN a."Policy Age"  BETWEEN 30 AND 34 THEN '30-34'
	WHEN a."Policy Age"  BETWEEN 35 AND 39 THEN '35-39'							   
	WHEN a."Policy Age"  BETWEEN 40 AND 44 THEN '40-44'
	WHEN a."Policy Age"  BETWEEN 45 AND 49 THEN '45-49'								   
	WHEN a."Policy Age"  >= 50 THEN  '50+'
    ELSE 'Unknown'
    END AS "Policy Age Band",
CASE WHEN (a.LOB IS NULL OR a.LOB <>  'Life Insurance' ) THEN  'N/A - Not Life LOB'
	WHEN (a."Face Amount" <  0 OR a."Face Amount"  IS NULL) THEN 'Unknown'
	WHEN a."Face Amount"  BETWEEN 0 AND .49 THEN '$0'
	WHEN a."Face Amount"  BETWEEN 0.50 AND 50000.49 THEN '$1 - $50,000'
	WHEN a."Face Amount"  BETWEEN 50000.50 AND 100000.49 THEN '$50,001 - $100,000'
	WHEN a."Face Amount"  BETWEEN 100000.50 AND 250000.49 THEN '$100,001 - $250,000'
	WHEN a."Face Amount"  BETWEEN 250000.50 AND 500000.49 THEN '$250,001 - $500,000'
	WHEN a."Face Amount"  BETWEEN 500000.50 AND 1000000.49 THEN '$500,001 - $1,000,000'
	WHEN a."Face Amount"  BETWEEN 1000000.50 AND 2000000.49 THEN '$1,000,001 - $2,000,000'
	WHEN a."Face Amount"  BETWEEN 2000000.50 AND 3000000.49 THEN '$2,000,001 - $3,000,000'
	WHEN a."Face Amount"  BETWEEN 3000000.50 AND 5000000.49 THEN '$3,000,001 - $5,000,000'
	WHEN a."Face Amount"  BETWEEN 5000000.50 AND 10000000.49 THEN '$5,000,001 - $10,000,000'	  
	WHEN a."Face Amount"  >= 10000000.50 THEN '$10,000,000+'
	ELSE 'ERROR'
	END AS "Face Amount Band",					 
Sum(a."Transaction Count") AS "Transaction Count"                  
FROM (
SELECT afv.function_nm AS "Function"
	,afv.segment_nm AS "Segment"
	,afv.work_event_nm AS "Work Event"
	,afv.work_event_num AS "Work Event Number"
	,CASE WHEN afv.work_event_nm LIKE '%1035%' THEN '1035' ELSE 'Surrender' END AS "Work Event Grouping"
	,afv.source_transaction_id AS "Source Transaction ID"
	,afv.agreement_nr AS "Agreement Number" -- where this is used because this has been renamed from Holding Key
	,Trim(Leading '0' FROM afv.agreement_nr) AS "Policy Number"
	,afv.admn_sys_cde AS "Admin System"
	,afv.chnl_dspy_nm AS "Service Channel"
	,Coalesce(agentinfo.firm_display_nm, 'Unknown') AS "Servicing Firm"
	,afv.logged_dt AS "Logged DateTime"
	,Cast (afv.logged_dt AS DATE) AS "Logged Date"
	,afv.completed_dt AS "Completed Date"
    ,afv.cash_received_amt as "CATS Amount"
	,afv.employee_last_nm||', '||afv.employee_first_nm AS "Employee Name"
	,afv.mmid AS "Employee MMID"
	,Coalesce(ahv.issue_dt, acv.issue_dt) AS "Issue Date"
	,Coalesce(NullIf(ahv.line_of_business_desc,''), NullIf(acv.line_of_business_desc,''),  'Unknown')  AS "LOB" 
	,Coalesce(NullIf(ahv.major_product_type_desc, ''), NullIf(acv.major_product_type_desc, ''),  'Unknown') AS "Major Product Name"
	,Coalesce(NullIf(ahv.minor_product_type_desc, ''), NullIf(acv.minor_product_type_desc, ''),  'Unknown') AS "Minor Product Name"
	,Coalesce(ahv.face_amt, acv.face_amt) AS "Face Amount"
	,acv.agreement_status_reason_nm AS "Current Status"
	,afv.tat AS "Turnaround Time"
	,afv.met_expected_ind AS "Met Expected Indicator"
	,afv.met_expected AS "Met Expected"
	,afv.tat_goal AS "TAT Goal"
	,acv.contract_jurisdiction_state_cde AS "Contract State"
--use current issue date first because there are some problems with the history table							 
	,CASE WHEN Coalesce(ahv.issue_dt, acv.issue_dt) IS NOT NULL 
	    AND Coalesce(ahv.issue_dt, acv.issue_dt) <> '0001-01-01' 
	    AND Coalesce(ahv.issue_dt, acv.issue_dt) > '1900-01-01' 
		AND Coalesce(ahv.issue_dt, acv.issue_dt) <= Cast (afv.logged_dt AS DATE) 
		THEN ((Cast (afv.logged_dt AS DATE)  - Coalesce(ahv.Issue_dt, acv.issue_dt) ) / 365)::INT
		ELSE NULL
        END AS "Policy Age"  
--Assign value of 1 to the record we want to include when there are multiple rows for one policy number
--This also accounts for more than one servicing firm
	--,Row_Number() Over (PARTITION BY afv.agreemeent_nr
	--ORDER BY afv.agreement_nr, afv.completed_dt DESC, afv.logged_dt DESC, afv.source_transaction_id DESC, agentinfo.begin_dt DESC) AS DuplicatePolicyFilter
	,1 AS "Transaction Count"				  
	FROM dma_vw.sem_fact_cats_activity_current_vw AS afv -- trying to remove the joins by using this semantic table - does this need to be curr or history view?		 
--In force policy info at time of work event 
	LEFT JOIN (Select *
	from edw_semantic_vw.sem_agreement_history_vw
	WHERE agreement_source_cde <> ' Univ'
	LIMIT 1 OVER(PARTITION BY dim_agreement_natural_key_hash_uuid ORDER BY dim_agreement_record_begin_dtm DESC)
	) AS ahv
	ON afv.dim_agreement_natural_key_hash_uuid = ahv.dim_agreement_natural_key_hash_uuid
    and CAST(afv.logged_dt as date) BETWEEN cast(dim_agreement_record_begin_dtm as DATE) AND cast(dim_agreement_record_end_dtm as DATE)	   
--Current in force policy info for status
	LEFT JOIN (Select dim_agreement_natural_key_hash_uuid, agreement_status_reason_nm, issue_dt, line_of_business_desc, major_product_type_desc, minor_product_type_desc, face_amt, contract_jurisdiction_state_cde
	from edw_semantic_vw.sem_agreement_current_vw
	WHERE agreement_source_cde <> 'Univ'
	) AS acv
	ON afv.dim_agreement_natural_key_hash_uuid = acv.dim_agreement_natural_key_hash_uuid
       --AND Coalesce(afv.AgreementId, acv.agreement_id )= acv.agreement_id (using the agreement key hash uuid not sure what this is doing)
--In force Servicing Firm for the policy at the time of the workevent
	LEFT JOIN (SELECT
	            pacv.agreement_nr,
				pacv.agreement_source_cde,
				pacv.dim_agreement_natural_key_hash_uuid,
				right(pacv.writing_agency_cde, 3),
				pacv.writing_agency_cde,
				frm.firm_display_nm, 
				cast(pacv.rel_party_agreement_record_begin_dtm as date) as strt_dt,
				cast(pacv.rel_party_agreement_record_end_dtm as date) as end_dt
				FROM edw_semantic_vw.sem_producer_agreement_history_vw AS pacv 
				JOIN dma_vw.dma_dim_firm_curr_vw as frm
				on right(frm.agency_id,3) = right(pacv.writing_agency_cde, 3)
				WHERE pacv.party_role_cde = 'Agcy'
        		AND pacv.party_sub_role_cde = 'Svc'
 			 LIMIT 1 OVER(PARTITION BY pacv.dim_agreement_natural_key_hash_uuid ORDER BY pacv.begin_dt DESC)
        		) agentinfo
	      		ON  afv.dim_agreement_natural_key_hash_uuid = agentinfo.dim_agreement_natural_key_hash_uuid
	   			--AND Coalesce(afv.AgreementId, agentinfo.agreement_id )= agentinfo.agreement_id --not sure if this is needed
  	   			AND Cast(afv.Logged_dt AS DATE) BETWEEN agentinfo.strt_dt AND agentinfo.end_dt  	   
WHERE afv.trans_type_id = 3
and afv.completed_dt BETWEEN '2020-01-01' AND cast(CURRENT_DATE as Date)
AND afv.work_event_num IN (179, 215, 254, 285, 325, 326, 344, 396, 470, 3004, 3006, 3007, 4543, 4544, 5002, 
		                                                         5082, 5149, 5508, 5511, 5606, 6687, 7056, 7057, 7574, 7575, 7593, 7634, 
																 7693, 7700, 7701, 9573, 9607, 9629, 9901, 10623, 10623, 10858, 10859, 10943, 
																 10944, 10975, 10976, 11204)
) AS a
WHERE 
--a.DuplicatePolicyFilter = 1
--Per Sharon, exclude the few disability records
--AND 
a."LOB" <> 'Disability'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30
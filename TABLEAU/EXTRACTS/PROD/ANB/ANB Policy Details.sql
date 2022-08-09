/*
Name: ANB Modern Policy Details
Author/Editor: Vince Bonaddio / Bill Trombley
Updated By: John Avgoustakis
Last Updated: 7/14/2022
Comments: Repoint to vertica.
*/

SELECT

	  T1.agreement_nr AS "HoldingKey"
	, T1.order_entry_id AS "OrderEntryID"
	, T1.dim_agreement_natural_key_hash_uuid AS "AgreementID"
	, T1.policy_num AS "PolicyNumber"
	, T1.doc_type_nm AS "NewBusinessDocType"
	, T1.contract_jurisdiction_state_cde AS "ContractState"
	, T1.resident_state_cde AS "ResidentState"
	, T1.agent_id AS "AgentID"
	, T1.advisor_nm AS "Advisor"
	, T1.agency_num AS "AgencyNumber"
	, T1.firm_nm AS "FirmName"
	, CASE WHEN UPPER(T1.distributor) = 'SDP' THEN 'MMSD' ELSE T1.distributor END AS "Distributor"
	, T1.channel AS "Channel"
	, T1.market_category_type_cde AS "Market Code"
	, T1.market_type_category AS "Market Category"
	, T1.product AS "Product"
	, T1.product_category AS "Product Category"
	, T1.anticipated_premium AS "AnticipatedPremium"
	, T1.deposit_amt AS "Deposit Amount"
	, T1.bingo_status AS "BINGOStatus"
	, T1.bingo_ind AS "BINGOIndicator"
	, T1.auto_approved_ind AS "AutoApprovalIndicator"
	, CASE WHEN T1.issue_dt >= '2018-08-01' THEN 1 ELSE 0 END AS "IssueCountforBINGORate"
	, T1.application_submit_dt AS "ApplicationSubmitDate"
	, T1.suitability_approved_dt AS "SuitabilityApprovalDate"
	, T1.original_order_submit_dt AS "OriginalOrderSubmitDate"
	, T1.suitability_submit_dt AS "SuitabilitySubmitDate"
	, T1.application_signed_dt AS "ApplicationSignDate"
	, T1.order_change_dt AS "OrderChangeDate"
	, T1.nb_submit_dt AS "NewBusinessSubmitDate"
	, T1.paw_dt AS "PawDate"
	, T1.toa_dt AS "TOADate"
	, T1.bingo_dt AS "BINGODate"
	 --first nigo date [PLEASE CHECK IF NEEDED IN THE REPORTS]
	, T1.final_disposition_dt AS "FinalDispositionDate" --Vince Zach noted final disposition date is new business end date.
	, T1.issue_dt AS "IssueDate"
	, T1.reject_dt AS "RejectDate"
	, T1.withdraw_dt AS "WithdrawnDate"
	, CAST(CURRENT_DATE() AS DATE) - T1.application_submit_dt AS "CALDaysSinceSub"
	, CAST(CURRENT_DATE() AS DATE) - T1.final_disposition_dt AS "CalDaysSinceNBSub"	
	, T1.issue_dt - T1.application_signed_dt AS "CalDaysSignToIssue"
	, T1.application_signed_dt - T1.application_submit_dt AS "CalDaysSignToSub"
	, T1.original_order_submit_dt - T1.application_signed_dt AS "CalDaysAppSignToSuitSub"
	, T1.nb_submit_dt - T1.application_signed_dt AS "CalDaysSignToNBSub"
	, T1.issue_dt - T1.application_submit_dt AS "SubtoIssueCycleTime"
	, T1.nb_submit_dt - T1.application_submit_dt AS "CalDaysSubToNBSub"
	, T1.issue_dt - T1.nb_submit_dt AS "CalDaysNBRcvdToIssued"
	, T1.bingo_dt - T1.nb_submit_dt AS "NBSubToBINGO"
	, T1.paw_dt - T1.nb_submit_dt AS "CalDaysNBSubToPAW"
	, T2.business_day AS "BUSINESSDAY"
	, T1.suitability_approved_dt - T1.suitability_submit_dt AS "CalDaysSuitSubToSuitApvd"
	, T1.nb_submit_dt - T1.suitability_approved_dt AS "CalDaysSuitApvdToNBSub"
	, CAST(T1.order_change_dt AS DATE) - T1.suitability_approved_dt AS "CalDaysSuitApvdToSuitTrans"
	, CAST(T1.order_change_dt AS DATE) - T1.suitability_submit_dt AS "CalDaysSuitSubToSuitTrans"
	, T1.issue_dt - T1.suitability_submit_dt AS "CalDaysSuitSubToIssue"
	, T1.nb_submit_dt - CAST(T1.order_change_dt AS DATE) AS "CalDayssuitCmpltToNBRcvd"
	, T1.paw_dt - T1.bingo_dt AS "CalDaysBINGOToPAW"
	, T1.toa_dt - T1.bingo_dt AS "CalDaysBINGOToTOA"
	, T1.issue_dt - T1.toa_dt AS "CalDaysTOAToIssue"
	, T3.function_nm AS "FUNCTIONNAME"
	, T3.goal_val AS "SLA"
	, T1.row_process_dtm AS "TransDate"
	, T1.final_disposition_dt - T1.nb_submit_dt AS "CalDaysNBSubToFinalDisposition"
	
	-- , CASE WHEN LOWER(T1.doc_type_nm) = 'nb purchase w app' AND UPPER(T3.function_nm) = 'SE2' THEN (SELECT business_day FROM dma_vw.dma_dim_date_vw WHERE short_dt = T1.issue_dt) - T2.business_day
	-- 	   WHEN LOWER(T1.doc_type_nm) = 'incoming transfer' AND UPPER(T3.function_nm) = 'SE2' THEN (SELECT business_day FROM dma_vw.dma_dim_date_vw WHERE short_dt = T1.toa_dt) - T2.business_day
	-- 	   WHEN LOWER(T1.doc_type_nm) = 'annuity application' AND UPPER(T3.function_nm) = 'SE2' THEN (SELECT business_day FROM dma_vw.dma_dim_date_vw WHERE short_dt = T1.paw_dt) - T2.business_day
	--   	   ELSE NULL
	--   END AS "SE2DocTypeCycleTime"
	  
	-- , CASE WHEN LOWER(T1.doc_type_nm) = 'nb purchase w app' AND UPPER(T3.function_nm) = 'HOME OFFICE' THEN (SELECT business_day FROM dma_vw.dma_dim_date_vw WHERE short_dt = T1.issue_dt) - T2.business_day
	-- 	   WHEN LOWER(T1.doc_type_nm) = 'incoming transfer' AND UPPER(T3.function_nm) = 'HOME OFFICE' THEN (SELECT business_day FROM dma_vw.dma_dim_date_vw WHERE short_dt = T1.toa_dt) - T2.business_day
	-- 	   WHEN LOWER(T1.doc_type_nm) = 'annuity application' AND UPPER(T3.function_nm) = 'HOME OFFICE' THEN (SELECT business_day FROM dma_vw.dma_dim_date_vw WHERE short_dt = T1.paw_dt) - T2.business_day
	--   	   ELSE NULL
	--   END AS "HODocTypeCycleTime"
	
	, CASE WHEN LOWER(T1.doc_type_nm) = 'nb purchase w app' THEN (SELECT business_day FROM dma_vw.dma_dim_date_vw WHERE short_dt = T1.issue_dt) - T2.business_day
		   WHEN LOWER(T1.doc_type_nm) = 'incoming transfer' THEN (SELECT business_day FROM dma_vw.dma_dim_date_vw WHERE short_dt = T1.toa_dt) - T2.business_day
		   WHEN LOWER(T1.doc_type_nm) = 'annuity application' THEN (SELECT business_day FROM dma_vw.dma_dim_date_vw WHERE short_dt = T1.paw_dt) - T2.business_day
	  	   ELSE NULL
	  END AS "DocTypeCycleTime"

	, CASE
		   WHEN T1.nb_submit_dt IS NOT NULL AND T1.withdraw_dt IS NOT NULL THEN 'Withdrawn'
		   WHEN T1.nb_submit_dt IS NOT NULL AND T1.reject_dt IS NOT NULL THEN 'Rejected'
		   WHEN T1.nb_submit_dt IS NOT NULL AND T1.issue_dt IS NOT NULL AND T1.issue_dt <> '0001/01/01' THEN 'Issued'
	  END AS "PlacementStatus"	  
	
	, (
	SELECT dma_vw.dma_dim_date_vw.is_holiday 
	FROM dma_vw.dma_dim_date_vw
	WHERE T1.issue_dt = dma_vw.dma_dim_date_vw.short_dt 
	) AS "IssueDateIsHoliday" --need to cast as integer
	
	, (
	SELECT dma_vw.dma_dim_date_vw.is_holiday 
	FROM dma_vw.dma_dim_date_vw
	WHERE T1.application_submit_dt = dma_vw.dma_dim_date_vw.short_dt 
	) AS "AppSubDateIsHoliday" --need to cast as integer
	
	, (
	SELECT dma_vw.dma_dim_date_vw.is_holiday 
	FROM dma_vw.dma_dim_date_vw
	WHERE T1.nb_submit_dt = dma_vw.dma_dim_date_vw.short_dt 
	) AS "NBSubmitDateIsHoliday" --need to cast as integer
	
	, (
	SELECT dma_vw.dma_dim_date_vw.prev_bd
	FROM dma_vw.dma_dim_date_vw
	WHERE dma_vw.dma_dim_date_vw.short_dt = CAST(CURRENT_DATE() AS DATE)
	) AS "PrevBusDayOfToday" --need to cast as integer
	
FROM dma_vw.sem_dim_anb_application_curr_vw T1
LEFT JOIN dma_vw.dma_dim_date_vw T2 ON T1.bingo_dt = T2.short_dt 
LEFT JOIN dma_vw.dma_dim_goal_curr_vw T3 ON lower(T1.doc_type_nm) = lower(T3.trans_type_nm)
	AND (CASE WHEN T3.function_nm = 'SE2' THEN 57 ELSE 73 END) = T1.source_system_id
-- LIMIT 1 OVER(PARTITION BY T1.agreement_nr, T1.doc_type_nm, COALESCE("SE2DocTypeCycleTime", "HODocTypeCycleTime") ORDER BY T1.row_process_dtm)  --coelesce is causing issues with aliased fields

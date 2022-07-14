/*
FILENAME: ANNUITY NEW BUSINESS IR AND SE2
UPDATED BY: John Avgoustakis, Vince Bonaddio 
LAST UPDATED: 07/5/2022
CHANGES MADE: Vertica Migration
*/

		SELECT
			 'IR' AS BINGOType
			, T1.policy_num AS "PolicyNumber"
			, dim_agreement_natural_key_hash_uuid AS "AgreementID"
			, T1.order_entry_id AS "OrderEntryID"
			, T1.initial_review_id AS "InitialReviewID"
			, T1.channel AS "Channel"
			, CASE WHEN T1.distributor = 'SDP' THEN 'MMSD' ELSE T1.distributor END AS Distributor
			, T1.product AS "Product"
			, T1.product_category AS "ProductCategory"
			, T1.resident_state_cde AS ResidenceState
			, T1.firm_num AS "FirmNum"
			, T1.firm_nm AS "FirmName"
			, CAST(T1.agent_id AS VARCHAR(10)) AS "AgentID"
			, T1.advisor_nm AS "Advisor"
			, T1.doc_type_nm AS "DocType"
			, T1.market_category_type_cde AS "MarketTypeCode"
			, T1.market_type_category AS "MarketTypeCategory"
			, T3.category AS "NIGOCategory"
			, T3.nigo_reason AS "NIGOReason"
			, CASE WHEN T2.reject_dt IS NOT NULL THEN 'Rejected'
					WHEN T2.cancel_dt IS NOT NULL THEN 'Canceled'
					WHEN T2.approved_dt IS NOT NULL THEN 'Approved'
		  		ELSE NULL END AS "FinalDisposition"
		  	, T1.nb_submit_dt AS "NewBusinessSubmitDate"
			, T1.application_submit_dt AS "ApplicationSubmitDate"
			, T1.suitability_approved_dt AS "SuitabilityApprovalDate"
			, T1.paw_dt AS "PAWDate"
			, T1.toa_dt AS "TOADate"
			, T2.reject_dt AS "RejectDate"
			, T3.updated_at AS "NIGODate"
			, T2.cancel_dt AS "CancelDate"
			, T2.approved_dt AS "ApprovedDate"
			, CASE WHEN T3.nigo_reason IS NULL THEN T1.suitability_approved_dt
		  		ELSE CAST(COALESCE(T2.reject_dt, T2.cancel_dt, T2.approved_dt, T2.transmit_dt, T1.paw_dt) AS DATE) END AS "IRBINGODate"
		  	, CAST(T3.updated_at AS DATE) AS "IRNIGODate"
			, T4.igo_ind::INT AS "BINGOIndicator"
			, ("IRBINGODate" - COALESCE("IRNIGODate","IRBINGODate")) AS "NIGOResolution"
		    , COALESCE(T2.approved_dt,T2.reject_dt,T2.cancel_dt,T1.paw_dt,T2.transmit_dt) AS "FinalDispositionDate"
			, T1.row_process_dtm AS "TransDate"

		FROM dma_vw.sem_dim_anb_application_curr_vw T1
		
		LEFT JOIN dma_vw.sem_anb_ipipeline_vw T2 ON T2.order_entry_id = T1.order_entry_id
		LEFT JOIN dma_vw.bibt_ir_initial_reviews_token_vw T3 ON T3.initial_review_id = T1.initial_review_id
		LEFT JOIN dma_vw.bibt_rel_initial_reviews_vw T4 ON T4.initial_review_id = T1.initial_review_id 
		WHERE T1.initial_review_id IS NOT NULL
		AND EXTRACT(YEAR FROM T1.final_disposition_dt) >= EXTRACT(YEAR FROM CURRENT_DATE) - 2
		LIMIT 1 OVER(PARTITION BY T1.initial_review_id, T3.nigo_reason ORDER BY T3.updated_at)
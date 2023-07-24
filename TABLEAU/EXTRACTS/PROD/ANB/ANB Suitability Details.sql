/*
Name: ANB Suitability Details
Author/Editor: John Avgoustakis, updated by Jess Madru
Last Updated: 6/1/2023
Comments: Replaced ipipeline views with Suitability report view
Note: This version uses fields added from ipipeline
*/
SELECT 
T1.dim_agreement_natural_key_hash_uuid as "Agreement Key"
, trim(leading '0' from T1.agreement_nr) as "Agreement Number"
,T1.original_order_id as "Original Order ID"    
,T1.order_entry_id as "Order Entry ID"  
,T1.copied_from_trans_id as "Parent Order ID"	
, T1.suitability_submit_dt as "Suitability Submit Date"
, T1.received_dt AS "Received Date" --this is a coalesce of electronic_submit_dt, created_at
, T1.cancel_rework_dt as "Cancel Rework Date"
, T1.suit_comp_dt_transmit as "Transmit Date"	
, T1.suitability_approved_dt as "Suitability Approved Date"  --suitability_approved_dt is suit_complete_dt_approved aliased
, T1.reject_dt AS "Reject Date"
, T1.cancel_dt AS "Cancel Date"
, CASE WHEN T1.reject_dt IS NOT NULL THEN 'Rejected'
      WHEN T1.cancel_dt IS NOT NULL THEN 'Cancelled'
      WHEN T1.cancel_rework_dt IS NOT NULL THEN 'Rework'
 	  WHEN COALESCE(T1.suitability_submit_dt, T1.suitability_approved_dt, T1.suit_comp_dt_transmit) IS NOT NULL THEN 'Transmitted' 
    END AS "Final Disposition" --Final Disposition: Suitability Volume is based on a count of final disposition
, COALESCE(T1.reject_dt, T1.cancel_dt, T1.cancel_rework_dt, T1.suit_comp_dt_transmit, T1.suitability_approved_dt, T1.suitability_submit_dt) AS "Final Disposition Date" 
, CAST("Final Disposition Date" AS Date) -  CAST(T1.suitability_submit_dt AS Date) AS "Suitability Cycle Time"
, T2.cas_ind as "CAS Ind" 
, T1.distributor	AS "Distributor"
, T1.channel AS "Channel"
, T1.product as "Product"
, T1.product_category AS "Product Category" 
, T1.agent_id as "Agent ID"
, T1.advisor_nm as "Advisor"
, T1.agency_num as "Firm Number"
, T1.firm_nm as "Firm Name"
, T1.auto_approved_ind as "Auto Approved Ind"
, T1.parent_cancel_dt AS "Parent Cancel Rework Date"
, CASE WHEN T1.parent_cancel_dt IS NOT NULL THEN 1 ELSE 0 END AS "Resubmit Ind" 
, CAST("Received Date" AS Date) - CAST("Parent Cancel Rework Date" AS Date) AS "Resubmit Lag Time" 
, T5.doc_type_nm as "NB Doc Type"
, CAST(T1.suit_comp_dt_transmit AS DATE) - CAST(T1.received_dt AS DATE) AS "Initial Review Cycle Time" 
, T1.ir_igo_ind as "IGO Ind"
, T1.row_process_dtm as "Trans Date"
FROM dma_vw.sem_fact_anb_suit_activity_vw T1
LEFT JOIN edw_semantic_vw.sem_producer_demographics_current_vw T2 on T1.agent_id = trim(leading '0' from T2.business_partner_id)
LEFT JOIN (SELECT dim_agreement_natural_key_hash_uuid, doc_type_nm FROM dma_vw.anb_doc_type_vw T5 WHERE current_row_ind = 1) T5 ON T1.dim_agreement_natural_key_hash_uuid = T5.dim_agreement_natural_key_hash_uuid
WHERE 
CAST(T1.received_dt AS DATE) >= CURRENT_DATE - INTERVAL '3' YEAR
and T1.division_cd = 'SI' and T1.department_cd = 'SU' and T1.trans_type_id = 3
and (T1.agreement_nr is not null or T1.order_entry_id is not null)
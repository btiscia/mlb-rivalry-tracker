/*
* This routine pulls pindrop_passport_calls_vw data from 7/1/2020 to current
*  with either (a) an lob of Ins Ops or (b) a corresponding Ins Ops transmit record 
*  The result is a complete list of Passport insurance Ops calls
*  for use in data source Fraud Ops All Passport Ins Ops Calls
*  Peer Review & Change Log: 
*  Peer Review Date: 5/10/2022
*  Sources for this routine are dma_vw.pindrop_passport_calls_vw 
*  & dma_vw.enhanced_auth_tier3_call_base_vw
*  Author: Christina Valenti
*  Created: 5/18/2022
*  Revised:
*/
SELECT
	ppcv.pindrop_passport_call_natural_key_hash_uuid,
	ppcv.pindrop_call_id AS "Passport Pindrop Call Id",
	ppcv.correlation_alt_id AS "InContact Id",
	ppcv.phone_num,
	ppcv.call_start_dtm,
	ppcv.ivr_start_dtm,
	ppcv.agent_start_dtm,
	ppcv.call_end_dtm,
	ppcv.duration,
	ppcv.destination_phone_num,
	ppcv.lob,
	ppcv.account,
	ppcv.device_type,
	ppcv.carrier,
	ppcv.location,
	ppcv.caller_id_blacklisted,
	ppcv.caller_id_whitelisted,
	ppcv.risk_result,
	ppcv.auth_result,
	ppcv.auth_policy,
	ppcv.enrollment_pol,
	ppcv.caller_id_validated,
	ppcv.auth_feedback,
	ppcv.auth_score,
	ppcv.device_score,
	ppcv.behavior_score,
	ppcv.voice_score,
	ppcv.risk_score,
	ppcv.device_risk,
	ppcv.behavior_risk,
	ppcv.voice_risk,
	ppcv.row_process_dtm,
	CASE WHEN ppcv.auth_policy = 'No Enrollment Data' 
          OR ppcv.enrollment_pol = 'Profile Creation'
         THEN 'First-Time Caller'
         WHEN ppcv.auth_policy IS null
         THEN 'No Auth Policy'
         ELSE 'Subsequent Caller'     
    END AS caller_status,
    CASE WHEN ppcv.auth_result = true
         THEN 'Authenticated' 
         WHEN ppcv.auth_result = false
         THEN 'Not Authenticated' 
         ELSE cast(ppcv.auth_result AS varchar(20))
    END AS auth_status,
    CASE WHEN ppcv.enrollment_pol = 'Profile Creation'
         THEN 'Enrolled' 
         ELSE 'Not Enrolled'
    END AS new_enrollment,	
	eat.transmit_caller_role AS "Transmit Caller Role"
FROM
	dma_vw.pindrop_passport_calls_vw AS ppcv
LEFT JOIN dma_vw.enhanced_auth_tier3_call_base_vw AS eat 
     ON ppcv.pindrop_call_id = eat.transmit_pindrop_call_id
WHERE
	call_start_dtm >'2020-06-30'
	AND (ppcv.lob = 'Ins Ops'
	OR eat.transmit_pindrop_call_id IS NOT NULL)
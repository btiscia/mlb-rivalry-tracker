/*  
FILENAME: LNB ePOL Final QC Work
CREATED BY: Bill Trombley
LAST UPDATED: 1/24/2023
CHANGES MADE: Vertica SQL Creation
CHANGES MADE:
*/

SELECT DISTINCT
	r_workobjectstepkey AS "Work Item Step Key"
	, wob.r_wobnum AS "Work Item Number"
	, wob.pe_sspolicynumber AS "Policy Number"
	, wob.pe_sworkflowstep AS "Work Item Step"
	, CASE
		WHEN wob.t_action = 'RepairReset' THEN 'Repair'
		ELSE wob.t_action
	END AS "Action in Final QC"
	, wob.r_stepstatus AS "Work Item Step Status"
	, wob.pe_dcreatecasedate AS "WI Create Date"
	, wob.r_starttime AS "WI Step Start Date"
	, wob.r_endtime AS "WI Step End Date"
	, wob.r_lastupdate AS "WI Step Last Update Date"
	, wob.pe_dissuedate AS "Issue Date"
	, wob.r_userid AS "QC By ID"
	, userlkp.r_userlogonname AS "QC By MMID"
	, userlkp.r_username AS "QC By Name"
	, wob.pe_ssadminsystem AS "Admin System"
	, wob.pe_ssagencyaffiliation AS "Firm Code"
	, wob.pe_sprimarylastname AS "Insured Last Name"
	, wob.pe_sprimaryfirstname AS "Insured First Name"
	, wob.pe_sissuerid AS "Issued By ID"
	, wob.pe_sissuername AS "Issued By Name"
	, CASE WHEN wob.t_action = 'RepairReset' THEN 1 ELSE 0 END AS "Currently Routed To Repair"
	, FinalQCWork.EverRoutedToRepair AS "Ever Routed To Repair"
	, CASE WHEN wob.t_action = 'Complete' THEN 1 ELSE 0 END AS "Currently Completed QC"
	, finalqcwork.evercompletedqc AS "Ever Completed QC"
	, wob.pe_sproduct AS Product
	, finalqcwork.firstfinalqcdate "First Final QC Date"
	, finalqcwork.lastfinalqcdate AS "Last Final QC Date"
	, CAST(finalqcwork.workitemcompleteddatetime AS DATE) AS "Work Item Completed Date"
	, finalqcwork.workitemcompleteddatetime AS "Work Item Completed DateTime"
        , wob.row_process_dtm
FROM dma_vw.lnb_epol_trex_work_object_steps_vw wob
LEFT OUTER JOIN dma_vw.lnb_epol_trex_users_vw userlkp ON userlkp.r_userid = wob.r_userid
JOIN (
	SELECT
		wob.r_wobnum
		, finalqcdates.firstfinalqcdate
		, finalqcdates.lastfinalqcdate
		, MAX(CASE
				WHEN wob.pe_sworkflowstep = 'Final QC'
				     AND wob.t_action = 'Complete' THEN 1
				ELSE 0 END) AS evercompletedqc
		, MAX(CASE WHEN wob.pe_sworkflowstep = 'Final QC'
				     AND wob.t_action = 'Complete' THEN r_lastupdate END) AS workitemcompleteddatetime
		, MAX(CASE WHEN wob.t_action = 'RepairReset' AND
			wob.r_lastupdate >= FinalQCDates.firstfinalqcdate THEN 1 ELSE 0 END) AS "EverRoutedToRepair"
	FROM dma_vw.lnb_epol_trex_work_object_steps_vw wob
	LEFT OUTER JOIN (
		SELECT
			r_wobnum
			, MIN(r_lastupdate) AS firstfinalqcdate
			, MAX(r_lastupdate) AS lastfinalqcdate
		FROM dma_vw.lnb_epol_trex_work_object_steps_vw wob
		WHERE pe_sworkflowstep = 'Final QC'
		GROUP BY r_wobnum
	) finalqcdates ON finalqcdates.r_wobnum = wob.r_wobnum
	GROUP BY
		wob.r_wobnum
		, finalqcdates.firstfinalqcdate
		, Finalqcdates.lastfinalqcdate
	HAVING firstfinalqcdate IS NOT NULL
) finalqcwork ON finalqcwork.r_wobnum = wob.r_wobnum
WHERE
	wob.pe_sworkflowstep = 'Final QC'
	AND wob.t_action IN ('RepairReset','Complete')
	AND wob.r_lastupdate >= firstfinalqcdate
	AND (userlkp.r_userlogonname NOT LIKE '%p8%' OR userlkp.r_userlogonname IS NULL)
	AND (userlkp.r_userlogonname NOT LIKE '%epol%' OR userlkp.r_userlogonname IS NULL)
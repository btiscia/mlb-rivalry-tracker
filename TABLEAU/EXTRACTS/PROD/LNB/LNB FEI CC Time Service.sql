/*  
FILENAME: LNB FEI CC Time Service
CREATED BY: Bill Trombley
LAST UPDATED: 1/24/2023
CHANGES MADE: Vertica SQL Creation
CHANGES MADE:
*/

SELECT DISTINCT
	fei_wobs.r_workobjectstepkey AS "Work Item Step Key"
	, fei_wobs.r_wobnum AS "Work Item Number"
	, fei_wobs.pe_sbusinessarea AS "Business Area"
	, fei_wobs.pe_bcontractchange AS "Contract Change Ind"
	, fei_wobs.pe_dcreatecasedate AS "Work Item Create Date Time"
	, CAST(fei_wobs.pe_dcreatecasedate AS DATE) AS "Work Item Create Date"
	, fei_wobs.pe_snbtransactiontype AS "Transaction Type"
	, fei_wobs.r_seqnumber AS "Work Item Step Seq Number"
	, fei_wobs.t_stepname AS "Next Step"
	, CAST(fei_wobs.r_endtime AS DATE) AS "Date To Next Step"
	, fei_wobs.r_endtime AS "Date Time To Next Step"
	, fei_wobs.t_lastuser AS "Associate MMID"
	, CASE
		WHEN mmidlkp.MaxChoiceName IS NOT NULL AND mmidlkp.MaxChoiceName <> '' THEN mmidlkp.MaxChoiceName
		WHEN fei_wobs.t_lastuser IS NOT NULL AND fei_wobs.t_lastuser <> '' THEN fei_wobs.t_lastuser 
		ELSE 'Unknown'
	END AS "Associate Name"
	, fei_wobs.pe_sspolicynumber AS "Policy Number"
	, fei_wobs.pe_sprimaryfirstname AS "Insured First Name"
	, fei_wobs.pe_sprimarylastname AS "Insured Last Name"
	, fei_wobs.r_stepstatus AS "Work Item Step Status"
	, CAST(fei_wobs.r_lastupdate AS DATE) AS "Wk Itm Stp Lst Updt Dt"
	, fei_wobs.r_lastupdate AS "Wk Itm Stp Lst Updt Dt Tm"
        , fei_wobs.r_stepstatustime
FROM dma_vw.lnb_fei_trex_work_object_steps_vw fei_wobs
LEFT OUTER JOIN (
	SELECT 
		chce_val
		, MAX(chce_nm) AS MaxChoiceName
	FROM dma_vw.lnb_mmfilenet_choice_list_lkp_vw 
	WHERE stus_desc = 'ACTIVE'
	GROUP BY chce_val	
) mmidlkp ON LOWER(fei_wobs.t_lastuser) = LOWER(mmidlkp.chce_val)
WHERE
	fei_wobs.pe_sbusinessarea = 'Disability Income'
	AND fei_wobs.pe_snbtransactiontype LIKE 'CC%'
	AND fei_wobs.r_pequeue = 'NBInterface' 
	AND fei_wobs.r_stepstatus <> 'W'
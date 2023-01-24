/*  
FILENAME: LNB FEI Life Time Service
CREATED BY: Bill Trombley
LAST UPDATED: 1/24/2023
CHANGES MADE: Vertica SQL Creation
CHANGES MADE:
*/

SELECT 
    fei_wob.r_wobnum AS "Work Item ID"
    , fei_wob.r_currentworkobjectstepkey AS "Current Work Item Step Key"
    , fei_wob.pe_sbusinessarea AS "Business Area"
    , CAST(fei_wob.r_createdate AS DATE)  AS  "Work Item Create Date"
    , fei_wob.r_createdate AS "Work Item Create Date Time"
    , fei_wob.pe_snbtransactiontype AS "Transaction Type"
    , fei_wob.t_stepname AS "Status"
    , fei_wob.t_lastuser AS "Associate MMID"
    , CASE
        WHEN mmidlkp.MaxChoiceName IS NOT NULL AND mmidlkp.MaxChoiceName <> '' THEN mmidlkp.MaxChoiceName
        WHEN fei_wob.t_lastuser IS NOT NULL AND fei_wob.t_lastuser <> '' THEN fei_wob.t_lastuser 
        ELSE 'Unknown'
    END AS "Associate Name"    
    , fei_wob.pe_sspolicynumber AS "Policy Number"
    , fei_wob.pe_sprimaryfirstname AS "Insured First Name"
    , fei_wob.pe_sprimarylastname AS "Insured Last Name"
    , CAST(fei_wob.r_countabletime AS DATE) AS "Work Item Complete Date"
    , fei_wob.r_countabletime AS "Work Item Complete Date Time"
    , fei_wob.row_process_dtm
FROM dma_vw.lnb_fei_trex_work_object_vw fei_wob
LEFT OUTER JOIN (
    SELECT 
        chce_val
        , MAX(chce_nm) AS MaxChoiceName
    FROM dma_vw.lnb_mmfilenet_choice_list_lkp_vw 
    WHERE stus_desc = 'ACTIVE'
    GROUP BY chce_val    
) mmidlkp ON LOWER(fei_wob.t_lastuser) = LOWER(mmidlkp.chce_val)
WHERE
    fei_wob.pe_sbusinessarea = 'Life Insurance'
    AND fei_wob.pe_snbtransactiontype IN ('Life-Reissue','Life-Initial Review','Life-Interim Requirement','Life-Post Issue Requirement')
    AND fei_wob.t_stepname = 'Complete'
    AND fei_wob.review_status = 'Complete'
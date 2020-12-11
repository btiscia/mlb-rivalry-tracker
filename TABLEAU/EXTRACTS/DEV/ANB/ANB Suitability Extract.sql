--Applications are the process from Original Order Submit Date - Anywhere into the Issue Process
-- Contract is New Business Submit Forward

T1.OriginalOrderID  
,T1.OrderEntryID  --Case Level
,T1.ParentOrderID
, T1.OriginalOrderSubmitDate AS "Suitability Submit Date"
, T1.PendDate AS "Electronic Submit Date" --Electronic Submit Date
, T1.CancelReworkDate
, T1.TransmitDate AS "Transmit Date"
, T1.ApprovedDate AS "Approved Date"
, T1.RejectDate AS "Reject Date"
, T1.CancelDate AS "Cancel Date"
,CASE WHEN COALESCE(T1.ApprovedDate,T1.TransmitDate) IS NOT NULL THEN 'Approved'
            WHEN T1.RejectDate IS NOT NULL THEN 'Rejected'
            WHEN T1.CancelDate IS NOT NULL THEN 'Cancelled'
    END AS "Final Disposition" --Final Disposition --Suitability Volume is based on a count of final disposition
, COALESCE(T1.TransmitDate, T1.ApprovedDate, T1.RejectDate, T1.CancelDate) AS "Final Disposition Date" --Final Disposition Date
, CAST("Suitability Submit Date" AS Date) - CAST("Final Disposition Date" AS Date) AS "Suitability Cycle Time"
--Suitability CycleTime = Original Order Submit Date to Order Status Date (Final Disposition Date)
--Initial Review Cycle Time (TAT) = Pend Date (Electronic Submit Date) to when Katie's time picks it up. We can use this as inventory. Don't worry about this for now.
-- Katies Team TAT
, CASE WHEN CAS_IND = 'N' AND TO_NUMBER(T2.AGENCYNUMBER) IS NOT NULL THEN 'CAB' 
        WHEN TO_NUMBER(T2.AGENCYNUMBER) IS NOT NULL THEN 'CAS'
        ELSE 'Unknown' END AS "Distributor"
, CASE WHEN TO_NUMBER(T2.AGENCYNUMBER) IS NULL THEN 'SDP' ELSE 'MMFA' END AS "Channel"
, CASE WHEN TO_NUMBER(T2.AGENCYNUMBER) IS NULL THEN 'SDP' ELSE 'Non-SDP' END AS "Channel Type"
, OREPLACE(PRODUCTNAME,'MassMutual ','') AS "Product"
, COALESCE(CASE WHEN PRODUCTNAME LIKE '%RetireEase%' THEN 'Income Annuity'
                        WHEN PRODUCTNAME LIKE '%Index Horizons%' THEN 'Fixed Indexed' END,T2.PRODUCTTYPE) AS "Product Category"
, T2.AGENTID
, T6.LST_NM||', '||T6.FIRST_NM AS "Advisor"
, CASE WHEN FirmCodeWithPrefix IS NULL THEN FirmCode
    ELSE FirmCodeWithPrefix END AS Firm
, CASE WHEN T2.AGENCYNUMBER = 'FIL' THEN '244' 
    ELSE T2.AGENCYNUMBER END AS FirmNum
, CASE WHEN FirmNum = 'EDJ' THEN '999 - Edward Jones'
    WHEN FirmCodeWithPrefix IS NULL AND FirmNum IS NULL THEN '999 - Unknown'
    WHEN FirmCodeWithPrefix IS NULL THEN '999 - ' || FirmNum
    ELSE FirmDisplayName END AS "Firm Name"
, CASE WHEN DistributionChannelType = 'DISO' OR FirmCodeWithPrefix IN ('A000','A199') THEN 'CLOSED AGENCIES'
    WHEN DistributionChannelType IN ('DDC','OTHR') OR OriginalFirmCodeWithPrefix IN ('A113','A119','A226','A244','A249') THEN 'Direct Brokerage'
    WHEN OriginalFirmCodeWithPrefix = 'A109' THEN 'Lifebridge Agency'
    WHEN FirmCodeWithPrefix IN ('A020','A028') THEN 'UPPER MIDWEST'
    WHEN FirmCodeWithPrefix IN ('A253','A275') THEN 'MIDWEST-SOCA'
    WHEN FirmCodeWithPrefix = 'A271' THEN 'SE-MW'
    WHEN FirmCodeWithPrefix = 'A262' THEN 'VIRGINA-NORTH'
    WHEN FirmCode IN ('FIL','FILI') THEN 'Fidelity'
    WHEN FirmCodeWithPrefix IS NULL THEN 'UNKNOWN' 
    ELSE Region END AS "Region Name"
, T3.HLDG_KEY AS "Holding Key"
, T2.AutoApprovedIndicator
, T1.ParentCancelDate AS "ParentCancelReworkDate" --(Parent Cancel Rework Date)
, CASE WHEN T1.ParentCancelDate IS NOT NULL THEN 1 ELSE 0 END AS "ResubmitIndicator" -- Use the Electronic Submit Date to Anchor Resubmit Counts
, CAST("Electronic Submit Date" AS Date) - CAST("ParentCancelReworkDate" AS Date) AS "Resubmit Lag Time" -- Resubmit Lag Time, Create this metric when talking to Resubmit Volume - Resubmit Lag Time (Time between Parent Cancel Date and Pend Date)
, CASE WHEN T5.NBPURCHASEWITHAPPINDICATOR = 1 THEN 'NB Purchase w App'
    WHEN T5.INCOMINGTRANSFERINDICATOR = 1 THEN 'Incoming Transfer'
    WHEN T5.ANNUITYAPPINDICATOR = 1 THEN 'Annuity Application'
    WHEN T5.SDELECTAPPINDICATOR = 1 THEN 'SD Elect App'
    WHEN T5.NBREG60INDICATOR = 1 THEN 'NB Reg 60'
    WHEN T5.EXCLUDEDINDICATOR = 1 THEN 'Excluded'
    WHEN T5.OVERLAPINDICATOR = 1 THEN 'Overlap'
    ELSE 'N/A' END AS "NB Doc Type"
, CASE WHEN NIGODATE IS NOT NULL THEN 'Nigo' ELSE 'Bingo' END AS "BINGO Status"
, CASE WHEN NIGODATE IS NOT NULL THEN '0' ELSE '1' END AS "BINGO Indicator"
, CAST(T1.TransmitDate AS DATE) - CAST(T1.PendDate AS DATE) AS InitialReviewCycleTime
, T1.TransDate
FROM PROD_DMA_VW.IPIPELINE_ORDER_FCT_VW T1
LEFT JOIN PROD_DMA_VW.IPIPELINE_ORDERS_VW T2 ON T1.ORDERENTRYID = OREPLACE(T2.ORDERENTRYID,'-','')
LEFT JOIN (SELECT DISTINCT (SUBSTR(TRIM(TRAILING FROM DISTRIBUTION_TRANS_ID),1,10)) ORDER_ENTRY_ID, AGREEMENT_ID, HLDG_KEY
                                , ROW_NUMBER() OVER (PARTITION BY ORDER_ENTRY_ID ORDER BY TRANS_DT) SEQ_NUM
                        FROM PROD_USIG_STND_VW.AGMT_REPLACEMENTS_CMN_VW T1
                        WHERE HLDG_KEY_SFX = ' ' AND SRC_SYS_ID = 57 AND ORDER_ENTRY_ID IS NOT NULL AND ORDER_ENTRY_ID <> ' ' AND ORDER_ENTRY_ID NOT LIKE ALL ('0188%','MMFG%')
                        QUALIFY ROW_NUMBER() OVER (PARTITION BY AGREEMENT_ID ORDER BY TRANS_DT) = 1) T3 ON T1.ORDERENTRYID = T3.ORDER_ENTRY_ID
                        
LEFT JOIN (SELECT DISTINCT AGREEMENTID
                            , CAST(MIN(NIGODate) OVER (PARTITION BY AGREEMENTID) AS DATE) AS NIGODate
                            , MAX(NIGOResolutionDate) OVER (PARTITION  BY AGREEMENTID) AS NIGOResolvedDate
                        FROM PROD_DMA_VW.ANB_NIGO_FCT_VW WHERE SYSTEMID = 34) T4 ON T3.AGREEMENT_ID = T4.AGREEMENTID 
                        
LEFT JOIN (SELECT * FROM PROD_DMA_VW.SE2_DOC_TYPE_HISTORY_VW WHERE TYPE2CURRENTFLAG = 1) T5 ON TRIM(LEADING '0' FROM T3.HLDG_KEY) = T5.CONTRACTNUMBER
LEFT JOIN PROD_USIG_STND_VW.PDCR_DEMOGRAPHICS_VW T6 ON T2.AGENTID = SUBSTR(TRIM(T6.BUSINESS_PARTNER_ID), CHARACTER_LENGTH(TRIM(T6.BUSINESS_PARTNER_ID)) - 5 FOR 6)          
LEFT JOIN PROD_DMA_VW.FIRM_DIM_VW T7 ON T2.AGENCYNUMBER = T7.ORIGINALFIRMCODE
WHERE CAST(PendDate AS DATE) >= '2019-07-01'

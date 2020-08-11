SELECT T1.INVENTORYID 
    , T1.APPLICATIONNATURALKEYUUID
    , T1.ORDERENTRYID
    , T1.AGREEMENTID
    , T1.CONTRACTNUMBER
    ,CASE WHEN T1.TRANSACTIONTYPEID = 1   THEN ReceivedDate
         WHEN T1.TRANSACTIONTYPEID = 2 THEN LoadDate
         WHEN T1.TRANSACTIONTYPEID = 3 THEN CompletedDate END AS "Date"    
    ,"InventoryCurrDayInd"
    , IsHoliday as "Date Is Holiday"
    ,IsWeekday as "Date is Weekeday"
    , T1.AGENTID
    , T8.LST_NM || ', ' || T8.FIRST_NM AS "Advisor"
    , T1.AGENCYNUMBER
    , OREPLACE(COALESCE(T4.PRODUCTNAME,T5.PROD_TYP_NME),'MassMutual ','') AS "Product"
    , CASE WHEN "Product" LIKE '%RetireEase%' THEN 'Income Annuity'
            WHEN "Product" = 'Index Horizons' THEN 'Fixed Indexed'
            ELSE "Product" END AS "Product Category"
    , CASE WHEN T1.AGENCYNUMBER = 'EDJ' THEN '999 - Edward Jones'
        WHEN OriginalFirmCodeWithPrefix IS NULL AND T1.AGENCYNUMBER IS NULL THEN '999 - Unknown'
        WHEN OriginalFirmCodeWithPrefix IS NULL THEN '999 - ' || T1.AGENCYNUMBER
        ELSE FirmDisplayName END AS "Firm Name"
    , COALESCE(TRANSFER_AMOUNT,TOTALINITIALPREMIUM) AS "Anticipated Premium"
    , CASE WHEN TO_NUMBER(T1.AGENCYNUMBER) IS NULL THEN 'SDP'
        WHEN CAS_IND = 'N' AND TO_NUMBER(T1.AGENCYNUMBER) IS NOT NULL THEN 'CAB'
        WHEN TO_NUMBER(T1.AGENCYNUMBER) IS NOT NULL THEN 'CAS'
        ELSE 'Unknown' END AS Distributor
    , CASE WHEN TO_NUMBER(T1.AGENCYNUMBER) IS NULL THEN 'SDP' ELSE 'MMFA' END AS Channel
    , CASE WHEN TO_NUMBER(T1.AGENCYNUMBER) IS NULL THEN 'SDP' ELSE 'Non-SDP' END AS "Channel Type"
    , CASE WHEN FIRST_NIGO_DT IS NOT NULL THEN 'NIGO' ELSE 'BINGO' END AS "Bingo Status"
    , T1.RECEIVEDDATE
    , T1.LOADDATE
    , T1.COMPLETEDDATE
    , T1.TAT
    , T1.DAYSPENDING
    , T2.TRANSACTIONTYPEID
    , T2.TRANSACTIONTYPENAME
    , T3.PLACEMENTSTATUSID
    , T3.PLACEMENTSTATUSDESC
    , T3.INVENTORYSTATUSID
    , T3.INVENTORYSTATUSDESC
    , T3.DECISIONSTATUSID
    , T3.DECISIONSTATUSDESC
    , CASE WHEN RANK() OVER (PARTITION BY APPLICATIONNATURALKEYUUID,"DATE"  ORDER BY T1.TRANSACTIONTYPEID DESC) = 1
                AND T1.TRANSACTIONTYPEID = 2 THEN 1 ELSE 0 END AS "EOD Pending Indicator" 
    ,Case 
    When INVENTORYSTATUSID = 5 and T2.TransactionTypeID = 1 then 1 
    else 0 
 End as "Count Input"
 ,Case 
    When INVENTORYSTATUSID = 5 and T2.TransactionTypeID = 3 then 1 
    else 0 
 End as "Count Throughput"
 ,ReportDate   
FROM PROD_DMA_VW.ANB_INVENTORY_FCT_VW T1
LEFT JOIN PROD_DMA_VW.TRANSACTION_TYPE_LOV_VW T2 ON T1.TRANSACTIONTYPEID = T2.TRANSACTIONTYPEID
LEFT JOIN PROD_DMA_VW.NB_APPL_STATUS_LOV_VW T3 ON T1.APPLICATIONSTATUSID = T3.APPLICATIONSTATUSID
LEFT JOIN PROD_DMA_VW.IPIPELINE_ORDERS_VW T4 ON T1.ORDERENTRYID = T4.ORDERENTRYID
LEFT JOIN PROD_USIG_STND_VW.AGMT_CMN_VW T5 ON T1.AGREEMENTID = T5.AGREEMENT_ID                    
LEFT JOIN PROD_USIG_STND_VW.PDCR_DEMOGRAPHICS_VW T8 ON T1.AGENTID = SUBSTR(TRIM(T8.BUSINESS_PARTNER_ID), CHARACTER_LENGTH(TRIM(T8.BUSINESS_PARTNER_ID)) - 5 FOR 6)
LEFT JOIN PROD_DMA_VW.FIRM_DIM_VW T9 ON T1.AGENCYNUMBER = T9.ORIGINALFIRMCODE
LEFT JOIN (SELECT DISTINCT T1.AGREEMENT_ID, SUM(TOTAL_DOLLAR_AMOUNT) AS "Deposit Amount"
                        FROM PROD_USIG_STND_VW.AGMT_PDCR_FIN_TXN_CMN_VW T1
                        INNER JOIN PROD_USIG_STND_VW.AGMT_CMN_VW T2 ON T1.AGREEMENT_ID = T2.AGREEMENT_ID
                        WHERE BUSINESS_EVENT_CODE In ('75','76','78','79') AND TRANS_AMOUNT_TYPE = 'TNA' AND TXN_DURATION = 1
                        AND EXTRACT(YEAR FROM ISSUE_DT) = EXTRACT(YEAR FROM CYCLE_DATE)
                        GROUP BY 1) T10 ON T1.AGREEMENTID = T10.AGREEMENT_ID                 
LEFT JOIN (SELECT AGREEMENT_ID, SUM(TRANSFER_AMOUNT) AS TRANSFER_AMOUNT FROM PROD_USIG_STND_VW.AGMT_REPLACEMENTS_CMN_VW GROUP BY 1) T11 ON T1.AGREEMENTID = T11.AGREEMENT_ID
LEFT JOIN (SELECT AGREEMENT_ID , MIN(TRANS_DT) AS FIRST_NIGO_DT, MAX(NIGO_RESOLUTION_DATE) AS NIGO_RES_DT
                        FROM PROD_USIG_STND_VW.AGMT_NIGO_CMN_VW GROUP BY 1) T12 ON T1.AGREEMENTID = T12.AGREEMENT_ID
LEFT JOIN   (Select ShortDate
                                            ,PreviousBusinessDay
                                            ,IsHoliday
                                            ,IsWeekday
                                            ,Case
                                                when IsHoliday =0 and Isweekday = 1 then Shortdate
                                                else PreviousBusinessday
                                            end ReportDate
                                            ,Case
                                                When shortDate = Current_Date then 1
                                                Else 0
                                            End as "InventoryCurrDayInd"                      
From PROD_DMA_VW.DATE_DIM_VW ) as ReportDate on "Date" = ShortDate
WHERE Date >= '2020-01-01'
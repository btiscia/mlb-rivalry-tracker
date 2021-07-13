--Dash for IR
SELECT T1.ActivityID
, T1.SourceTransactionID AS OrderEntryID
, T1.WorkID
, T1. WorkEventID
, T9.WorkEventName AS "Work Event"
, T9.FunctionName AS "Function Name"
, T9.SegmentName AS "Segment Name"
, T1.TeamPartyID
, T1.PartyEmployeeID
, T8.EmployeeLastName||', '||T8.EmployeeFirstName AS "Employee"
, T8.ManagerLastName||', '||T8.ManagerFirstName AS "Manager"
, T1.TransactionTypeID
, T1.ReceivedDate AS "Received Date"
, T1.LoadDate AS "Load Date"
, T1.CompletedDate AS "Completed Date"
, T1.TAT
, T1.TATGoal AS "TAT Goal"
, T1.DaysPending AS "Days Pending"
, T1.DaysPastTAT AS "Days Past TAT"
, T1.ReportDate AS "Report Date"
, T1.ProductivityCredits AS "Productivity Credits"
, T1.AgreementID
, T1.HoldingKey AS "Holding Key"
, T1.SourceSystemID
, T1.RunID
, T1.UpdateRunID
, T1.TransDate
, CASE WHEN CAS_IND = 'N' AND TO_NUMBER(T2.AGENCYNUMBER) IS NOT NULL THEN 'CAB'
	WHEN TO_NUMBER(T2.AGENCYNUMBER) IS NOT NULL THEN 'CAS'
	ELSE 'Unknown' END AS "Distributor"
, CASE WHEN TO_NUMBER(T2.AGENCYNUMBER) IS NULL THEN 'SDP' ELSE 'MMFA' END AS "Channel"
--, OREPLACE(PRODUCTNAME,'MassMutual ','') AS "Product"
, CASE
	WHEN ProductName LIKE ('%Capital Vantage%') THEN 'Capital Vantage'
	WHEN ProductName LIKE ('%Transitions Select%') THEN 'Transition Select'
	WHEN ProductName LIKE ('%RetireEase Choice%') THEN 'RetireEase Choice'
	WHEN ProductName LIKE ('%RetireEase%') THEN 'RetireEase'
	WHEN ProductName LIKE ('%Stable Voyage%') THEN 'Stable Voyage'
	WHEN ProductName LIKE ('%Odyssey Select%') THEN 'Odyssey Select'
	WHEN ProductName LIKE ('%Index Horizons%') THEN 'Index Horizons'
	ELSE 'Unknown'
  END AS Product
, COALESCE(CASE WHEN PRODUCTNAME LIKE '%RetireEase%' THEN 'Income Annuity'
  WHEN PRODUCTNAME LIKE '%Index Horizons%' THEN 'Fixed Indexed' END,T2.PRODUCTTYPE) AS "Product Category"
, T2.AGENTID
, T6.LST_NM||', '||T6.FIRST_NM AS "Advisor"
, CASE WHEN FirmCodeWithPrefix IS NULL THEN FirmCode ELSE FirmCodeWithPrefix END AS Firm
, CASE WHEN T2.AGENCYNUMBER = 'FIL' THEN '244'  ELSE T2.AGENCYNUMBER END AS FirmNum
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
, T2.AutoApprovedIndicator
, CASE WHEN T5.NBPURCHASEWITHAPPINDICATOR = 1 THEN 'NB Purchase w App'
    WHEN T5.INCOMINGTRANSFERINDICATOR = 1 THEN 'Incoming Transfer'
    WHEN T5.ANNUITYAPPINDICATOR = 1 THEN 'Annuity Application'
    WHEN T5.SDELECTAPPINDICATOR = 1 THEN 'SD Elect App'
    WHEN T5.NBREG60INDICATOR = 1 THEN 'NB Reg 60'
    WHEN T5.EXCLUDEDINDICATOR = 1 THEN 'Excluded'
    WHEN T5.OVERLAPINDICATOR = 1 THEN 'Overlap'
  ELSE 'N/A' END AS "NB Doc Type"
--, CAST(T1.TransmitDate AS DATE) - CAST(T1.PendDate AS DATE) AS InitialReviewCycleTime
, T10.IGOIndicator  -- Some are Paper apps, Concerned we may be missing the ones that are not electronically submitted.
FROM PROD_DMA_VW.ACT_IPIPELINE_FCT_VW T1
INNER JOIN PROD_DMA_VW.IPIPELINE_ORDERS_VW T2 ON T1.SOURCETRANSACTIONID = OREPLACE(T2.ORDERENTRYID,'-','')
LEFT JOIN (SELECT * FROM PROD_DMA_VW.SE2_DOC_TYPE_HISTORY_VW WHERE TYPE2CURRENTFLAG = 1) T5 ON TRIM(LEADING '0' FROM T1.HoldingKey) = T5.CONTRACTNUMBER
LEFT JOIN PROD_USIG_STND_VW.PDCR_DEMOGRAPHICS_VW T6 ON OREPLACE(T2.AGENTID, 'aa','') = SUBSTR(TRIM(T6.BUSINESS_PARTNER_ID), CHARACTER_LENGTH(TRIM(T6.BUSINESS_PARTNER_ID)) - 5 FOR 6)
LEFT JOIN PROD_DMA_VW.FIRM_DIM_VW T7 ON T2.AGENCYNUMBER = T7.ORIGINALFIRMCODE
LEFT JOIN EMPLOYEE_PIT_DIM_VW T8 ON T1.TeamPartyID = T8.TeamPartyID
LEFT JOIN WORK_EVENT_PIT_DIM_VW T9 ON T1.WorkID = T9.WorkID
LEFT JOIN PROD_DMA_VW.ANB_IR_FORMS_VW T10 ON T1.SOURCETRANSACTIONID = T10.APPLICATIONID

WHERE CAST(CompletedDate AS DATE) >= '2019-07-01'

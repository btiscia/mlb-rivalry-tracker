Select CAST('LifeCare' AS VARCHAR(15)) As "System"
	, T1.PolicyNum As "Policy Number"
	, T1.STUS_CTGY_DESC As "Contract Status"
	, Case When T1.STUS_CTGY_DESC In ('Premium Paying', 'Surrendered', 'Lapsed', 'Free Look') Then 'Reported' 
		When T1.STUS_CTGY_DESC In ('Pending Requirements') Then 'Submitted, Not Issued' 
		When T1.STUS_CTGY_DESC In ('Issued Reportable') Then 'Issued, Not Reported' 
		Else T1.STUS_CTGY_DESC End As "Status Description"
	, 'SignatureCare' As "Product Category"
	, T1.Product As "Product Type"
	, CASE WHEN T4.CAS_IND = 'N' AND TO_NUMBER(T2.AGT_WRTG_AGY_CD) IS NOT NULL THEN 'CAB' ELSE 'CAS' END AS "Channel"
	, CASE WHEN DistributionChannelType = 'DISO' OR FirmCodeWithPrefix IN ('A000','A199') THEN 'CLOSED AGENCIES'
		WHEN DistributionChannelType IN ('DDC','OTHR') OR OriginalFirmCodeWithPrefix IN ('A113','A119','A226','A244','A249') THEN 'Direct Brokerage'
		WHEN OriginalFirmCodeWithPrefix = 'A109' THEN 'Lifebridge Agency'
		WHEN FirmCodeWithPrefix IN ('A020','A028') THEN 'UPPER MIDWEST'
		WHEN FirmCodeWithPrefix IN ('A253','A275') THEN 'MIDWEST-SOCA'
		WHEN FirmCodeWithPrefix = 'A271' THEN 'SE-MW'
		WHEN FirmCodeWithPrefix = 'A262' THEN 'VIRGINA-NORTH'
		WHEN FirmCode IN ('FIL','FILI') THEN 'Fidelity'
		WHEN FirmCodeWithPrefix IS NULL THEN 'UNKNOWN' 
		ELSE Region END AS "Region"
	, CASE WHEN FirmCodeWithPrefix IS NULL THEN FirmCode
		ELSE FirmCodeWithPrefix END AS "Firm Number"
	, CASE WHEN FirmCodeWithPrefix IS NULL THEN '999 - Unknown'
		ELSE FirmDisplayName END AS "Firm Name"
	, T4.LST_NM || ', ' || T4.FIRST_NM As "Advisor"
	, T1.CTRT_JURISDICTION As "Contract State"
	, T1.STATE As "Residence State"
	, T1.HO_RECEIPT_DATE As "Submit Date"
	, Case When T1.STUS_CTGY_DESC Like 'ISS%' Then T1.IS_Date 
		When (T1.STUS_CTGY_DESC Like 'Not T%' Or T1.STUS_CTGY_DESC Like 'FREE%' Or T1.STUS_CTGY_DESC Like 'LAP%' Or T1.STUS_CTGY_DESC Like 'Pre%' Or T1.STUS_CTGY_DESC Like 'Sur%' Or T1.STUS_CTGY_DESC Like 'Res%') And T1.IS_Date > '2015-07-23' Then T1.IS_Date 
		When (T1.STUS_CTGY_DESC Like 'Not T%' Or T1.STUS_CTGY_DESC Like 'FREE%' Or T1.STUS_CTGY_DESC Like 'LAP%' Or T1.STUS_CTGY_DESC Like 'Pre%' Or T1.STUS_CTGY_DESC Like 'Sur%' Or T1.STUS_CTGY_DESC Like 'Res%') And T1.ISSUE_DT <> '0001-01-01' Then T1.ISSUE_DT 
		When (T1.STUS_CTGY_DESC Like 'Not T%' Or T1.STUS_CTGY_DESC Like 'FREE%' Or T1.STUS_CTGY_DESC Like 'LAP%' Or T1.STUS_CTGY_DESC Like 'DEA%') And T1.POLICY_EFF_DATE >= T1.HO_RECEIPT_DATE Then T1.POLICY_EFF_DATE 
		When (T1.STUS_CTGY_DESC Like 'Not T%' Or T1.STUS_CTGY_DESC Like 'FREE%' Or T1.STUS_CTGY_DESC Like 'LAP%' Or T1.STUS_CTGY_DESC Like 'DEA%') Then T1.HO_RECEIPT_DATE 
		When T1.IS_Date Is Not Null And T1.IS_Date > '2015-07-23' Then T1.IS_Date End As "Issue Date"
	, CASE WHEN ISSUE_DT IS NOT NULL AND T1.STUS_CTGY_DESC LIKE 'Not%' AND ISSUE_DT < "Issue Date" THEN "Issue Date"
		WHEN ISSUE_DT IS NULL AND T1.STUS_CTGY_DESC NOT LIKE 'Not%' THEN ISSUE_DT END AS "Reported Date"
	, Case When T1.STUS_CTGY_DESC Like 'Not T%' And T1.NT_NR_Date = '2015-07-23' Then T1.HO_RECEIPT_DATE 
		When T1.STUS_CTGY_DESC Like 'Not T%' Then T1.NT_NR_Date End As "Not Taken Date"
	, Case When T1.STUS_CTGY_DESC Like 'Dec%' And T1.DN_Date = '2015-07-23' Then T1.HO_RECEIPT_DATE 
		When T1.STUS_CTGY_DESC Like 'Dec%' Then T1.DN_Date End As "Decline Date"
	, Case When T1.STUS_CTGY_DESC Like 'With%' And T1.WT_Date > '2015-07-23' Then T1.WT_Date 
		When T1.STUS_CTGY_DESC Like 'With%' Then T1.HO_RECEIPT_DATE 
		When T1.STUS_CTGY_DESC Like 'In%' Then T1.IN_Date End As "Incomplete Withdrawn Date"
	, CASE WHEN "Reported Date" IS NOT NULL THEN 'Reported'
		WHEN T1.STUS_CTGY_DESC LIKE 'Not%' THEN 'Not Taken'
		WHEN T1.STUS_CTGY_DESC LIKE 'Dec%' THEN 'Declined'
		WHEN T1.STUS_CTGY_DESC LIKE ANY ('With%','Inc%') THEN 'Incomplete/Withdrawn' END AS "Placement Status"
	, CASE WHEN "Reported Date" IS NOT NULL THEN "Reported Date"
		WHEN T1.STUS_CTGY_DESC LIKE 'Not%' THEN "Not Taken Date"
		WHEN T1.STUS_CTGY_DESC LIKE 'Dec%' THEN "Decline Date"
		WHEN T1.STUS_CTGY_DESC LIKE ANY ('With%','Inc%') THEN "Incomplete Withdrawn Date" END AS "Placement Status Date"
	
	, T1.WeightedPremium As "Anticipated Premium"
	, "Issue Date" - "Submit Date" AS "SubmitToIssueCycleTime"
	, "Reported Date" - "Issue Date" AS "IssueToReportedCycleTime"
	, "Reported Date" - "Submit Date" AS "SubmitToReportedCycleTime"
	, CAST(NULL AS VARCHAR(25)) As "PlanMetric"
	, CAST(NULL AS DECIMAL(15,3)) As "Daily KPI Plan"
	, CAST(NULL AS DECIMAL(15,3)) As "Daily MTD Plan"
	,(SELECT BusinessDay 
	   FROM PROD_DMA_VW.DATE_DIM_VW
	   WHERE "Submit Date" = ShortDate) AS "Submit Business Day"
	
	,(SELECT PreviousBusinessDay 
	   FROM PROD_DMA_VW.DATE_DIM_VW
	   WHERE "Submit Date" = ShortDate) AS "Submit Previous Business Day"
	
	,(SELECT BusinessDay 
	   FROM PROD_DMA_VW.DATE_DIM_VW
	   WHERE "Issue Date" = ShortDate) AS "Issue Business Day"
	
	,(SELECT PreviousBusinessDay 
	   FROM PROD_DMA_VW.DATE_DIM_VW
	   WHERE "Issue Date" = ShortDate) AS "Issue Previous Business Day"
	
	,(SELECT PreviousBusinessDay 
	   FROM PROD_DMA_VW.DATE_DIM_VW
	   WHERE ShortDate = CAST(Current_Date AS DATE)) AS "PreviousBusinessDayOfToday"
	
	,(SELECT IsHoliday 
	   FROM PROD_DMA_VW.DATE_DIM_VW
	   WHERE "Submit Date" = ShortDate) AS "Submit Date Is Holiday"
	
	,(SELECT IsHoliday 
	   FROM PROD_DMA_VW.DATE_DIM_VW
	   WHERE "Issue Date" = ShortDate) AS "Issue Date is Holiday"
	
	,(SELECT IsHoliday 
	   FROM PROD_DMA_VW.DATE_DIM_VW
	   WHERE "Placement Status Date" = ShortDate) AS "Placement Status Date is Holiday"
	
	,(SELECT IsHoliday 
	   FROM PROD_DMA_VW.DATE_DIM_VW
	   WHERE "Reported Date" = ShortDate) AS "Reported Date is Holiday"
	
	,CASE WHEN "Status Description" IN ('Submitted, Not Issued', 'Issued, Not Reported') THEN 1 ELSE 0 END AS "Pending Indicator"
	
From (Select T2.AGREEMENT_ID
			, T1.SRC_SYS_ID
			, T1.STUS_CTGY_DESC
			, CAST(TRIM(LEADING '0' FROM T1.HLDG_KEY) AS INTEGER) As PolicyNum
			, T1.HO_RECEIPT_DATE
			, T1.POLICY_EFF_DATE As POLICY_EFF_DATE
			, T1.CTRT_JURISDICTION
			, T1.ISSUE_DT
			, T4.LST_NM As InsuredLast
			, T4.FIRST_NM As InsuredFirst
			, T5.GOVT_ID_NR
			, T5.STATE 
			, Max(T2.PROD_TYP_NME) As Product
			, Min(Case When T2.AGMT_HIST_TO_DT = '9999-12-31 00:00:00.00000' Then T2.ANNUALIZED_PREM_AMT End) As WeightedPremium
			, Min(Case When T2.STUS_RSN = 'DN' Then Cast(T2.AGMT_HIST_FR_DT As Date) End) As DN_Date
			, Min(Case When T2.STUS_RSN = 'IS' Then Cast(T2.AGMT_HIST_FR_DT As Date) End) As IS_Date
			, Min(Case When T2.STUS_RSN In ('NT', 'NR') Then Cast(T2.AGMT_HIST_FR_DT As Date) End) As NT_NR_Date
			, Min(Case When T2.STUS_RSN = 'IN' Then Cast(T2.AGMT_HIST_FR_DT As Date) End) As IN_Date
			, Min(Case When T2.STUS_RSN = 'PP' Then Cast(T2.AGMT_HIST_FR_DT As Date) End) As PP_Date
			, Min(Case When T2.STUS_RSN = 'WT' Then Cast(T2.AGMT_HIST_FR_DT As Date) End) As WT_Date
		FROM PROD_USIG_STND_VW.AGMT_CMN_VW T1 
		INNER JOIN PROD_USIG_STND_VW.AGMT_STND_DATA_HIST_VW T2 ON T1.AGREEMENT_ID = T2.AGREEMENT_ID AND T2.AGREEMENT_SOURCE_CD = 'LFCARE' AND T2.HLDG_KEY_SFX = '' 
		INNER JOIN PROD_USIG_STND_VW.AGMT_STND_DATA_VW T3 ON T2.AGREEMENT_ID = T3.AGREEMENT_ID 
		LEFT JOIN PROD_USIG_STND_VW.CUST_AGMT_CMN_VW T4 ON T1.AGREEMENT_ID = T4.AGREEMENT_ID AND T4.PRTY_AGMT_RLE_CD = 'INSD' AND T4.PRTY_AGMT_RLE_STYP_CD = 'PRMR' 
		LEFT JOIN PROD_USIG_STND_VW.CUST_DEMOGRAPHICS_VW T5 ON T4.PRTY_ID = T5.PRTY_ID 
		WHERE T1.HO_RECEIPT_DATE >= Current_Date - INTERVAL '5' YEAR
		GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12) T1 
LEFT JOIN PROD_USIG_STND_VW.PDCR_AGMT_CMN_VW T2 ON T1.AGREEMENT_ID = T2.AGREEMENT_ID AND T2.PRTY_AGMT_RLE_STYP_CD = 'SVC' AND T2.PRTY_AGMT_RLE_CD = 'AGT' 
LEFT JOIN (SELECT AGREEMENT_ID, HLDG_KEY, PRTY_AGMT_RLE_STYP_CD, PRTY_AGMT_RLE_CD, Min(BUSINESS_PARTNER_ID) As MIN_AGENT_ID
							FROM PROD_USIG_STND_VW.PDCR_AGMT_CMN_VW 
							WHERE PRTY_AGMT_RLE_STYP_CD = 'SVC' And PRTY_AGMT_RLE_CD = 'AGT' 
							GROUP BY 1,2,3,4) T3 ON T2.AGREEMENT_ID = T3.AGREEMENT_ID AND T2.BUSINESS_PARTNER_ID = T3.MIN_AGENT_ID 
LEFT JOIN PROD_USIG_STND_VW.PDCR_DEMOGRAPHICS_VW T4 ON T2.PRTY_ID = T4.PRTY_ID 
LEFT JOIN PROD_USIG_STND_VW.AGMT_SUMMARY_DATA_VW T5 ON T1.AGREEMENT_ID = T5.AGREEMENT_ID
LEFT JOIN PROD_DMA_VW.FIRM_DIM_VW T6 ON RIGHT(T2.AGT_WRTG_AGY_CD,3) = T6.OriginalFirmCode
LEFT JOIN (Select Cast(MM_ID As VarChar(6)) As MetProducerID, LST_NM As ProducerLastName, FIRST_NM As ProducerFirstName 
						From PROD_USIG_CMN_VW.MET_AGT_POINTINTIME_VW) T7 ON RIGHT(T4.BUSINESS_PARTNER_ID,6) = T7.MetProducerID
--;
				
UNION ALL

SELECT CAST('Plan' AS VARCHAR(15)) AS "System"
, CAST(NULL AS INTEGER) AS "Policy Number"
, CAST(NULL AS VARCHAR(60)) AS "Contract Status"
, CAST(NULL AS VARCHAR(60)) AS "Status Description"
,'SignatureCare' AS "Product Category"
,ProductName AS  "Product Type"
,CASE
	WHEN SalesGroup = 'MMCAS' THEN 'MMFA'
	WHEN SalesGroup = 'Total' THEN 'Total'
	ELSE 'SDP'
END AS "Channel"
,CAST(NULL AS VARCHAR(25)) AS "Region"
,CAST(NULL AS VARCHAR(5)) AS "Firm Number"
,CAST(NULL AS VARCHAR(72)) AS "Firm Name"
,CAST(NULL AS VARCHAR(202)) AS "Advisor"
,CAST(NULL AS VARCHAR(2)) AS "Contract State"
,CAST(NULL AS VARCHAR(100)) AS "Residence State"
,CASE
	WHEN Volumetric LIKE '%Submitted%' THEN ShortDate
	ELSE NULL
END AS "Submit Date"
,CASE
	WHEN Volumetric LIKE '%Issued%' OR Volumetric LIKE '%Reported%' THEN ShortDate
	ELSE NULL
END AS "Issue Date"
,CASE
	WHEN Volumetric LIKE '%Issued%' OR Volumetric LIKE '%Reported%' THEN ShortDate
	ELSE NULL
END AS "Reported Date"
, CAST(NULL AS DATE) AS "Not Taken Date"
, CAST(NULL AS DATE) AS "Decline Date"
, CAST(NULL AS DATE) AS "Incomplete Withdrawn Date"
, CAST(NULL AS VARCHAR(20)) AS "Placement Status"
, CAST(NULL AS DATE) AS "Placement Status Date"
, CAST(NULL AS DECIMAL(19,2)) AS "Anticipated Premium"
, CAST(NULL AS INTEGER) AS "SubmitToIssueCycleTime"
, CAST(NULL AS INTEGER) AS "IssueToReportedCycleTime"
, CAST(NULL AS INTEGER) AS "SubmitToReportedCycleTime"
,Volumetric AS "PlanMetric"
,DailyKPIPlan As "Daily KPI Plan"
,DailyMTDPlan AS "Daily MTD Plan"
,(SELECT BusinessDay 
   FROM PROD_DMA_VW.DATE_DIM_VW
   WHERE T1.ShortDate = ShortDate) AS "Submit Business Day"

,(SELECT PreviousBusinessDay
   FROM PROD_DMA_VW.DATE_DIM_VW
   WHERE T1.ShortDate = ShortDate) AS "Submit Previous Business Day"

,(SELECT BusinessDay
   FROM PROD_DMA_VW.DATE_DIM_VW
   WHERE T1.ShortDate = ShortDate) AS "Issue Business Day"

,(SELECT PreviousBusinessDay 
   FROM PROD_DMA_VW.DATE_DIM_VW
   WHERE T1.ShortDate = ShortDate) AS "Issue Previous Business Day"

,(SELECT PreviousBusinessDay 
   FROM PROD_DMA_VW.DATE_DIM_VW
   WHERE ShortDate = CAST(Current_Date AS DATE)) AS "PreviousBusinessDayOfToday"

,(SELECT IsHoliday
   FROM PROD_DMA_VW.DATE_DIM_VW
   WHERE T1.ShortDate = ShortDate) AS "Submit Date Is Holiday"

,(SELECT IsHoliday
   FROM PROD_DMA_VW.DATE_DIM_VW
   WHERE T1.ShortDate = ShortDate) AS "Issue Date is Holiday"

,(SELECT IsHoliday
   FROM PROD_DMA_VW.DATE_DIM_VW
   WHERE T1.ShortDate = ShortDate) AS "Placement Status Date is Holiday"

,(SELECT IsHoliday
   FROM PROD_DMA_VW.DATE_DIM_VW
   WHERE T1.ShortDate = ShortDate) AS "Reported Date is Holiday"

,NULL AS "Pending Indicator"

FROM PROD_DMA_VW.PRD_KPI_PLAN_DATA_VW T1
WHERE DEPARTMENTID NOT IN (37,47,15)

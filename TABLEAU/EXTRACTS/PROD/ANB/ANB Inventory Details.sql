/*
FILENAME: ANB Inventory Details
UPDATED BY: Jess Madru 
LAST UPDATED: 08/24/2022
CHANGES MADE: Vertica Migration
*/

SELECT	DISTINCT T1.fact_inventory_natural_key_hash_uuid AS InventoryID
	, T1.dim_agreement_natural_key_hash_uuid AS ApplicationNaturalKeyUUID
	, order_entry_id AS OrderEntryID
	, T1.agreement_nr AS AgreementID 
	, TRIM(LEADING '0' FROM T1.agreement_nr) AS ContractNumber
	, T2.ReportDate AS "Date"
	,"InventoryCurrDayInd"
    , IsHoliday AS "Date Is Holiday"
    , IsWeekDay AS "Date Is Weekday"
	, agent_id AS AgentID
	, advisor_nm AS Advisor  
	, agency_num AS AgencyNumber
	, CASE
   		WHEN T1.product LIKE ('%Capital Vantage%') THEN 'Capital Vantage'
   		WHEN T1.product LIKE ('%Transition Select%') THEN 'Transition Select'
  		WHEN T1.product LIKE ('%RetireEase Choice%') THEN 'RetireEase Choice'
   		WHEN T1.product LIKE ('%RetireEase%') THEN 'RetireEase'
   		WHEN T1.product LIKE ('%Stable Voyage%') THEN 'Stable Voyage'
   		WHEN T1.product LIKE ('%Odyssey Select%') THEN 'Odyssey Select'
   		WHEN T1.product LIKE ('%Index Horizons%') THEN 'Index Horizons'
   		WHEN T1.product LIKE ('%Envision%') THEN 'Envision'
   		ELSE 'Unknown'
	  END AS Product
	, product_category AS "Product Category"
	, agency_id_prefix AS Firm
	, firm_num AS "FirmID"
	, CASE WHEN agency_num is NULL and firm_nm is NULL then '999 - Unknown' ELSE firm_nm END AS "FirmName" 
	, anticipated_premium AS "Anticipated Premium"
	, CASE WHEN UPPER(distributor) = 'SDP' THEN 'MMSD' ELSE distributor END AS "Distributor"
	, channel AS Channel
	, bingo_status AS "Bingo Status"
	, CASE 
		When T1.doc_type_nm  IS Null THEN 'N/A'
		Else T1.doc_type_nm
		End as NewBusinessDocType
	, received_dt AS ReceivedDate
	, load_dt AS LoadDate
	, completed_dt AS CompletedDate
	, tat AS TAT
	, days_pending AS DaysPending
	, transaction_type_id AS TransactionTypeID
	, transaction_type_nm AS TransactionTypeName
	, placement_status_desc AS PlacementStatusDescription
	, inventory_status_desc AS InventoryStatusDescription
	, decision_status_desc AS DecisionStatusDescription
	, CASE WHEN RANK() OVER (PARTITION BY APPLICATIONNATURALKEYUUID,"DATE"  ORDER BY T1.transaction_type_id DESC) = 1
			AND T1.transaction_type_id = 2 THEN 1 ELSE 0 END AS "EOD Pending Indicator" 
    , CASE WHEN Lower (inventory_status_desc) = 'new business review' AND transaction_type_id = 1 THEN 1 
    		ELSE 0 END AS "Count Input"
	, CASE WHEN Lower (inventory_status_desc) = 'new business review' AND transaction_type_id = 3 THEN 1 
    		ELSE 0 END AS "Count Throughput"
    ,T2.ReportDate
    ,T2.IsHoliday
    ,T2.IsWeekday
FROM dma_vw.sem_fact_inventory_anb_vw T1
LEFT JOIN   (SELECT short_dt, prev_bd, CAST(is_holiday AS INTEGER) AS "IsHoliday", CAST(is_weekday AS INTEGER) AS "IsWeekDay"
			 ,CASE WHEN is_holiday = False AND is_weekday = True THEN short_dt ELSE prev_bd END AS ReportDate
			 ,CASE WHEN short_dt = CURRENT_DATE THEN 1 ELSE 0 END AS "InventoryCurrDayInd"
			 FROM dma_vw.dma_dim_date_vw ) T2 ON T1.report_dt = short_dt
WHERE T1.report_dt >= '2020-01-01'
AND days_pending <= 200 
OR days_pending IS Null
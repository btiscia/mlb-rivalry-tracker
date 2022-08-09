/*
FILENAME: ANB Inventory Details
CREATED BY: Bill Trombley
LAST UPDATED: 7/8/2022
CHANGES MADE: Added NewBusinessDocType
*/

SELECT	DISTINCT InventoryID
	, ApplicationNaturalKeyUUID
	, OrderEntryID
	, T1.AgreementID
	, ContractNumber
	, T1.ReportDate AS "Date"
	,"InventoryCurrDayInd"
    , IsHoliday AS "Date Is Holiday"
    , IsWeekday AS "Date Is Weekday"
	, AgentID
	, Advisor
	, AgencyNumber
	, Product
	, ProductCategory AS "Product Category"
	, Firm
	, FirmNum AS "FirmID"
	, FirmName AS "Firm Name"
	, RegionName
	, AnticipatedPremium AS "Anticipated Premium"
	, CASE WHEN Distributor = 'SDP' THEN 'MMSD' ELSE Distributor END AS Distributor
	, Channel
	, ChannelType AS "Channel Type"
	, BINGOStatus AS "Bingo Status"
	,CASE WHEN T3.NBPurchaseWAppIndicator = 1 THEN 'NB Purchase w App'
		WHEN T3.INCOMINGTRANSFERINDICATOR = 1 THEN 'Incoming Transfer'
		WHEN T3.ANNUITYAPPINDICATOR = 1 THEN 'Annuity Application'
		WHEN T3.SDElectIndicator = 1 THEN 'SD Elect App'
		WHEN T3.NBREG60INDICATOR = 1 THEN 'NB Reg 60'
		WHEN T3.EXCLUDEDINDICATOR = 1 THEN 'Excluded'
		WHEN T3.OVERLAPINDICATOR = 1 THEN 'Overlap'
		ELSE 'N/A' END AS NewBusinessDocType
	,ReceivedDate
	, LoadDate
	, CompletedDate
	, TAT
	, DaysPending
	, TransactionTypeID
	, TransactionTypeName
	, PlacementStatusID
	, PlacementStatusDescription
	, InventoryStatusID
	, InventoryStatusDescription
	, DecisionStatusID
	, DecisionStatusDescription
	, CASE WHEN RANK() OVER (PARTITION BY APPLICATIONNATURALKEYUUID,"DATE"  ORDER BY T1.TRANSACTIONTYPEID DESC) = 1
			AND T1.TRANSACTIONTYPEID = 2 THEN 1 ELSE 0 END AS "EOD Pending Indicator" 
    , CASE WHEN INVENTORYSTATUSID = 5 AND TRANSACTIONTYPEID = 1 THEN 1 
    		ELSE 0 END AS "Count Input"
	, CASE WHEN INVENTORYSTATUSID = 5 AND TRANSACTIONTYPEID = 3 THEN 1 
    		ELSE 0 END AS "Count Throughput"
    ,T2.ReportDate
    ,T2.IsHoliday
    ,T2.IsWeekday
FROM	PROD_DMA_VW.ANB_INVENTORY_RPT_VW T1

LEFT JOIN   (SELECT ShortDate, PreviousBusinessDay, IsHoliday, IsWeekday
							,CASE WHEN IsHoliday =0 AND Isweekday = 1 THEN Shortdate ELSE PreviousBusinessday END AS ReportDate
							,CASE WHEN shortDate = CURRENT_DATE THEN 1 ELSE 0 END AS "InventoryCurrDayInd"
						FROM PROD_DMA_VW.DATE_DIM_VW ) T2 ON "Date" = ShortDate

LEFT JOIN PROD_DMA_VW.ANB_DOC_TYPE_CMN_VW T3 ON T3.HoldingKey = T1.ContractNumber

WHERE DATE >= '2020-01-01'
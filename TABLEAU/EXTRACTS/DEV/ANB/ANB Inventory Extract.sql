SELECT	DISTINCT InventoryID
	, ApplicationNaturalKeyUUID
	, OrderEntryID
	, AgreementID
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
	, FirmID
	, FirmName AS "Firm Name"
	, RegionName
	, AnticipatedPremium AS "Anticipated Premium"
	, Distributor
	, Channel
	, ChannelType AS "Channel Type"
	, BINGOStatus AS "Bingo Status"
	, CASE WHEN CompletedDate IS NOT NULL THEN
		CASE WHEN NewBusinessStatus <> 'Withdrawn' THEN 'Issued' ELSE NewBusinessStatus END 
		END AS NewBusinessStatus
	, ReceivedDate
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
    , T2.ReportDate   
FROM	PROD_DMA_VW.ANB_INVENTORY_RPT_VW T1

LEFT JOIN   (SELECT ShortDate, PreviousBusinessDay, IsHoliday, IsWeekday
							,CASE WHEN IsHoliday =0 AND Isweekday = 1 THEN Shortdate ELSE PreviousBusinessday END AS ReportDate
							,CASE WHEN shortDate = Current_Date THEN 1 Else 0 END AS "InventoryCurrDayInd"                      
						FROM PROD_DMA_VW.DATE_DIM_VW ) T2 ON "Date" = ShortDate

WHERE Date >= '2020-01-01'
--Tableau Extract: ANB Inventory Modern Data
--Application Level

SELECT T1.InventoryID 
    , T1.ApplicationNaturalKeyUUID
    , T1.OrderEntryID
    , T1.AgreementID
    , T1.ContractNumber
    , T1.ReportDate AS "Date"    
    , T2.InventoryCurrDayInd
    , T2.IsHoliday as "Date Is Holiday"
    , T2.IsWeekday as "Date is Weekeday"
    , T1.AgentID
    , T1.Advisor
    , T1.AgencyNumber
    , T1.Product
    , T1.ProductCategory AS "Product Category"
    , T1.FirmName
    , T1.AnticipatedPremium AS "Anticipated Premium"
    , T1.Distributor
    , T1.Channel
    , T1.ChannelType AS "Channel Type"
    , T1.BINGOStatus AS "Bingo Status"
    , T1.ReceivedDate
    , T1.LoadDate
    , T1.CompletedDate
    , T1.TAT
    , T1.DaysPending
    , T1.TransactionTypeID
    , T1.TransactionTypeName
    , T1.PlacementStatusID
    , T1.PlacementStatusDescription AS "PlacementStatusDesc"
    , T1.InventoryStatusID
    , T1.InventoryStatusDescription AS "InventoryStatusDesc"
    , T1.DecisionStatusID
    , T1.DecisionStatusDescription AS "DecisionStatusDesc"
    , CASE WHEN RANK() OVER (PARTITION BY ApplicationNaturalKeyUUID,"Date"  ORDER BY T1.TransactionTypeID DESC) = 1
                AND T1.TransactionTypeID = 2 THEN 1 ELSE 0 END AS "EOD Pending Indicator" 
	, CASE WHEN InventoryStatusID = 5 AND TransactionTypeID = 1 THEN 1 ELSE 0 END AS "Count Input"
	, CASE WHEN InventoryStatusID = 5 AND TransactionTypeID = 3 THEN 1 ELSE 0 END AS "Count Throughput"
	, T2.ReportDate   
FROM PROD_DMA_VW.ANB_INVENTORY_RPT_VW T1
LEFT JOIN   (SELECT ShortDate,PreviousBusinessDay,IsHoliday,IsWeekday
							, CASE WHEN IsHoliday =0  Isweekday = 1 THEN Shortdate ELSE PreviousBusinessday END AS ReportDate
							, CASE WHEN shortDate = Current_Date THEN 1 ELSE 0 END AS "InventoryCurrDayInd"                      
						FROM PROD_DMA_VW.DATE_DIM_VW ) T2  ON "Date" = ShortDate
WHERE Date >= '2020-01-01'
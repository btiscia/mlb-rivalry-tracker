-- Tableau Extract: ANB Modern Plan-Prod
-- Contract  Level

-- This routine pulls daily time 

-- Peer Review & Change Log:
-- Peer Review Date: 
-- Source for this routine is PROD_DMA_VW.Date_DIM_VW, PROD_DMA_VW.PRD_KPI_PLAN_DATA_VW,
--   PROD_DMA_VW.ANB_APPLICATION_RPT_VW
-- Author: Bill Trombley
-- Created: 6/28/2021
-- Revised:  


SELECT T1.Volumetric AS PlanMetric
, T1.ShortDate
, T1.IsHoliday AS "IsHoliday"
, T1.IsWeekday
, T1.ChannelType AS Channel
, T1.ProductType AS Product
, Measure
, DailyKPIPlan
, DailyMTDPlan
, DailyYTDPlan

	FROM 

		----------------------------------Begin T1------------------------------------
		(SELECT DISTINCT T2.SHORTDATE
		, T2.IsHoliday 
		, T2.IsWeekday
		, CASE GROUPING(TCAT.VOLUMETRIC) WHEN 1 THEN 'Total' ELSE TCAT.VOLUMETRIC END AS Volumetric
		, CASE GROUPING(TCAT.PRODUCTTYPE) WHEN 1 THEN 'Total' ELSE TCAT.PRODUCTTYPE END AS ProductType
		, CASE GROUPING(TCAT.CHANNELTYPE) WHEN 1 THEN 'Total' ELSE TCAT.CHANNELTYPE END AS ChannelType
		, SUM(DAILYKPIPLAN) AS DailyKPIPlan
		, SUM(DAILYMTDPLAN) AS DailyMTDPlan
		, SUM(DAILYYTDPLAN) AS DailyYTDPlan
		FROM PROD_DMA_VW.Date_DIM_VW T2 
		
		----------------------------------Begin TCAT------------------------------------
		JOIN (SELECT DISTINCT VOLUMETRIC
		, PRODUCTTYPE
		, CHANNELTYPE 
		FROM PROD_DMA_VW.PRD_KPI_PLAN_DATA_VW
		WHERE CHANNELTYPE <> 'Total' AND DEPARTMENTID = 47) TCAT ON 1=1
		----------------------------------End TCAT------------------------------------
		
		LEFT JOIN PROD_DMA_VW.PRD_KPI_PLAN_DATA_VW T1 ON T2.ShortDate = T1.ShortDate 
			AND  T1.CHANNELTYPE <> 'Total' 
			AND T1.DEPARTMENTID = 47
			AND T1.VOLUMETRIC = TCAT.VOLUMETRIC 
			AND T1.PRODUCTTYPE = TCAT.PRODUCTTYPE 
			AND T1.CHANNELTYPE = TCAT.CHANNELTYPE
		
		WHERE T2.SHORTDATE BETWEEN (ADD_MONTHS(TRUNC(CURRENT_DATE, 'YEAR'),-48))  AND (ADD_MONTHS(TRUNC(CURRENT_DATE, 'YEAR'),12)-1)
		
		----------------------------------Begin use to test change of year------------------------------------
		--WHERE T2.SHORTDATE BETWEEN  (CURRENT_DATE - INTERVAL '5' YEAR) AND ADD_MONTHS(TRUNC(CAST('2022-01-01' AS DATE), 'YEAR'),12)-1
		----------------------------------End  use to test change of year------------------------------------
		
		GROUP BY ROLLUP(TCAT.VOLUMETRIC,TCAT.CHANNELTYPE,TCAT.PRODUCTTYPE,IsHoliday ),1,2,3) T1
		----------------------------------End T1------------------------------------


		LEFT JOIN
		
		----------------------------------Begin T2------------------------------------
		(
			SELECT DISTINCT CASE GROUPING(T1.VOLUMETRIC) WHEN 1 THEN 'Total' ELSE T1.VOLUMETRIC END AS Volumetric
			, CASE GROUPING(CAST(T1.ShortDate AS VARCHAR(10))) WHEN 1 THEN 'Total' ELSE CAST(T1.ShortDate AS VARCHAR(10)) END AS ShortDate
			, CASE GROUPING(T1.PRODUCTTYPE) WHEN 1 THEN 'Total' ELSE T1.PRODUCTTYPE END AS ProductType
			, CASE GROUPING(T1.CHANNELTYPE) WHEN 1 THEN 'Total' ELSE T1.CHANNELTYPE END AS ChannelType
			, SUM(T1.MEASURE) AS Measure
			FROM 
		
				----------------------------------Begin T1------------------------------------
				(
					SELECT 'Submitted WTD Prem' AS Volumetric
					, NewBusinessSubmitDate AS ShortDate
					, ProductCategory AS ProductType
					, Channel AS ChannelType
					, SUM(AnticipatedPremium) AS Measure
					FROM PROD_DMA_VW.ANB_APPLICATION_RPT_VW
					GROUP BY 1,2,3,4
					
					UNION ALL
					
					SELECT 'Reported Premium' AS Volumetric
					, IssueDate AS ShortDate
					, ProductCategory AS ProductType
					, Channel AS ChannelType
					, SUM(DepositAmount) AS Measure
					FROM PROD_DMA_VW.ANB_APPLICATION_RPT_VW
					GROUP BY 1,2,3,4
					
					UNION ALL
					
					SELECT  'Submitted Counts' AS Volumetric
					, NewBusinessSubmitDate AS ShortDate
					, ProductCategory AS ProductType
					, Channel AS ChannelType
					, CAST (COUNT(NewBusinessSubmitDate) AS DECIMAL(8,2)) AS Measure
					FROM PROD_DMA_VW.ANB_APPLICATION_RPT_VW
					GROUP BY 1,2,3,4
					
					UNION ALL
					
					SELECT 'Issued Counts' AS Volumetric
					, IssueDate AS ShortDate
					, ProductCategory AS ProductType
					, Channel AS ChannelType
					,CAST (COUNT(IssueDate) AS DECIMAL(8,2)) AS Measure
					FROM PROD_DMA_VW.ANB_APPLICATION_RPT_VW
					GROUP BY 1,2,3,4
				) T1
			----------------------------------End T1------------------------------------
	
	
		WHERE T1.SHORTDATE >= CURRENT_DATE - INTERVAL '5' YEAR
		AND ProductType IS NOT NULL AND ChannelType IS NOT NULL
		
		GROUP BY ROLLUP(T1.VOLUMETRIC,CAST(T1.ShortDate AS VARCHAR(10)),T1.CHANNELTYPE,T1.PRODUCTTYPE)
		
		) T2
		----------------------------------End T2------------------------------------
	
	ON T1.VOLUMETRIC = T2.VOLUMETRIC AND T2.SHORTDATE = CAST(T1.SHORTDATE AS VARCHAR(10)) 
	AND T1.PRODUCTTYPE = T2.PRODUCTTYPE AND T1.CHANNELTYPE = T2.CHANNELTYPE
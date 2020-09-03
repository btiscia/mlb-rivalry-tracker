--Tableau Extract: ANB Modern Plan-Prod
--Contract  Level

SELECT T1.Volumetric as PlanMetric
, T1.ShortDate
,T1.IsHoliday as "Submit Date Is Holiday"
, T1.ChannelType as Channel
, T1.ProductType as Product
, Measure
, DailyKPIPlan
, DailyMTDPlan
, DailyYTDPlan
FROM 

(SELECT DISTINCT T1.SHORTDATE
,T2.IsHoliday 
, CASE GROUPING(VOLUMETRIC) WHEN 1 THEN 'Total' ELSE VOLUMETRIC END AS Volumetric
, CASE GROUPING(PRODUCTTYPE) WHEN 1 THEN 'Total' ELSE PRODUCTTYPE END AS ProductType
, CASE GROUPING(CHANNELTYPE) WHEN 1 THEN 'Total' ELSE CHANNELTYPE END AS ChannelType
, SUM(DAILYKPIPLAN) AS DailyKPIPlan
, SUM(DAILYMTDPLAN) AS DailyMTDPlan
, SUM(DAILYYTDPLAN) AS DailyYTDPlan
FROM PROD_DMA_VW.PRD_KPI_PLAN_DATA_VW T1       
Inner Join PROD_DMA_VW.Date_DIM_VW as T2 ON T1.ShortDate = T2.ShortDate    
WHERE CHANNELTYPE <> 'Total'
AND DEPARTMENTID = 47
--AND IsHoliday = 0
GROUP BY ROLLUP(VOLUMETRIC,CHANNELTYPE,PRODUCTTYPE,IsHoliday ),1,2) T1

Left Join
(
	SELECT DISTINCT CASE GROUPING(T1.VOLUMETRIC) WHEN 1 THEN 'Total' ELSE T1.VOLUMETRIC END AS Volumetric
	, CASE GROUPING(CAST(T1.ShortDate AS VARCHAR(10))) WHEN 1 THEN 'Total' ELSE CAST(T1.ShortDate AS VARCHAR(10)) END AS ShortDate
	, CASE GROUPING(T1.PRODUCTTYPE) WHEN 1 THEN 'Total' ELSE T1.PRODUCTTYPE END AS ProductType
	, CASE GROUPING(T1.CHANNELTYPE) WHEN 1 THEN 'Total' ELSE T1.CHANNELTYPE END AS ChannelType
	, SUM(T1.MEASURE) AS Measure
	FROM 
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
		---LEFT JOIN PROD_DMA_VW.DATE_DIM_VW as 
		GROUP BY 1,2,3,4
		
		UNION ALL
		
		SELECT 'Issued Counts' AS Volumetric
		, IssueDate AS ShortDate
		, ProductCategory AS ProductType
		, Channel AS ChannelType
		,Cast (COUNT(IssueDate) as DECIMAL(8,2)) AS Measure
		FROM PROD_DMA_VW.ANB_APPLICATION_RPT_VW
		GROUP BY 1,2,3,4
) T1

WHERE T1.SHORTDATE >= Current_Date - INTERVAL '5' YEAR
AND ProductType IS NOT NULL AND ChannelType IS NOT NULL

GROUP BY ROLLUP(T1.VOLUMETRIC,CAST(T1.ShortDate AS VARCHAR(10)),T1.CHANNELTYPE,T1.PRODUCTTYPE)

) T2
ON T1.VOLUMETRIC = T2.VOLUMETRIC AND T2.SHORTDATE = CAST(T1.SHORTDATE AS VARCHAR(10)) 
AND T1.PRODUCTTYPE = T2.PRODUCTTYPE AND T1.CHANNELTYPE = T2.CHANNELTYPE
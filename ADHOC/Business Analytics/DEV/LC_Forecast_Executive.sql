
SELECT  
D.ForecastID,
D.ForecastDate,
A.BusinessDays,
D.WorkRole,
--D.WorkFunction,
--D.ComplexityLevel,
D.ForecastVolume,
D.ForecastVolume_high95,
D.ForecastVolume_high80,
D.ForecastVolume_low80,
D.ForecastVolume_low95,
D.ForecastDemand,
D.ForecastDemand_high95,
D.ForecastDemand_high80,
D.ForecastDemand_low80,
D.ForecastDemand_low95,
C.ForecastCapacity,
C.ForecastCapacity_high95,
C.ForecastCapacity_high80,
C.ForecastCapacity_low80,
C.ForecastCapacity_low95,
C.ForecastEffectiveFTE,
C.ForecastEffectiveFTE_high95,
C.ForecastEffectiveFTE_high80,
C.ForecastEffectiveFTE_low80,
C.ForecastEffectiveFTE_low95,
C.ForecastShrinkage,
C.ForecastShrinkage_high95,
C.ForecastShrinkage_high80,
C.ForecastShrinkage_low80,
C.ForecastShrinkage_low95
FROM  DMA_GRP_DL.RT20_00002983_LC_Capacity C
JOIN 
(SELECT  
ForecastID,
ForecastDate,
WorkRole,
--WorkFunction,
--ComplexityLevel,
SUM(ForecastVolume) AS ForecastVolume,
SUM(ForecastVolume_high95) AS ForecastVolume_high95,
SUM(ForecastVolume_high80)AS ForecastVolume_high80,
SUM(ForecastVolume_low80)AS ForecastVolume_low80 ,
SUM(ForecastVolume_low95)AS ForecastVolume_low95,
SUM(ForecastDemand)AS ForecastDemand,
SUM(ForecastDemand_high95)AS ForecastDemand_high95,
SUM(ForecastDemand_high80)AS ForecastDemand_high80,
SUM(ForecastDemand_low80)AS ForecastDemand_low80,
SUM(ForecastDemand_low95)AS ForecastDemand_low95
FROM DMA_GRP_DL.RT20_00002983_LC_Forecast_New
Group by 1,2,3) D
ON
C.ForecastDate = D.ForecastDate AND
C.WorkRole = D.WorkRole AND
C.ForecastID = D.ForecastID

LEFT JOIN (
	SELECT
		FirstDayofMonth,
		COUNT(CASE WHEN IsHoliday = 0 AND  IsWeekday = 1 THEN ShortDate END) AS BusinessDays
			FROM  PROD_DMA_VW.DATE_DIM_VW
			GROUP BY 1) A
ON A.FirstDayofMonth = D.ForecastDate
INNER JOIN
(SELECT MAX(ForecastID) as FxID 
FROM DMA_GRP_DL.RT20_00002983_LC_Forecast_New) D2
ON D.ForecastID = FxID




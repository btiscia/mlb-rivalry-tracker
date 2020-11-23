SELECT DISTINCT D.WorkRole, D.ForecastDate,
SUM(ForecastVolume) AS ForecastVolume,
SUM(ForecastVolume_high95) AS ForecastVolume_high95,
SUM(ForecastVolume_high80) AS ForecastVolume_high80,
SUM(ForecastVolume_low80) AS ForecastVolume_low80,
SUM(ForecastVolume_low95) AS ForecastVolume_low95,
SUM(ForecastDemand) AS ForecastDemand,
SUM(ForecastDemand_high95) AS ForecastDemand_high95,
SUM(ForecastDemand_high80) AS ForecastDemand_high80,
SUM(ForecastDemand_low80) AS ForecastDemand_low80,
SUM(ForecastDemand_low95) AS ForecastDemand_lwo95,
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
FROM DMA_GRP_DL.RT20_00002983_LC_Forecast_New D
INNER JOIN DMA_GRP_DL.RT20_00002983_LC_Capacity C ON C.ForecastDate = D.ForecastDate AND C.WorkRole = D.WorkRole
-- We can change the where clause when our demand and capacity forecasts line up
WHERE D.ForecastID = 202009 AND C.ForecastID = 202011
GROUP BY 1,2,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27
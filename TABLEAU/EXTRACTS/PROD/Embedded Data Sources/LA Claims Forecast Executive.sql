/*
FILENAME: LA Claims Forecast Executive
CREATED BY: Jay Johnson
LAST UPDATED: 3/28/2022
CHANGES MADE: Modifications to the source tables.
**Notes:  This is in the Executive forecast dashboard.  
*This runs as of 3-29-79
*/

SELECT  
D.ForecastID,
D.ForecastDate,
A.BusinessDays,
Trim(D.WorkRole) as WorkRole,
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
FROM  dma_analytics.analytics_capacity_fx AS C
JOIN 
(SELECT  
ForecastID,
ForecastDate,
WorkRole,
--WorkFunction,
--ComplexityLevel,
Sum(ForecastVolume) AS ForecastVolume,
Sum(ForecastVolume_high95) AS ForecastVolume_high95,
Sum(ForecastVolume_high80)AS ForecastVolume_high80,
Sum(ForecastVolume_low80)AS ForecastVolume_low80 ,
Sum(ForecastVolume_low95)AS ForecastVolume_low95,
Sum(ForecastDemand)AS ForecastDemand,
Sum(ForecastDemand_high95)AS ForecastDemand_high95,
Sum(ForecastDemand_high80)AS ForecastDemand_high80,
Sum(ForecastDemand_low80)AS ForecastDemand_low80,
Sum(ForecastDemand_low95)AS ForecastDemand_low95
FROM dma_analytics.analytics_demand_fx--RT20_00002983_LC_Forecast_New
GROUP BY 1,2,3) D
ON
C.ForecastDate = D.ForecastDate AND
C.WorkRole = D.WorkRole AND
C.ForecastID = D.ForecastID
LEFT JOIN (
    SELECT
        first_day_of_month,
        Count(CASE WHEN is_holiday = false AND  is_weekday = True THEN short_dt END) AS BusinessDays
            FROM  dma_vw.dma_dim_date_vw
            GROUP BY 1) A
ON A.first_day_of_month = D.ForecastDate
INNER JOIN
(SELECT DISTINCT Department, ForecastDate ,Max(ForecastID) Over (PARTITION BY Department,ForecastDate) AS FxID 
FROM dma_analytics.analytics_capacity_fx
WHERE   Extract(YEAR From ForecastDate) = Extract (YEAR From Current_Date- INTERVAL '0' YEAR)
AND Department = 'Life Claims') AS T2
ON (C.ForecastID = FxID AND C.ForecastDate = T2.ForecastDate AND C.Department=T2.Department)
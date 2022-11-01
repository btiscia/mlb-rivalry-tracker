/*
FILENAME: ANB Plan Details
UPDATED BY: Bill Trombley, Zach Dorval
LAST UPDATED: 08/25/2022
CHANGES MADE: Vertica Migration
*/

WITH volumetrics AS (
    SELECT volumetric
         , department_id
         , short_dt
         , product_category                              AS product_type
         , channel                                       AS channel_type
         , REPLACE(lower(product_nm), 'massmutual ', '') AS product
         , measure
    FROM dma_vw.fact_aggregated_volumetrics_vw
)

SELECT T2.volumetric AS PlanMetric
    , T1.short_dt AS ShortDate
    , CAST(T1.is_holiday AS INT) AS "IsHoliday"
    , CAST(T1.is_weekday AS INT) AS "IsWeekDay"
    , T2.channel_type AS Channel
    , T2.product_type AS ProductType
    , T2.product AS Product
    , T3.measure AS Measure
    , T2.daily_kpi_plan AS DailyKPIPlan
	, T2.daily_mtd_plan AS DailyMTDPlan
	, T2.daily_ytd_plan AS DailyYTDPlan
FROM dma_vw.dma_dim_date_vw T1
LEFT JOIN dma_vw.dma_kpi_plans_vw T2 ON T1.short_dt = T2.date_of_year
LEFT JOIN volumetrics T3 ON T1.short_dt = T3.short_dt
            AND lower(T2.product_type) = lower(T3.product_type)
            AND lower(T2.channel_type) = lower(T3.channel_type)
            AND lower(T2.product) = lower(T3.product)
            AND lower(T2.volumetric) = lower(T3.volumetric)
WHERE T1.short_dt >= CURRENT_DATE - INTERVAL '5' YEAR
    AND T2.sales_group <> 'Total'
    AND T2.product <> ''
ORDER BY T1.short_dt desc
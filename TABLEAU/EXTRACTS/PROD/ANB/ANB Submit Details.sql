/*
FILENAME: ANB Submit Details
UPDATED BY: John Avgoustakis, Vince Bonaddio 
LAST UPDATED: 06/27/2022
CHANGES MADE: Vertica Migration
*/

SELECT T1.submit_dt AS "SubmitDate"
    , CAST(T3.is_holiday AS INTEGER) AS "IsHoliday"
    , CAST(T3.is_weekday AS INTEGER) AS "IsWeekDay"
    , total AS "TOTAL"
    , MMFA
    , total - MMFA AS "MMSD"
FROM (
    SELECT COUNT(T1.agreement_nr) AS total
        , T2.app_count AS MMFA
        , CAST(nb_submit_dt AS DATE) AS submit_dt
    FROM dma_vw.sem_dim_anb_application_curr_vw T1
    INNER JOIN (SELECT COUNT(REPLACE(T1.order_entry_id,'-','')) AS app_count
                    , CAST(T1.electronic_submit_dt AS DATE) AS submit_dt
                FROM dma_vw.dim_ipipeline_orders_curr_vw T1
                WHERE product_nm LIKE 'MassMutual%'
                GROUP BY 2) T2 ON CAST(T1.nb_submit_dt AS DATE) = T2.submit_dt
    GROUP BY 2,3) T1

LEFT JOIN dma_vw.dma_dim_date_vw T3 ON T3.short_dt = T1.submit_dt
ORDER BY T3.short_dt DESC
SELECT
    CAL_DT AS 'Date'
    ,SRC_CDE AS 'Source'
    ,SRC_CDE_DESC AS 'Source Description'
    ,SUM(BOOKED_NBR) AS 'Booked Attendees'
    ,SUM(ACTUAL_NBR) AS 'Actual Attendees'
FROM
    DMA.dbo.MMLCC_BOOKED_VS_ACTUAL_VW
GROUP BY
    CAL_DT
    ,SRC_CDE
    ,SRC_CDE_DESC
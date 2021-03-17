SELECT
	ROOM_UTILIZATION_DT AS 'Room Utilization Date'
	,ROOM_TYP_DESC AS 'Room Type Description'
	,ROOM_DESC AS 'Room Description'
	,ROOM_BOOKING_NBR AS 'Room Booking Count'
	,UTILIZATION_CTG_DESC AS 'Category Description'
	,SUM(USED_HRS) AS 'Hours Used'
	,SUM(AVAILABLE_HRS) AS 'Hours Available'
	,SUM(UTILIZATION_PCT) AS 'Utilization Percentage'
        ,month_num
        ,year_num
FROM 
	DMA.dbo.MMLCC_20_CONFERENCE_ROOM_VW
GROUP BY
	ROOM_UTILIZATION_DT
	,ROOM_TYP_DESC
	,ROOM_DESC
	,ROOM_BOOKING_NBR
	,UTILIZATION_CTG_DESC
        ,month_num
        ,year_num
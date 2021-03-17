SELECT
	ROOM_RESV_DT AS 'Room Reservation Date'
	,RESV_CTG_NM AS 'Reservation Category'
	,RATE_TYP_NM AS 'Rate Type'
	,SUM(TOT_RESV_BOOKING_NBR) AS 'Total Reservations'
	,SUM(TOT_COST_AMT) AS 'Total Cost'
	,SUM(RESV_RATE_TYP_COST_AMT) AS 'Rate Type Cost'
        ,month_num
        ,year_num
FROM 
	DMA.dbo.MMLCC_40_GUESTROOM_VW
GROUP BY
	ROOM_RESV_DT
	,RESV_CTG_NM
	,RATE_TYP_NM
        ,month_num
        ,year_num
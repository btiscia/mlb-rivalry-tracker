/*
FILENAME: ANNUITY NEW BUSINESS SUBMIT DETAILS
UPDATED BY: Jess Madru
LAST UPDATED: 9/12/2023
CHANGES MADE: Vertica Migration, OSDT3-4818 - Update Daily Submit Logic, MMSD Envision changes
*/

SELECT T2.submit_dt AS "SubmitDate"
	, CAST(T3.is_holiday AS INTEGER) AS "IsHoliday"
    , CAST(T3.is_weekday AS INTEGER) AS "IsWeekDay"
    , total_HO --top of dashboard
    , total_Zinnia -- top of dashboard
    , MMFA --section 1
    , total_Zinnia - MMFASub + MMFASubEnv AS "MMSD" --section 2
    , MMFASub --used for testing
    , MMFASubEnv --used for testing
    
FROM (	SELECT
		SUM(totalHO) AS total_HO --sum of all HO Envision received 
		, SUM(totalZinnia) AS total_Zinnia --sum of all Zinnia received
		, COALESCE(T3.app_count, 0) as MMFA --all MMFA electronic submissions
		, COALESCE(T4.app_count2, 0) AS MMFASub --includes all transmitted orders (includes Zinnia MMFA)
        , COALESCE(T5.app_count2a, 0) AS MMFASubEnv --includes all transmitted ipipeline orders (HO MMFA only)
        , T1.submit_dt
        FROM (SELECT CASE WHEN home_office_ind = 1 THEN COUNT(T1.agreement_nr) ELSE 0 END AS totalHO --use this to count HO received
    	    , CASE WHEN home_office_ind = 0 THEN COUNT(T1.agreement_nr) ELSE 0 END AS totalZinnia --use this to count Zinnia received
    		, home_office_ind
       	 	, CAST(T1.nb_submit_dt AS DATE) AS submit_dt
    		FROM dma_vw.sem_dim_anb_application_curr_vw T1
    		GROUP BY 3,4) T1
    
   		LEFT JOIN (SELECT COUNT(T1.order_entry_id) AS app_count
     		, CAST(T1.electronic_submit_dt AS DATE) AS submit_dt
     		FROM dma_vw.sem_anb_ipipeline_vw T1
            GROUP BY 2) T3 ON T1.submit_dt = T3.submit_dt
        
   		LEFT JOIN (SELECT COUNT(T1.order_entry_id) AS app_count2 
            , CAST(T1.suit_comp_dt_transmit AS DATE) AS suit_comp_dt_trans
            FROM dma_vw.sem_anb_ipipeline_vw T1
            WHERE home_office_ind = 0
            GROUP BY 2) T4 ON T1.submit_dt = T4.suit_comp_dt_trans
       
   		LEFT JOIN (SELECT COUNT(T1.order_entry_id) AS app_count2a 
            , CAST(T1.suit_comp_dt_transmit AS DATE) AS suit_comp_dt_trans
            FROM dma_vw.sem_anb_ipipeline_vw T1
            WHERE home_office_ind = 1
            GROUP BY 2) T5 ON T1.submit_dt = T5.suit_comp_dt_trans            
  	 	
	GROUP BY 3,4,5,6) T2

LEFT JOIN dma_vw.dma_dim_date_vw T3 ON T3.short_dt = T2.submit_dt
WHERE T2.submit_dt > '2019-07-01'
ORDER BY T2.submit_dt DESC
/*
This routine pulls TimeOut data for past 3 years 
Views used in this query: 
   dma_vw.dma_dim_schedule_curr_vw 
   dma_vw.dma_dim_employee_curr_vw  
   dma_vw.dma_dim_date_vw                                                                
   dma_vw.sem_fact_timeout_activity_current_vw   
   dma_vw.dma_dim_goal_pit_vw
  Created: 6/15/2022 initial Vertica load -Kristin Carlile
*/


SELECT DISTINCT 
		T1.row_process_dtm as "TransDt"
		, T3.short_dt as "Date" 
	    , T3.day_nm as "Day Name"
	    ,T2.fte  
	    ,CASE WHEN T2.fte < 1 THEN 'Non-Production'
		ELSE 'Production'
		END AS "Employee Type" 
	    ,T3.is_holiday 
	    ,T3.is_weekday 
	    ,COALESCE(T2.employee_last_nm || ', ' || T2.employee_first_nm, 'Unknown') AS Employee 
	    ,T2.team_nm "Team Name" 
	    ,T2.role_nm "Employee Role Name" 
	    ,T2.role_id  AS "RoleID"
	    ,T2.department_id  AS "DepartmentID"
	    ,T2.department_nm AS "Department Name" 
	    ,COALESCE(T2.manager_last_nm || ', ' || T2.manager_first_nm, 'Unknown') AS Manager 
	    ,working_hours AS "Working Hours"
	    ,time_type AS "Time Type"
	    ,parent_time_category AS "Category"
	    ,time_category AS "Time Category"
	    ,planned_actual AS "Planned Actual"
		,T5.description AS "Meeting Description"
	    ,(SELECT goal_val FROM dma_vw.dma_dim_goal_pit_vw  WHERE end_dt = '9999-12-31' AND department_id = T2.department_id  AND goal_type_id = 4 AND role_nm = t2.role_nm)  AS "Non Prod Goal"--return non prod goal 
	    ,CASE WHEN planned_actual = 'PLANNED-ACTUAL' THEN 'Planned'
		  WHEN planned_actual = 'ACTUAL' THEN 'Unplanned'
		  END AS "Planned or Actual"
	    ,COALESCE(SUM(actual_flex_hrs),0) "Actual Flex Hours"
	    ,COALESCE(SUM(actual_non_prod_hrs),0) "Non-Prod Hours"
	    ,COALESCE(SUM(actual_ooo_hrs),0) "Actual OOO Hours"
	    ,COALESCE(SUM(actual_ot_hrs),0) "Actual OT Hours"
	    ,COALESCE(SUM(actual_prod_hrs),0) "Prod Hours"
	    ,COALESCE(SUM(actual_excused_hrs),0) "Actual Excused Hours"
	    ,COALESCE(SUM(actual_makeup_hrs),0) "Actual Makeup Hours" 
	    ,COALESCE(SUM(all_day_ooo),0) "All Day OOO"
	    ,CASE WHEN "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0
		    WHEN ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours") = 0 THEN 0 
		    WHEN (is_holiday = 1 OR "Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") = 0 THEN  0
		    ELSE "Prod Hours"
		    END AS "Actual Production Hours"
	     ,CASE WHEN "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0
		    WHEN ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours") = 0 THEN 0 
		    WHEN (is_holiday = 1 OR "Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") = 0 THEN  0
		    ELSE "Non-Prod Hours"
		    END AS "Actual Non-Production Hours" 
	    ,CASE WHEN "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN "Working Hours" 
		    ELSE "Actual OOO Hours"
		    END AS "Actual OOO Hrs"
	FROM dma_vw.dma_dim_schedule_pit_vw T1 -- Base dataset is the Employee's schedule ***DOUBLE CHECK IF CURR OR PIT VIEW***
	INNER JOIN dma_vw.dma_dim_employee_curr_vw  T2 ON T1.mmid = T2.mmid AND T2.end_dt > CURRENT_DATE -- current Employee info
    INNER JOIN dma_vw.dma_dim_date_vw T3 ON T1.day_of_week = T3.day_of_week --return date info                                                                       
    LEFT JOIN dma_vw.sem_fact_timeout_activity_current_vw  T5 ON t3.short_dt = T5.meeting_dt AND T2.party_employee_id = T5.party_employee_id -- Non-Prod TimeOut Data
	WHERE T1.end_dt = '9999-12-31' -- Latest Schedule record for each HR_ID
	AND t3.short_dt BETWEEN ADD_MONTHS(CURRENT_DATE, -36) AND CURRENT_DATE - INTERVAL '1' DAY  ---MAKE SURE SQL BEING USED HAS 3 YRS
	---AND ShortDate BETWEEN '2017-05-01' AND CURRENT_DATE - INTERVAL '1' DAY --5/1/2017 is the start of TimeOut
	AND parent_time_category IS NOT NULL
	AND t2.to_rep_ind = 1 --filter timeout applicable users only
	--AND TimeType Like  '%Capture%'
	GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22
SELECT DISTINCT 
		TransDt
		,ShortDate "Date" 
	    ,T3.DayName
	    ,T2.FTE  
	    ,CASE WHEN T2.FTE < 1 THEN 'Non-Production'
		ELSE 'Production'
		END AS "Employee Type" 
	    ,T3.IsHoliday 
	    ,T3.IsWeekday 
	    ,COALESCE(T2.EmployeeLastName || ', ' || T2.EmployeeFirstName, 'Unknown') AS Employee 
	    ,T2.TeamName "Team Name" 
	    ,T2.RoleName "Employee Role Name" 
	    ,T2.RoleID  AS "RoleID"
	    ,T2.DepartmentID  AS "DepartmentID"
	    ,T2.DepartmentName AS "Department Name" 
	    ,COALESCE(T2.ManagerLastName || ', ' || T2.ManagerFirstName, 'Unknown') AS Manager 
	    ,WorkingHours AS "Working Hours"
	    ,TimeType
	    ,ParentTimeCategory 
	    ,TimeCategory 
	    ,PlannedActual
		,T5.MeetingDescription
	    ,(SELECT GoalValue FROM PROD_DMA_VW.GOAL_DIM_VW WHERE EndDate = '9999-12-31' AND DepartmentID = T2.DepartmentID  AND GoalTypeID = 4 AND RoleName = "Employee Role Name")  AS "Non Prod Goal"--return non prod goal 
	    ,CASE WHEN PlannedActual = 'PLANNED-ACTUAL' THEN 'Planned'
		  WHEN PlannedActual = 'ACTUAL' THEN 'Unplanned'
		  END AS "Planned or Actual"
	    ,COALESCE(SUM(ActualFlexHours),0) "Actual Flex Hours"
	    ,COALESCE(SUM(ActualNonProdHours),0) "Non-Prod Hours"
	    ,COALESCE(SUM(ActualOOOHours),0) "Actual OOO Hours"
	    ,COALESCE(SUM(ActualOTHours),0) "Actual OT Hours"
	    ,COALESCE(SUM(ActualProdHours),0) "Prod Hours"
	    ,COALESCE(SUM(ActualExcusedHours),0) "Actual Excused Hours"
	    ,COALESCE(SUM(ActualMakeupHours),0) "Actual Makeup Hours" 
	    ,COALESCE(SUM(AllDayOOO),0) "All Day OOO"
	    ,CASE WHEN "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0
		    WHEN ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours") = 0 THEN 0 
		    WHEN (IsHoliday = 1 OR "Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") = 0 THEN  0
		    ELSE "Prod Hours"
		    END AS "Actual Production Hours"
	     ,CASE WHEN "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0
		    WHEN ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours") = 0 THEN 0 
		    WHEN (IsHoliday = 1 OR "Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") = 0 THEN  0
		    ELSE "Non-Prod Hours"
		    END AS "Actual Non-Production Hours" 
	    ,CASE WHEN "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN "Working Hours" 
		    ELSE "Actual OOO Hours"
		    END AS "Actual OOO Hrs"
	FROM PROD_DMA_VW.SCHEDULE_DIM_VW T1 -- Base dataset is the Employee's schedule
	INNER JOIN PROD_DMA_VW.EMPLOYEE_CURR_DIM_VW T2 ON T1.MMID = T2.MMID AND EndDate > CURRENT_DATE -- current Employee info
    INNER JOIN PROD_DMA_VW.DATE_DIM_VW T3 ON T1.DayOfWeek = T3.DayOfWeek --return date info                                                                       
    LEFT JOIN PROD_DMA_VW.TIMEOUT_ACTIVITY_CURR_IVW  T5 ON ShortDate = T5.MeetingDate AND T2.PartyEmployeeID = T5.PartyEmployeeID -- Non-Prod TimeOut Data
	WHERE T1.EndDt = '9999-12-31' -- Latest Schedule record for each HR_ID
	AND ShortDate BETWEEN ADD_MONTHS(CURRENT_DATE, -36) AND CURRENT_DATE - INTERVAL '1' DAY  ---MAKE SURE SQL BEING USED HAS 3 YRS
	---AND ShortDate BETWEEN '2017-05-01' AND CURRENT_DATE - INTERVAL '1' DAY --5/1/2017 is the start of TimeOut
	AND parentTimeCategory IS NOT NULL
	AND TimeOutReportInd = 1 --filter timeout applicable users only
	--AND TimeType Like  '%Capture%'
	
	GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21

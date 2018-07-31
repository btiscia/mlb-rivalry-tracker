SELECT "Date"  --DAate
,"DayName"
,CASE 
    WHEN FTE < 1 THEN 'Non-Production'
    ELSE 'Production'
END AS "Employee Type" 
,IsHoliday 
,IsWeekday  
,Employee 
,"Team Name" 
,"Employee Role Name"
,"RoleID"
,"DepartmentID"
,"Department Name"
,Manager 
,"Working Hours"
,TimeType
,ParentTimeCategory
,TimeCategory 
,PlannedActual
,CASE WHEN PlannedActual = 'PLANNED-ACTUAL' THEN 'Planned'
  WHEN PlannedActual = 'ACTUAL' THEN 'Unplanned'
  END AS "Planned or Actual"
,"Actual Flex Hours"
,CASE WHEN "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0
    WHEN ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours") = 0 THEN 0 
    WHEN (IsHoliday = 1 OR "Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") = 0 THEN  0
    ELSE "Actual Non-Prod Hours"
    END AS "Actual Non-Production Hours" 
,CASE WHEN "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN "Working Hours" 
    ELSE "Actual OOO Hours"
    END AS "Actual OOO Hours"
,"Actual OT Hours"
,CASE WHEN "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0
    WHEN ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours") = 0 THEN 0 
    WHEN (IsHoliday = 1 OR "Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") = 0 THEN  0
    ELSE "Actual Prod Hours"
    END AS "Actual Production Hours"
,"Actual Excused Hours" 
,"Actual Makeup Hours" 
 ,"All Day OOO"
FROM 
	(SELECT DISTINCT ShortDate "Date" 
	    ,T3.DayName
	    ,T2.FTE  
	    ,T3.IsHoliday 
	    ,T3.IsWeekday 
	    ,Coalesce(T2.EmployeeLastName || ', ' || T2.EmployeeFirstName, 'Unknown') AS Employee 
	    ,T2.TeamName "Team Name" 
	    ,T2.RoleName "Employee Role Name" 
	    ,T2.RoleID  AS "RoleID"
	    ,T2.DepartmentID  AS "DepartmentID"
	    ,T2.DepartmentName AS "Department Name" 
	    ,Coalesce(T2.ManagerLastName || ', ' || T2.ManagerFirstName, 'Unknown') AS Manager 
	    ,WorkingHours AS "Working Hours"
	    ,TimeType
	    ,ParentTimeCategory 
	    ,TimeCategory 
	    ,PlannedActual       
	    ,Coalesce(Sum(ActualFlexHours),0) "Actual Flex Hours"
	    ,Coalesce(Sum(ActualNonProdHours),0) "Actual Non-Prod Hours"
	    ,Coalesce(Sum(ActualOOOHours),0) "Actual OOO Hours"
	    ,Coalesce(Sum(ActualOTHours),0) "Actual OT Hours"
	    ,Coalesce(Sum(ActualProdHours),0) "Actual Prod Hours"
	    ,Coalesce(Sum(ActualExcusedHours),0) "Actual Excused Hours"
	    ,Coalesce(Sum(ActualMakeupHours),0) "Actual Makeup Hours" 
	    ,Coalesce(Sum(AllDayOOO),0) "All Day OOO"
	FROM PROD_DMA_VW.SCHEDULE_DIM_VW T1 -- Base dataset is the Employee's schedule
	INNER JOIN PROD_DMA_VW.EMPLOYEE_CURR_DIM_VW T2 ON T1.MMID = T2.MMID AND EndDate > Current_Date -- current Employee info
    INNER JOIN PROD_DMA_VW.DATE_DIM_VW T3 ON T1.DayOfWeek = T3.DayOfWeek --return date info                                                                       
    LEFT JOIN PROD_DMA_VW.TIMEOUT_ACTIVITY_CURR_IVW  T5 ON ShortDate = T5.MeetingDate AND T2.PartyEmployeeID = T5.PartyEmployeeID -- Non-Prod TimeOut Data
	WHERE T1.EndDt = '9999-12-31' -- Latest Schedule record for each HR_ID
	AND ShortDate BETWEEN Add_Months(Current_Date, -13) AND Current_Date - INTERVAL '1' DAY
	AND parentTimeCategory IS NOT NULL
	GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17) T1 

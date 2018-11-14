CREATE VOLATILE TABLE variables AS (SELECT '5' AS deptID) WITH DATA NO PRIMARY INDEX
ON COMMIT PRESERVE ROWS;

SELECT
"Date"
,IsHoliday
,IsWeekday
,Employee
,CASE 
    WHEN FTE < 1 THEN 'Non-Production'
    ELSE 'Production'
END AS "Employee Type"
,Manager
,"Team Name"
,"Role Name"
,"Prod Goal"
,"NonProd Goal"
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
,"Planned Flex Hours"
,CASE WHEN "All Day OOO" >= 1 OR ("Planned OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0
    WHEN ("Working Hours" + "Planned OT Hours" + "Planned Makeup Hours") = 0 THEN 0 
    WHEN (IsHoliday = 1 OR "Working Hours" = 0) AND ("Planned OT Hours" + "Planned Makeup Hours") = 0 THEN  0
    ELSE "Planned Non-Production Hours"
    END AS "Planned Non-Production Hours"
,CASE WHEN "All Day OOO" >= 1 OR ("Planned OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN "Working Hours" 
    ELSE "Planned OOO Hours"
    END AS "Planned OOO Hours"
,"Planned OT Hours"
,CASE WHEN "All Day OOO" >= 1 OR ("Planned OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0
    WHEN ("Working Hours" + "Planned OT Hours" + "Planned Makeup Hours") = 0 THEN 0 
    WHEN (IsHoliday = 1 OR "Working Hours" = 0) AND ("Planned OT Hours" + "Planned Makeup Hours") = 0 THEN  0
    ELSE "Planned Prod Hours"
    END AS "Planned Prod Hours"
,"Planned Excused Hours"
,"Planned Makeup Hours"
,"Working Hours"
,"Admin Time"
,Coalesce("Productivity Credits",0) AS "Productivity Credits"
,"All Day OOO"
,CASE WHEN "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0
    WHEN ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours") = 0 THEN 0 
    WHEN (IsHoliday = 1 OR "Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") = 0 THEN  0
    ELSE Coalesce(Cast("Productivity Credits" AS DECIMAL(12,5)),0) / 60 
    END AS "Productivity Hours"
,"Productivity Hours" + "Actual Production Hours" AS "Hours Productive"
,CASE WHEN "All Day OOO" >= 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0 
    WHEN ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours") = 0 THEN 0 
    WHEN (IsHoliday = 1) AND ("Actual OT Hours" + "Actual Makeup Hours") = 0 THEN  0
    WHEN (IsHoliday = 1) AND ("Actual OT Hours" + "Actual Makeup Hours") < 6 THEN  ("Actual OT Hours" + "Actual Makeup Hours" - "Actual Excused Hours" - "Actual Non-Production Hours" - "Actual OOO Hours")
    WHEN (IsHoliday = 1) AND ("Actual OT Hours" + "Actual Makeup Hours") > 6 THEN  ("Actual OT Hours" + "Actual Makeup Hours" - "Actual Excused Hours" - "Actual Non-Production Hours" - "Actual OOO Hours" - "Admin Time")
    WHEN ("Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") < 6 THEN  ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours" - "Actual Excused Hours" - "Actual Non-Production Hours" - "Actual OOO Hours")
    WHEN ("Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") >= 6 THEN  ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours" - "Actual Excused Hours" - "Actual Non-Production Hours" - "Actual OOO Hours" - "Admin Time")
    ELSE ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours" - "Actual Excused Hours" - "Actual Non-Production Hours" - "Actual OOO Hours" - "Admin Time") 
    END AS "Available Time"
,CASE WHEN "All Day OOO" >= 1 OR ("Planned OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0 
    WHEN ("Working Hours" + "Planned OT Hours" + "Planned Makeup Hours") = 0 THEN 0 
    WHEN (IsHoliday = 1) AND ("Planned OT Hours" + "Planned Makeup Hours") = 0 THEN  0
    WHEN (IsHoliday = 1) AND ("Planned OT Hours" + "Planned Makeup Hours") < 6 THEN  ("Planned OT Hours" + "Planned Makeup Hours" - "Planned Excused Hours" - "Planned Non-Production Hours" - "Planned OOO Hours")
    WHEN (IsHoliday = 1) AND ("Planned OT Hours" + "Planned Makeup Hours") > 6 THEN  ("Planned OT Hours" + "Planned Makeup Hours" - "Planned Excused Hours" - "Planned Non-Production Hours" - "Planned OOO Hours" - "Admin Time")
    WHEN ("Working Hours" = 0) AND ("Planned OT Hours" + "Planned Makeup Hours") < 6 THEN  ("Working Hours" + "Planned OT Hours" + "Planned Makeup Hours" - "Planned Excused Hours" - "Planned Non-Production Hours" - "Planned OOO Hours")
    WHEN ("Working Hours" = 0) AND ("Planned OT Hours" + "Planned Makeup Hours") >= 6 THEN  ("Working Hours" + "Planned OT Hours" + "Planned Makeup Hours" - "Planned Excused Hours" - "Planned Non-Production Hours" - "Planned OOO Hours" - "Admin Time")
    ELSE ("Working Hours" + "Planned OT Hours" + "Planned Makeup Hours" - "Planned Excused Hours" - "Planned Non-Production Hours" - "Planned OOO Hours" - "Admin Time") 
    END AS "Planned Available Time"
FROM (SELECT DISTINCT ShortDate "Date"
			    ,T1.FTE 
			    ,T3.IsHoliday
			    ,T3.IsWeekday
			    ,Coalesce(T1.EmployeeLastName || ', ' || T1.EmployeeFirstName, 'Unknown') AS Employee
			    ,T1.TeamName "Team Name"
			    ,T1.RoleName "Role Name"
			    ,T1.RoleID
			    ,T1.DepartmentID
			    ,Coalesce(T1.ManagerLastName || ', ' || T1.ManagerFirstName, 'Unknown') AS Manager
			    ,WorkingHours "Working Hours"
				,AdminTime "Admin Time"
			    ,SUM(ProdCredits) AS "Productivity Credits"
			    ,T6.GoalValue AS "Prod Goal"
			    ,T7.GoalValue AS "NonProd Goal"
			    ,Coalesce(Sum(ActualFlexHours),0) "Actual Flex Hours"
			    ,Coalesce(Sum(ActualNonProdHours),0) "Actual Non-Prod Hours"
			    ,Coalesce(Sum(ActualOOOHours),0) "Actual OOO Hours"
			    ,Coalesce(Sum(ActualOTHours),0) "Actual OT Hours"
			    ,Coalesce(Sum(ActualProdHours),0) "Actual Prod Hours"
			    ,Coalesce(Sum(PlannedFlexHours),0) "Planned Flex Hours"
			    ,Coalesce(Sum(PlannedNonProdHours),0) "Planned Non-Production Hours"
			    ,Coalesce(Sum(PlannedOOOHours),0) "Planned OOO Hours"
			    ,Coalesce(Sum(PlannedOTHours),0) "Planned OT Hours"
			    ,Coalesce(Sum(PlannedProdHours),0) "Planned Prod Hours"
			    ,Coalesce(Sum(PlannedExcusedHours),0) "Planned Excused Hours"
			    ,Coalesce(Sum(ActualExcusedHours),0) "Actual Excused Hours"
			    ,Coalesce(Sum(ActualMakeupHours),0) "Actual Makeup Hours"
			    ,Coalesce(Sum(PlannedMakeupHours),0) "Planned Makeup Hours"
			    ,Coalesce(Sum(AllDayOOO),0) "All Day OOO"
		    FROM (SELECT * FROM PROD_DMA_VW.EMPLOYEE_CURR_DIM_VW T1 INNER JOIN variables T2 ON T1.DepartmentID = T2.deptID) T1
		    INNER JOIN (SELECT * FROM PROD_DMA_VW.SCHEDULE_DIM_VW WHERE EndDt = '9999-12-31') T2 ON T1.MMID = T2.MMID  
--) After Release the Current Dimension will be used      
/*		    INNER JOIN PROD_DMA_VW.SCHEDULE_CURR_DIM_VW T2 ON T1.PartyEmployeeID = T2.PartyEmployeeID      */
		    INNER JOIN PROD_DMA_VW.DATE_DIM_VW T3 ON T2.DayOfWeek = T3.DayOfWeek AND ShortDate >= T1.StartDate
		    LEFT JOIN (SELECT PartyEmployeeID, CompletedDate, Sum(T1.ProductivityCredit) AS ProdCredits                     
							FROM PROD_DMA_VW.ACTIVITY_FCT_VW T1
							INNER JOIN PROD_DMA_VW.WORK_EVENT_CURR_DIM_VW T2 ON T1.WorkEventID = T2.WorkEventID
							INNER JOIN variables T3 ON T2.DepartmentID = T3.deptID -- Inner join to variables
							WHERE CompletedIndicator = 1
								AND CompletedDate BETWEEN Add_Months(Current_Date, -3) 
								AND Current_Date + INTERVAL '10' DAY
							GROUP BY 1,2) T4 ON T1.PartyEmployeeID = T4.PartyEmployeeID AND T3.ShortDate = T4.CompletedDate AND T4.CompletedDate >= T1.StartDate
		    LEFT JOIN PROD_DMA_VW.TIMEOUT_ACTIVITY_CURR_IVW T5 ON ShortDate = T5.MeetingDate AND T1.PartyEmployeeID = T5.PartyEmployeeID AND T5.MeetingDate >= T1.StartDate
			LEFT JOIN (SELECT * FROM PROD_DMA_VW.GOAL_DIM_VW WHERE GoalTypeID = 3 AND EndDate = '9999-12-31') T6 ON T1.DepartmentID = T6.DepartmentID AND T1.RoleID = T6.RoleID
			LEFT JOIN (SELECT * FROM PROD_DMA_VW.GOAL_DIM_VW WHERE GoalTypeID = 4 AND EndDate = '9999-12-31') T7 ON T1.DepartmentID = T7.DepartmentID AND T1.RoleID = T7.RoleID
--) After Release the Current Dimension will be used
/*			LEFT JOIN (SELECT * FROM PROD_DMA_VW.GOAL_CURR_DIM_VW WHERE GoalTypeID = 3) T6 ON T1.DepartmentID = T6.DepartmentID AND T1.RoleID = T6.RoleID
			LEFT JOIN (SELECT * FROM PROD_DMA_VW.GOAL_CURR_DIM_VW WHERE GoalTypeID = 4) T7 ON T1.DepartmentID = T7.DepartmentID AND T1.RoleID = T7.RoleID*/
		    WHERE ShortDate BETWEEN Add_Months(Current_Date, -3) AND Current_Date + INTERVAL '10' DAY 
		    GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,14,15) T1
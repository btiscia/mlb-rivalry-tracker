SELECT
ShortDate AS "Date"
,IsHoliday
,IsWeekday
,EmployeeLastName || ', ' || EmployeeFirstName AS Employee
,CASE 
    WHEN T1.FTE < 1 THEN 'Non-Production'
    ELSE 'Production'
END AS "Employee Type"
, ManagerLastName || ', ' || ManagerFirstName AS Manager
, TeamName AS "Team Name"
, RoleName AS "Role Name"
, RoleGradeName AS "Role Grade Name"
, ProductionGoal AS "Prod Goal"
, NonProductionGoal AS "Non Prod Goal"
, ActualFlexHours AS "Actual Flex Hours"
--, ActualNonWorkingHours AS  "Actual Non Working Hours" --("Actual Non-Prod Hours") DELETE
,CASE WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
    ELSE ActualNonWorkingHours
    END AS "Actual Non-Production Hours"
,CASE WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN ScheduledHours 
    ELSE ActualOOOHours
    END AS "Actual OOO Hours"
,ActualOTHours AS "Actual OT Hours"

,CASE WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
    ELSE ActualWorkingHours
    END AS "Actual Production Hours"

,ActualExcusedHours AS "Actual Excused Hours"
,ActualMakeupHours AS "Actual Makeup Hours"
,PlannedFlexHours AS "Planned Flex Hours"

,CASE WHEN AllDayOOO >= 1 OR (PlannedOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
    WHEN (ScheduledHours + PlannedOTHours + PlannedMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (PlannedOTHours + PlannedMakeupHours) = 0 THEN  0
    ELSE PlannedNonWorkingHours
    END AS "Planned Non-Production Hours"

,CASE WHEN AllDayOOO >= 1 OR (PlannedOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN ScheduledHours 
    ELSE PlannedOOOHourS
    END AS "Planned OOO Hours"

,PlannedOTHours AS "Planned OT Hours"

,CASE WHEN AllDayOOO >= 1 OR (PlannedOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
    WHEN (ScheduledHours + PlannedOTHours + PlannedMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (PlannedOTHours + PlannedMakeupHours) = 0 THEN  0
    ELSE PlannedWorkingHours
    END AS "Planned Prod Hours"

,PlannedExcusedHours AS "Planned Excused Hours"
,PlannedMakeupHours AS "Planned Makeup Hours"
,ScheduledHours AS "Working Hours"
,AdminTime AS "Admin Time"
,COALESCE(ProductivityCredits,0) AS "Productivity Credits"
,AllDayOOO AS "All Day OOO"

,CASE WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
    ELSE COALESCE(CAST("Productivity Credits" AS DECIMAL(12,5)),0) / 60 
    END AS "Productivity Hours"
    
,"Productivity Hours" + "Actual Production Hours" AS "Hours Productive"

,CASE WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0 
    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  (ActualOTHours + ActualMakeupHours - ActualExcusedHours - "Actual Non-Production Hours" - ActualOOOHours)
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) > 6 THEN  (ActualOTHours + ActualMakeupHours - ActualExcusedHours - "Actual Non-Production Hours" - ActualOOOHours - AdminTime)
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  (ScheduledHours + ActualOTHours + ActualMakeupHours - ActualExcusedHours - "Actual Non-Production Hours" - ActualOOOHours)
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  (ScheduledHours + ActualOTHours + ActualMakeupHours - ActualExcusedHours - "Actual Non-Production Hours" - ActualOOOHours - AdminTime)
    ELSE (ScheduledHours + ActualOTHours + ActualMakeupHours - ActualExcusedHours - "Actual Non-Production Hours" - ActualOOOHours - AdminTime) 
    END AS "Available Time"
    
,CASE WHEN AllDayOOO >= 1 OR (PlannedOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0 
    WHEN (ScheduledHours + PlannedOTHours + PlannedMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1) AND (PlannedOTHours + PlannedMakeupHours) = 0 THEN  0
    WHEN (IsHoliday = 1) AND (PlannedOTHours + PlannedMakeupHours) < 6 THEN  (PlannedOTHours + PlannedMakeupHours - PlannedExcusedHours - PlannedNonWorkingHours - PlannedOOOHours)
    WHEN (IsHoliday = 1) AND (PlannedOTHours + PlannedMakeupHours) > 6 THEN  (PlannedOTHours + PlannedMakeupHours - PlannedExcusedHours - PlannedNonWorkingHours - PlannedOOOHours - AdminTime)
    WHEN (ScheduledHours = 0) AND (PlannedOTHours + PlannedMakeupHours) < 6 THEN  (ScheduledHours + PlannedOTHours + PlannedMakeupHours - PlannedExcusedHours - PlannedNonWorkingHours - PlannedOOOHours)
    WHEN (ScheduledHours = 0) AND (PlannedOTHours + PlannedMakeupHours) >= 6 THEN  (ScheduledHours + PlannedOTHours + PlannedMakeupHours - PlannedExcusedHours - PlannedNonWorkingHours - PlannedOOOHours - AdminTime)
    ELSE (ScheduledHours + PlannedOTHours + PlannedMakeupHours - PlannedExcusedHours - PlannedNonWorkingHours - PlannedOOOHours - AdminTime) 
    END AS "Planned Available Time"
    
FROM PROD_DMA_VW.PERFORMANCE_FCT_VW T1
LEFT JOIN PROD_DMA_VW.EMPLOYEE_PIT_DIM_VW T2 ON T1.TeamPartyID = T2.TeamPartyID
 WHERE "Date" BETWEEN  ADD_MONTHS(CURRENT_DATE, -3) AND CURRENT_DATE + INTERVAL '10' DAY
 AND T1.DepartmentID IN (7,8)
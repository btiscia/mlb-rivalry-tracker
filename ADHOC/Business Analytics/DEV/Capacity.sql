
SELECT
ShortDate AS "Date"
,IsHoliday
,IsWeekday
,T2.MMID
,EmployeeLastName || ', ' || EmployeeFirstName AS Employee
,CASE WHEN T3.MaxEndDate = '9999-12-31' THEN 'Curr Employee'
                                                ELSE 'Termed Emplyee'
                                                END AS "Active Schedule Ident"

, ManagerLastName || ', ' || ManagerFirstName AS Manager
, TeamName AS "Team Name"
, RoleName AS "Role Name"
, RoleGradeName AS "Role Grade Name"
, ProductionGoal AS "Prod Goal"
, NonProductionGoal AS "Non Prod Goal"
, ActualFlexHours AS "Actual Flex Hours"

,CASE WHEN AllDayOOO >= 1 OR (PlannedOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN ScheduledHours 
    ELSE PlannedOOOHourS
    END AS "Planned OOO Hours"

,PlannedOTHours AS "Planned OT Hours"

,PlannedExcusedHours AS "Planned Excused Hours"
,PlannedMakeupHours AS "Planned Makeup Hours"
,COALESCE(ProductivityCredits,0) AS "Productivity Credits"
,AllDayOOO AS "All Day OOO"
-------
------use this case statement for testing only - to be deleted
-------

,CASE 
--             WHEN AllDayOOO >= 1 OR  (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 'A' 
--   WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 'B'
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  'C'
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  'A_Calc'   -----                                                
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  'B_Calc'---                                                
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  'C_Calc'----         
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  'D_Calc'-----    
    WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN  'E_Calc'
    ELSE 'Final_Calc'--     
    END AS "CalcID" --Jay Added
---------------
---
--Parts of actual production
--
-------------

,ScheduledHours AS "Working Hours"
,CASE 
    --WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0 
    --WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  0
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  0
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  ScheduledHours
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  ScheduledHours
    WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
    ELSE ScheduledHours
    END AS "Actual Working Hrs"
    
,ActualOTHours AS "Actual OT Hrs"
,ActualMakeupHours AS "Actual Makeup Hrs"
,ActualExcusedHours AS "Actual Excused Hrs"

,CASE 
    --WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0 
    --WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  (ActualOTHours + ActualMakeupHours - ActualExcusedHours)   
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  (ActualOTHours + ActualMakeupHours - ActualExcusedHours)
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  (ScheduledHours + ActualOTHours + ActualMakeupHours - ActualExcusedHours)
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  (ScheduledHours + ActualOTHours + ActualMakeupHours - ActualExcusedHours) 
    WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN  (ActualOTHours + ActualMakeupHours - ActualExcusedHours)
    ELSE (ScheduledHours + ActualOTHours + ActualMakeupHours - ActualExcusedHours)
    END AS "ACT Capacity" --Jay Added
---------------
-----
----Parts of Shrinkage
-----
-----------------
,CASE 
                --WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0 
   -- WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  0
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  (AdminTime)
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  0
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN   AdminTime
    WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
    ELSE  AdminTime
    END AS "Admin Time"

,CASE WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
    ELSE ActualNonWorkingHours
    END AS "Actual Non-Production Hrs"

,ActualOOOHours
,CASE WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN ScheduledHours 
    ELSE ActualOOOHours
    END AS "Actual OOO Hrs"
   
   

,CASE 
                --WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0 
   -- WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  "Actual OOO Hrs"
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  ( "Actual Non-Production Hrs" + "Actual OOO Hrs")
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  ( "Actual Non-Production Hrs" + "Actual OOO Hrs" + AdminTime)
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  ( "Actual Non-Production Hrs" + "Actual OOO Hrs")   ---Review with DAN!!!!!!!!
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  ("Actual Non-Production Hrs" + "Actual OOO Hrs"+ AdminTime)
    WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN ( "Actual OOO Hrs" )
    ELSE ( "Actual Non-Production Hrs" +  "Actual OOO Hrs"+ AdminTime)
    END AS "ACT Shrinkage"
    
-----------
-----------
FROM PROD_DMA_VW.PERFORMANCE_FCT_VW T1
JOIN PROD_DMA_VW.EMPLOYEE_PIT_DIM_VW T2 ON T1.TeamPartyID = T2.TeamPartyID
JOIN ( SELECT --Get the max date to use above for a current EE Termination identifier
                                                                                                MMID
                                                                                               , MAX(ENDDate) AS MaxEndDate
                                                                                               FROM PROD_DMA_VW.EMPLOYEE_PIT_DIM_VW
                                                                                                WHERE  DepartmentID IN (8) --to Get all EE's in Claims.  Not using T1 
                                                                                                AND  RoleID IN (15,16,17,19,22) 
                                                                                                AND PartyTypeName = 'EMPLOYEE'
                                                                                                AND TimeOutReportInd = 1  --filter timeout applicable users only Per Angela workflow
                                                                                                GROUP BY 1) T3 ON T2.MMID = T3.MMID
-- WHERE "Date" BETWEEN  Add_Months(Current_Date, -60) AND Current_Date + INTERVAL '10' DAY
AND T1.DepartmentID IN (8) --to Get all EE's in Claims.
AND  RoleID IN (15,16,17,19,22) AND
PartyTypeName = 'EMPLOYEE'
AND TimeOutReportInd = 1  --filter timeout applicable users only Per Angela workflow


 
 

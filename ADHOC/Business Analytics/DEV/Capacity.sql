
SELECT
ShortDate AS "Date"
,IsHoliday
,IsWeekday
,T2.MMID
,EmployeeLastName || ', ' || EmployeeFirstName AS Employee
,Case When T3.MaxEndDate = '9999-12-31' then 'Curr Employee'
                                                else 'Termed Emplyee'
                                                End as "Active Schedule Ident"

, ManagerLastName || ', ' || ManagerFirstName AS Manager
, TeamName AS "Team Name"
, RoleName AS "Role Name"
, RoleGradeName AS "Role Grade Name"
, ProductionGoal AS "Prod Goal"
, NonProductionGoal AS "Non Prod Goal"
, ActualFlexHours AS "Actual Flex Hours"


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

,Coalesce(ProductivityCredits,0) AS "Productivity Credits"
,AllDayOOO AS "All Day OOO"

,CASE WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
    ELSE Coalesce(Cast("Productivity Credits" AS DECIMAL(12,5)),0) / 60 
    END AS "Productivity Hours"
    
,"Productivity Hours" + "Actual Production Hours" AS "Hours Productive"

,CASE ----use this case statement for testing only - to be deleted
--             WHEN AllDayOOO >= 1 OR  (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 'A' 
--   WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 'B'
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  'C'
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  'A_Calc'   -----                                                
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  'B_Calc'---                                                
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  'C_Calc'----         
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  'D_Calc'-----    
    WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) Then  'E_Calc'
    ELSE 'Final_Calc'--     
    END AS "CalcID" --Jay Added

,ActualMakeupHours
,CASE 
    --WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0 
    --WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  (ActualOTHours + ActualMakeupHours - ActualExcusedHours)   
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  (ActualOTHours + ActualMakeupHours - ActualExcusedHours)
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  (ScheduledHours + ActualOTHours + ActualMakeupHours - ActualExcusedHours)
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  (ScheduledHours + ActualOTHours + ActualMakeupHours - ActualExcusedHours) 
    WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) Then  (ActualOTHours + ActualMakeupHours - ActualExcusedHours)
    ELSE (ScheduledHours + ActualOTHours + ActualMakeupHours - ActualExcusedHours)
    END AS "ACT Capacity Available Production" --Jay Added

-----------------
------------------

----AdminTime
,CASE 
                --WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0 
   -- WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  0
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  (AdminTime)
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  0
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN   AdminTime
    WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) Then 0
    ELSE  AdminTime
    END AS "Admin Time"        --Jay Added  

,CASE WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
    ELSE ActualNonWorkingHours
    END AS "Actual Non-Production Hours"

,ActualOOOHours
,CASE WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN ScheduledHours 
    ELSE ActualOOOHours
    END AS "Actual OOO Hours"
    
   
-----------
-----------

,CASE 
                --WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0 
   -- WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  "Actual OOO Hours"
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  ( "Actual Non-Production Hours" + "Actual OOO Hours")
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  ( "Actual Non-Production Hours" + "Actual OOO Hours" + AdminTime)
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  ( "Actual Non-Production Hours" + "Actual OOO Hours")   ---Review with DAN!!!!!!!!
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  ("Actual Non-Production Hours" + "Actual OOO Hours"+ AdminTime)
    WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) Then ("Actual Non-Production Hours" +  "Actual OOO Hours" ) ---Maybe take out Non Prod hrs.  !!!!!!!!!1
    ELSE ( "Actual Non-Production Hours" +  "Actual OOO Hours"+ AdminTime)
    END AS "ACT Capacity Shrinkage"        --Jay Added

                        
,CASE WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0 
    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  (ActualOTHours + ActualMakeupHours - ActualExcusedHours - "Actual Non-Production Hours" - ActualOOOHours)
    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) > 6 THEN  (ActualOTHours + ActualMakeupHours - ActualExcusedHours - "Actual Non-Production Hours" - ActualOOOHours - AdminTime)
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  (ScheduledHours + ActualOTHours + ActualMakeupHours - ActualExcusedHours - "Actual Non-Production Hours" - ActualOOOHours)
    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  (ScheduledHours + ActualOTHours + ActualMakeupHours - ActualExcusedHours - "Actual Non-Production Hours" - ActualOOOHours - AdminTime)
    ELSE (ScheduledHours + ActualOTHours + ActualMakeupHours - ActualExcusedHours - "Actual Non-Production Hours" - ActualOOOHours - AdminTime) 
    END AS "Available Time"

,PlannedNonWorkingHours

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
JOIN PROD_DMA_VW.EMPLOYEE_PIT_DIM_VW T2 ON T1.TeamPartyID = T2.TeamPartyID
JOIN ( Select --Get the max date to use above for a current EE Termination identifier
                                                                                                MMID
                                                                                               , Max(ENDDate) as MaxEndDate
                                                                                               FROM PROD_DMA_VW.EMPLOYEE_PIT_DIM_VW
                                                                                                where  DepartmentID IN (8) --to Get all EE's in Claims.  Not using T1 
                                                                                                and  RoleID in (15,16,17,19,22) 
                                                                                                AND PartyTypeName = 'EMPLOYEE'
                                                                                                And TimeOutReportInd = 1  --filter timeout applicable users only Per Angela workflow
                                                                                                Group by 1) T3 on T2.MMID = T3.MMID
-- WHERE "Date" BETWEEN  Add_Months(Current_Date, -60) AND Current_Date + INTERVAL '10' DAY
AND T1.DepartmentID IN (8) --to Get all EE's in Claims.
and  RoleID in (15,16,17,19,22) AND
PartyTypeName = 'EMPLOYEE'
And TimeOutReportInd = 1  --filter timeout applicable users only Per Angela workflow


 
 

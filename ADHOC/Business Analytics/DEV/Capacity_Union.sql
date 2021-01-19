SELECT
CAST ('TimeOut' AS VARCHAR (50)) AS "TransactionTypeName"
, NULL AS ForecastID
, T2.MMID
, EmployeeLastName || ', ' || EmployeeFirstName AS Employee
, CASE 
			WHEN T3.EE_EndDate = '9999-12-31' THEN 'Curr Employee'
            ELSE 'Termed Emplyee'
            END AS "Active Schedule Ident"
, ManagerLastName || ', ' || ManagerFirstName AS Manager
, TeamName AS "Team Name"
, T2.RoleID
, T2.RoleName AS "Role Name"
, CASE 
		    WHEN T2.RoleName LIKE 'Life Claim%' THEN 'Life Claim Examiner'
		    WHEN T2.RoleName LIKE 'Life Pay%' THEN 'Life Pay'
		    ELSE T2.RoleName
		    END AS "WorkRole" 
, EE_Startdate
, RoleStartDate
, EE_EndDate
, ShortDate AS "Date"
, IsHoliday
, IsWeekday
, Case 
            When T2.RoleName Like ('%Consultant') Then CAST(11 AS INTEGER)
            When (ShortDate-RoleStartDate) Month(4) >9 Then CAST(10 AS INTEGER)
			Else  CAST(((ShortDate-RoleStartDate) Month(4)) AS INTEGER)
			End as Experience
, Case 
            When T2.RoleName Like ('%Consultant') Then 'Consultant'
            When (ShortDate-RoleStartDate) Month(4) >9 Then 'Experienced'
			Else  'New Hire'
			End as EE_TYPE
, T4.Effective AS "%Effective"
, CAST(NULL AS INTEGER) AS "EffectiveFTE"
, CAST(NULL AS INTEGER) AS "ForecastEffectiveFTE_high95"
, CAST(NULL AS INTEGER) AS "ForecastEffectiveFTE_high80"
, CAST(NULL AS INTEGER) AS "ForecastEffectiveFTE_low80"
, CAST(NULL AS INTEGER) AS "ForecastEffectiveFTE_low95"
, ActualFlexHours AS "Actual Flex Hours"
, CASE 
			WHEN AllDayOOO >= 1 OR (PlannedOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN ScheduledHours 
		    ELSE PlannedOOOHourS
		    END AS "Planned OOO Hours"
, PlannedOTHours AS "Planned OT Hours"
, PlannedExcusedHours AS "Planned Excused Hours"
, PlannedMakeupHours AS "Planned Makeup Hours"
, COALESCE(ProductivityCredits,0) AS "Productivity Credits"
, AllDayOOO AS "All Day OOO"
, ScheduledHours AS "Working Hours"
, CASE 
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  0
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  0
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  ScheduledHours
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  ScheduledHours
		    WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
		    ELSE ScheduledHours
		    END AS "Actual Working Hrs"    
, ActualOTHours AS "Actual OT Hrs"
, ActualMakeupHours AS "Actual Makeup Hrs"
, ActualExcusedHours AS "Actual Excused Hrs"
, CASE 
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  (ActualOTHours + ActualMakeupHours - ActualExcusedHours)   
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  (ActualOTHours + ActualMakeupHours - ActualExcusedHours)
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  (ScheduledHours + ActualOTHours + ActualMakeupHours - ActualExcusedHours)
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  (ScheduledHours + ActualOTHours + ActualMakeupHours - ActualExcusedHours) 
		    WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN  (ActualOTHours + ActualMakeupHours - ActualExcusedHours)
		    ELSE (ScheduledHours + ActualOTHours + ActualMakeupHours - ActualExcusedHours)
		    END AS "Actual Capacity" --New    
, ("Actual Capacity" * T4.Effective)  as "Effective Capacity"
, CAST(NULL AS INTEGER) AS "ForecastCapacity_high95"
, CAST(NULL AS INTEGER) AS "ForecastCapacity_high80"
, CAST(NULL AS INTEGER) AS "ForecastCapacity_low80"
, CAST(NULL AS INTEGER) AS "ForecastCapacity_low95" 
, ("Actual Capacity" - "Effective Capacity") as "Efficiency Loss"   
, CASE 
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  0
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  (AdminTime)
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  0
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN   AdminTime
		    WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
		    ELSE  AdminTime
		    END AS "Admin Time"
, CASE 
			WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
		    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
		    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
		    ELSE ActualNonWorkingHours
		    END AS "Actual Non-Production Hrs"
, ActualOOOHours
, CASE 
			WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN ScheduledHours 
		    ELSE ActualOOOHours
		    END AS "Actual OOO Hrs"   
, CASE 
	    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  "Actual OOO Hrs"
	    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  ( "Actual Non-Production Hrs" + "Actual OOO Hrs")
	    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  ( "Actual Non-Production Hrs" + "Actual OOO Hrs" + AdminTime)
	    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  ( "Actual Non-Production Hrs" + "Actual OOO Hrs")
	    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  ("Actual Non-Production Hrs" + "Actual OOO Hrs"+ AdminTime)
	    WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN ( "Actual OOO Hrs" )
	    ELSE ( "Actual Non-Production Hrs" +  "Actual OOO Hrs"+ AdminTime)
	    END AS "Shrinkage Hrs" 
, CAST (NULL AS FLOAT) AS "%Shrinkage"       
, CAST(NULL AS FLOAT) AS "ForecastShrinkage_high95"
, CAST(NULL AS FLOAT) AS "ForecastShrinkage_high80"
, CAST(NULL AS FLOAT) AS "ForecastShrinkage_low80"
, CAST(NULL AS FLOAT) AS "ForecastShrinkage_low95"
, CASE 
			WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
		    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
		    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
		    ELSE Coalesce(Cast("Productivity Credits" AS DECIMAL(12,5)),0) / 60 
		    END AS "Productivity Hours"  
, CASE 
			WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
		    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
		    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
		    ELSE ActualWorkingHours
		    END AS "Actual Production Hours"
, "Productivity Hours" + "Actual Production Hours" AS "Hours Productive"
FROM PROD_DMA_VW.PERFORMANCE_FCT_VW T1
JOIN PROD_DMA_VW.EMPLOYEE_PIT_DIM_VW T2 ON T1.TeamPartyID = T2.TeamPartyID
JOIN ( SELECT Distinct MMID
							, RoleID
							, RoleName
							, Min(Case 
							                  When Extract(Year From StartDate) = '1900' Then HireDate
				                               Else StartDate
				                               End) OVER (PARTITION  BY MMID) as EE_Startdate
							, MIN(Case 
				                               When Extract(Year From StartDate) = '1900' Then HireDate
				                               Else StartDate
				                               End) OVER (PARTITION BY MMID,ROLEID) as RoleStartDate  ---New
							, MAX(EndDate) OVER (PARTITION BY MMID) as EE_EndDate
				FROM PROD_DMA_VW.EMPLOYEE_PIT_DIM_VW
    			WHERE  DepartmentID IN (8) 
    			AND  RoleID IN (15,16,17,19,22) 
    			AND PartyTypeName = 'EMPLOYEE'
   				 AND TimeOutReportInd = 1) T3 ON T2.MMID = T3.MMID and T2.RoleID = T3.RoleID
Join DMA_GRP_DL.RT20_LC_Capacity_ExperianceLOV T4 on 
																										Case 
							                																	When T2.RoleName Like ('%Consultant') Then CAST(11 AS INTEGER)
							               																		When (ShortDate-RoleStartDate) Month(4) >9 Then CAST(10 AS INTEGER)
																												Else  CAST(((ShortDate-RoleStartDate) Month(4)) AS INTEGER)
																										End = T4.Experiance
AND T1.DepartmentID IN (8)
AND T2.RoleID IN (15,16,17,19,22) AND
PartyTypeName = 'EMPLOYEE'
AND TimeOutReportInd = 1

UNION ALL

SELECT
CAST ('Forecast' AS VARCHAR (50)) AS "TransactionTypeName"
, F.ForecastID
, CAST(NULL AS VARCHAR(50)) AS "MMID"
, CAST(NULL AS VARCHAR(100)) AS "Employee"
, CAST(NULL AS VARCHAR(100)) AS "Active Schedule Ident"
, CAST(NULL AS VARCHAR(100)) AS "Manager"
, CAST(NULL AS VARCHAR(100)) AS "Team Name"
, CAST(NULL AS INTEGER) AS "RoleID"
, CAST(NULL AS VARCHAR(100)) AS "Role Name"
, F.WorkRole 
, CAST(NULL AS DATE) AS "EE_Startdate"
, CAST(NULL AS DATE) AS "RoleStartDate"
, CAST(NULL AS DATE) AS "EE_EndDate"
,F.ForecastDate AS "Date" 
--,( F.ForecastDate - INTERVAL '1'YEAR) AS "Date"   ----Minus 1 year so I can test the design of the dashboard
, CAST(NULL AS INTEGER) AS "IsHoliday"
, CAST(NULL AS INTEGER) AS "IsWeekday"
, CAST(NULL AS INTEGER) AS "Experience"
, CAST(NULL AS VARCHAR(100)) AS "EE_TYPE"
,Cast(NULL AS INTEGER) AS "%Effective"
, F.ForecastEffectiveFTE "EffectiveFTE"
, F.ForecastEffectiveFTE_high95
, F.ForecastEffectiveFTE_high80
, F.ForecastEffectiveFTE_low80
, F.ForecastEffectiveFTE_low95
, CAST(NULL AS INTEGER) AS "Actual Flex Hours"
, CAST(NULL AS INTEGER) AS "Planned OOO Hours"
, CAST(NULL AS INTEGER) AS "Planned OT Hours"
, CAST(NULL AS INTEGER) AS "Planned Excused Hours"
, CAST(NULL AS INTEGER) AS "Planned Makeup Hours"
, CAST(NULL AS INTEGER) AS "Productivity Credits"
, CAST(NULL AS INTEGER) AS "All Day OOO"
, CAST(NULL AS INTEGER) AS "Working Hours"
, CAST(NULL AS INTEGER) AS "Actual Working Hrs"    
, CAST(NULL AS INTEGER) AS "Actual OT Hrs"
, CAST(NULL AS INTEGER) AS "Actual Makeup Hrs"
, CAST(NULL AS INTEGER) AS "Actual Excused Hrs"
, CAST(NULL AS INTEGER) AS "Actual Capacity"
, F.ForecastCapacity AS "Effective Capacity"
, F.ForecastCapacity_high95
, F.ForecastCapacity_high80
, F.ForecastCapacity_low80
, F.ForecastCapacity_low95
, CAST(NULL AS INTEGER) AS "Efficiency Loss"   
, CAST(NULL AS INTEGER) AS "Admin Time"
, CAST(NULL AS INTEGER) AS "Actual Non-Production Hrs"
, CAST(NULL AS INTEGER) AS "ActualOOOHours"
, CAST(NULL AS INTEGER) AS "Actual OOO Hrs"   
, CAST(NULL AS INTEGER) AS "Shrinkage Hrs" 
, F.ForecastShrinkage AS "%Shrinkage"
, F.ForecastShrinkage_high95
, F.ForecastShrinkage_high80
, F.ForecastShrinkage_low80
, F.ForecastShrinkage_low95
, CAST(NULL AS INTEGER) AS "Productivity Hours"  
, CAST(NULL AS INTEGER) AS "Actual Production Hours"
, CAST(NULL AS INTEGER) AS "Hours Productive"
FROM DMA_GRP_DL.RT20_00002983_LC_Capacity F
INNER JOIN
	(SELECT MAX(ForecastID) as FxID 
	FROM DMA_GRP_DL.RT20_00002983_LC_Capacity) D2
	ON F.ForecastID = FxID
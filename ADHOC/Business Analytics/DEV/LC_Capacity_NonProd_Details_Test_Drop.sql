
Select 
T2.MMID
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
, ShortDate AS "Date"
, IsHoliday
, IsWeekday
, AllDayOOO AS "All Day OOO"
, CASE 
			WHEN AllDayOOO = 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
		    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
		    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
		    ELSE ActualNonWorkingHours
		    END AS "Actual Non-Production Hrs"

,T6.MeetingTitle
,T6.MeetingDescription
,T6.TimeType
,T6.PlannedActual
,T6.Duration

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
				FROM PROD_DMA_VW.EMPLOYEE_PIT_DIM_VW ) T3 ON T2.MMID = T3.MMID and T2.RoleID = T3.RoleID

Join (	Select MMID,MeetingDate,MeetingTitle,MeetingDescription,TimeType,PlannedActual,Timecategory,ParentTimeCategory,Duration
				    From  PROD_DMA_VW.TIMEOUT_ACTIVITY_PIT_IVW T4
					Join (Select Distinct * From PROD_DMA_VW.SCHEDULE_PIT_DIM_VW where HRID IS not null) T5 on T4.HRID = T5.HRID and T4."MeetingDate" Between T5.StartDate and EndDate And td_day_of_week(T4.MeetingDate) = T5.DayofWeek
					)T6 on T2.MMID = T6.MMID and "Date" = T6.MeetingDate 

AND T1.DepartmentID IN (8)
AND T2.RoleID IN (13,15,16,17,19,22) AND
PartyTypeName = 'EMPLOYEE'
AND TimeOutReportInd = 1
And "Actual Non-Production Hrs" <>0
--and TimeCategory not in ('Out of Office','Remote Work')
And TimeType = 'Non-Production'
and PlannedActual <> 'Planned'

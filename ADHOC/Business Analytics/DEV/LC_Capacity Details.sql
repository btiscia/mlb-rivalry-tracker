---Created to get Non Prod details logged in Time out, and Prod details of meetings loged.  


SELECT 
T1.RoleID
,T1.TimeOutReportInd
,ShortDate AS SHORT_DT
,T1.FTE AS FTE
,T2.IsHoliday AS IS_HOLIDAY
,T2.IsWeekday AS IS_WEEKDAY
,T1.TeamPartyID AS TEAM_PARTY_ID
,T1.DepartmentID AS DEPARTMENT_ID
,T5.TransDt AS TRANS_DT
,WorkingHours AS WORKING_HRS
,AdminTime AS ADMIN_TIME
,ProdCredits AS PROD_CREDITS
,T6.GoalValue AS PROD_GOAL
,T7.GoalValue AS NON_PROD_GOAL
,ActualFlexHours AS ACTUAL_FLEX_HRS
,ActualNonProdHours AS ACTUAL_NON_PROD_HRS
,ActualOOOHours AS ACTUAL_OOO_HRS
,ActualOTHours AS ACTUAL_OT_HRS
,ActualProdHours AS ACTUAL_PROD_HRS
,PlannedFlexHours AS PLANNED_FLEX_HRS
,PlannedNonProdHours AS PLANNED_NON_PROD_HRS
,PlannedOOOHours AS PLANNED_OOO_HRS
,PlannedOTHours AS PLANNED_OT_HRS
,PlannedProdHours AS PLANNED_PROD_HRS
,PlannedExcusedHours AS PLANNED_EXCUSED_HRS
,ActualExcusedHours AS ACTUAL_EXCUSED_HRS
,ActualMakeupHours AS ACTUAL_MAKEUP_HRS
,PlannedMakeupHours AS PLANNED_MAKEUP_HRS
,AllDayOOO AS ALL_DAY_OOO
FROM (SELECT * FROM PROD_DMA_VW.EMPLOYEE_PIT_DIM_VW T1 WHERE DepartmentID IN (7,8)) T1

INNER JOIN (SELECT ShortDate, T2.DayOfWeek, IsHoliday, IsWeekday, HRID, WorkingHours, AdminTime, StartDate
						FROM PROD_DMA_VW.SCHEDULE_PIT_DIM_VW T2

INNER JOIN PROD_DMA_VW.DATE_DIM_VW T3 ON T2.DayOfWeek = T3.DayOfWeek
			  WHERE SHORTDATE BETWEEN StartDate AND EndDate) T2 ON T1.HRID = T2.HRID AND T2.ShortDate BETWEEN T1.StartDate AND T1.EndDate

LEFT JOIN (SELECT PartyEmployeeID
						, CompletedDate
						, SUM(ProdCredit) AS ProdCredits
						FROM PROD_DMA_VW.ACT_LAC_PIT_INTEGRATED_VW
						WHERE TransactionTypeID = 3 AND CompletedDate BETWEEN ADD_MONTHS(CURRENT_DATE, -12)
						AND CURRENT_DATE + INTERVAL '10' DAY
						GROUP BY 1,2) T4
						ON T1.PartyEmployeeID = T4.PartyEmployeeID AND T2.ShortDate = T4.CompletedDate

LEFT JOIN PROD_DMA_VW.ACTIVITY_TO_FCT_VW T5 ON ShortDate = T5.MeetingDate AND T1.PartyEmployeeID = T5.PartyEmployeeID  --Get time out data

LEFT JOIN (SELECT * FROM PROD_DMA_VW.GOAL_PIT_DIM_VW WHERE GoalTypeID = 3) T6
					  ON T1.DepartmentID = T6.DepartmentID AND T1.RoleID = T6.RoleID AND ShortDate BETWEEN T6.StartDAte AND T6.EndDate

LEFT JOIN (SELECT * FROM PROD_DMA_VW.GOAL_PIT_DIM_VW WHERE GoalTypeID = 4) T7
    				  ON T1.DepartmentID = T7.DepartmentID AND T1.RoleID = T7.RoleID AND ShortDate BETWEEN T7.StartDate AND T7.EndDate

WHERE ShortDate BETWEEN (CASE WHEN T1.StartDate < CURRENT_DATE - INTERVAL '36' MONTH
														THEN T2.StartDate ELSE ADD_MONTHS(CURRENT_DATE, -36) END)
AND CURRENT_DATE + INTERVAL '10' DAY
And Department_ID = 8
AND T1.RoleID in (13,15,16,17,19,22) 
--And T1.Timeoutreportind <>1




/*   -------Orginal way to get only Non Prod details ---tested values matched to performance fact.  Once above is finalized this can be deleted.  

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
AND T2.RoleID IN (13,15,16,17,19,22) 
AND PartyTypeName = 'EMPLOYEE'
AND TimeOutReportInd = 1
And "Actual Non-Production Hrs" <>0
--and TimeCategory not in ('Out of Office','Remote Work')
And TimeType = 'Non-Production'
and PlannedActual <> 'Planned'*/

With T as (
Select 
T1.RoleID
,T1.RoleName 
,T1.TimeOutReportInd
,T1.TeamName
,T1.DepartmentName
,T1.MMID
,T1.PartyTypeName
,T1.EmployeeLastName || ', ' || T1.EmployeeFirstName AS Employee
,T1.ManagerLastName || ', ' || T1.ManagerFirstName AS Manager
,ShortDate AS "Date"
,T5.MeetingTitle
,T5.Description
,T5.Duration
,T1.FTE AS FTE
,T2.IsHoliday AS IS_HOLIDAY
,T2.IsWeekday AS IS_WEEKDAY
,T1.TeamPartyID AS TEAM_PARTY_ID
,T1.DepartmentID AS DEPARTMENT_ID
,T5.TransDt AS TRANS_DT
,WorkingHours AS ScheduledHours
--,AdminTime AS ADMIN_TIME
,ProdCredits AS PROD_CREDITS
,Count (*) Over (Partition By ShortDate, T1.MMID) as EE_Day_RowCnt
,COALESCE(ProdCredits,0) AS "Productivity Credits_Whole"
--,COALESCE(ProdCredits/EE_Day_RowCnt ,0)"Productivity Credits_Part_NoCase"
,COALESCE(ActualMakeupHours ,0) AS ACTUAL_MAKEUP_HRS
, CASE 
			WHEN All_Day_OOO = 1 OR (ACTUAL_OOO_HRS >= ScheduledHours AND ScheduledHours <> 0) THEN 0
		    WHEN (ScheduledHours + ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN 0 
		    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN  0
		    ELSE COALESCE(Cast (ProdCredits/EE_Day_RowCnt as Decimal (12,5)) ,0)/60
		    END AS  "Productivity Hours"

, CASE 
			WHEN All_Day_OOO >= 1 OR (ACTUAL_OOO_HRS >= ScheduledHours AND ScheduledHours <> 0) THEN 0
		    WHEN (ScheduledHours + ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN 0 
		    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN  0
		    ELSE COALESCE (ActualProdHours ,0)
		    END AS  "Actual Production Hours"
, "Productivity Hours" + "Actual Production Hours" AS "Hours Productive"
, CASE 
			WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN  (ScheduledHours)
		    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  0
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  0
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  ScheduledHours
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  ScheduledHours
		    ELSE ScheduledHours
		    END AS "Actual Working Hrs"    
, CASE 
			WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN  0
		    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  ActualOTHours
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  ActualOTHours
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  ActualOTHours 
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  ActualOTHours  
		    ELSE ActualOTHours
		    END AS "Actual OT Hrs"
, CASE 
			WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN  0
		    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN   ActualMakeupHours
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN   ActualMakeupHours
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  ActualMakeupHours
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  ActualMakeupHours
		    ELSE  ActualMakeupHours
		    END AS  "Actual Makeup Hrs" 
, CASE 
			WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN  0
		    WHEN (ScheduledHours + ActualOTHours + ActualMakeupHours) = 0 THEN 0 
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  ActualExcusedHours
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  ActualExcusedHours
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN ActualExcusedHours
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN ActualExcusedHours
		    ELSE ActualExcusedHours
		    END AS "Actual Excused Hrs"
,COALESCE (Sum(AllDayOOO) OVER (Partition by ShortDate,T1.MMID),0) as All_Day_OOO  ---Need to test if its accurate
,COALESCE (Sum(ActualOTHours) OVER (Partition by ShortDate,T1.MMID),0) as ACTUAL_OT_HRS ---Need to test if its accurate
--Need to test if its accurate
--,ActualNonProdHours AS ACTUAL_NON_PROD_HRS
, CASE 
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) = 0 THEN  0
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  0
		    WHEN (IsHoliday = 1) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN  (AdminTime)
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) < 6 THEN  0
		    WHEN (ScheduledHours = 0) AND (ActualOTHours + ActualMakeupHours) >= 6 THEN   AdminTime
		    WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN 0
		    ELSE  AdminTime
		    END AS "Admin Time"
, CASE 
			WHEN AllDayOOO >= 1 OR (ActualOOOHours >= ScheduledHours AND ScheduledHours <> 0) THEN ScheduledHours 
		    ELSE ActualOOOHours
		    END AS "Actual OOO Hrs"   
,COALESCE (Sum(ActualOOOHours) OVER (Partition by ShortDate,T1.MMID),0) as ACTUAL_OOO_HRS
,ActualOOOHours
, CASE 
			WHEN All_Day_OOO >= 1 OR (ACTUAL_OOO_HRS >= ScheduledHours AND ScheduledHours <> 0) THEN 0
		    WHEN (ScheduledHours + ACTUAL_OT_HRS +ACTUAL_MAKEUP_HRS) = 0 THEN 0 
		    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN  0
		    ELSE COALESCE( ActualNonProdHours,0)
		    END AS  "Actual Non-Production Hrs"
, CASE 
			WHEN All_Day_OOO >= 1 OR (ACTUAL_OOO_HRS >= ScheduledHours AND ScheduledHours <> 0) THEN 'A'
		    WHEN (ScheduledHours + ACTUAL_OT_HRS+ ACTUAL_MAKEUP_HRS) = 0 THEN 'B'
		    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN  'C'
		    ELSE 'D'
		    END AS  Test
,T5.TimeType

,ActualOTHours 
,ActualProdHours AS ACTUAL_PROD_HRS
/*,PlannedFlexHours AS PLANNED_FLEX_HRS
,PlannedNonProdHours AS PLANNED_NON_PROD_HRS
,PlannedOOOHours AS PLANNED_OOO_HRS
,PlannedOTHours AS PLANNED_OT_HRS
,PlannedProdHours AS PLANNED_PROD_HRS
,PlannedExcusedHours AS PLANNED_EXCUSED_HRS
,ActualExcusedHours AS ACTUAL_EXCUSED_HRS*/
--,ActualMakeupHours AS ACTUAL_MAKEUP_HRS
--,PlannedMakeupHours AS PLANNED_MAKEUP_HRS
,AllDayOOO
,CAST(((ShortDate-RoleStartDate) Month(4)) AS INTEGER) as Experiance
FROM (SELECT * FROM PROD_DMA_VW.EMPLOYEE_PIT_DIM_VW T1 WHERE DepartmentID IN (11,47)) T1

INNER JOIN (SELECT ShortDate, T2.DayOfWeek, IsHoliday, IsWeekday, HRID, WorkingHours, AdminTime, StartDate
						FROM PROD_DMA_VW.SCHEDULE_PIT_DIM_VW T2
						INNER JOIN PROD_DMA_VW.DATE_DIM_VW T3 ON T2.DayOfWeek = T3.DayOfWeek
			 			 WHERE SHORTDATE BETWEEN StartDate AND EndDate) T2 ON T1.HRID = T2.HRID AND T2.ShortDate BETWEEN T1.StartDate AND T1.EndDate
JOIN ( SELECT Distinct MMID --Get role start date for experiance
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
				FROM PROD_DMA_VW.EMPLOYEE_PIT_DIM_VW ) T3 ON T1.MMID = T3.MMID and T1.RoleID = T3.RoleID
LEFT JOIN (SELECT PartyEmployeeID   ----Get Cats data for production
						, CompletedDate
						, SUM(ProdCredit) AS ProdCredits
						FROM PROD_DMA_VW.ACT_LAC_PIT_INTEGRATED_VW
						WHERE TransactionTypeID = 3 AND CompletedDate BETWEEN ADD_MONTHS(CURRENT_DATE, -12)
						AND CURRENT_DATE + INTERVAL '10' DAY
						GROUP BY 1,2) T4
						ON T1.PartyEmployeeID = T4.PartyEmployeeID AND T2.ShortDate = T4.CompletedDate
LEFT JOIN PROD_DMA_VW.ACTIVITY_TO_FCT_VW T5 ON ShortDate = T5.MeetingDate AND T1.PartyEmployeeID = T5.PartyEmployeeID

WHERE ShortDate BETWEEN (CASE WHEN T1.StartDate < CURRENT_DATE - INTERVAL '36' MONTH
														THEN T2.StartDate ELSE ADD_MONTHS(CURRENT_DATE, -36) END)
AND CURRENT_DATE + INTERVAL '10' DAY

)
Select * 
From T
--Where ACTUAL_OOO_HRS <> ActualOOOHours 
 --ACTUAL_OT_HRS <> ActualOTHours 
--Where All_Day_OOO = 1

--order by MMID, "DATE"
where MMID = 'MM34273'
and "DATE" = '2020-05-05'
/*
FILENAME: LA CLAIMS CAPACITY Details
CREATED BY: Jay Johnson
LAST UPDATED: 11/22/2021
CHANGES MADE: Modifications to the source tables.
*/

SELECT 
T1.RoleID
, CASE 
		    WHEN T1.RoleName LIKE 'Life Claim%' THEN 'Life Claim Examiner'
		    WHEN T1.RoleName LIKE 'Life Pay%' THEN 'Life Pay'
		    ELSE T1.RoleName
		    END AS "WorkRole" 
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
,AdminTime AS ADMIN_TIME
,ProdCredits AS PROD_CREDITS
,COUNT (*) OVER (PARTITION BY ShortDate, MMID) AS EE_Day_RowCnt
,COALESCE(ProdCredits,0) AS "Productivity Credits_Whole"
,COALESCE(ActualMakeupHours ,0) AS ACTUAL_MAKEUP_HRS

, CASE 
			WHEN All_Day_OOO = 1 OR (ACTUAL_OOO_HRS >= ScheduledHours AND ScheduledHours <> 0) THEN 0
		    WHEN (ScheduledHours + ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN 0 
		    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN  0
		    ELSE COALESCE(CAST (ProdCredits/EE_Day_RowCnt AS DECIMAL (12,5)) ,0)/60
		    END AS  "Productivity Hours"

, CASE 
			WHEN All_Day_OOO >= 1 OR (ACTUAL_OOO_HRS >= ScheduledHours AND ScheduledHours <> 0) THEN 0
		    WHEN (ScheduledHours + ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN 0 
		    WHEN (IsHoliday = 1 OR ScheduledHours = 0) AND (ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN  0
		    ELSE COALESCE (ActualProdHours ,0)
		    END AS  "Actual Production Hours"
, "Productivity Hours" + "Actual Production Hours" AS "Hours Productive"

,COALESCE (SUM(AllDayOOO) OVER (PARTITION BY ShortDate,MMID),0) AS All_Day_OOO
,COALESCE (SUM(ActualOTHours) OVER (PARTITION BY ShortDate,MMID),0) AS ACTUAL_OT_HRS
,COALESCE (SUM(ActualOOOHours) OVER (PARTITION BY ShortDate,MMID),0) AS ACTUAL_OOO_HRS
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
,ActualProdHours AS ACTUAL_PROD_HRS
FROM (SELECT * FROM PROD_DMA_VW.EMPLOYEE_PIT_DIM_VW T1 WHERE DepartmentID IN (/*7,*/8)) T1

INNER JOIN (SELECT ShortDate, T2.DayOfWeek, IsHoliday, IsWeekday, HRID, WorkingHours, AdminTime, StartDate
						FROM PROD_DMA_VW.SCHEDULE_PIT_DIM_VW T2

INNER JOIN PROD_DMA_VW.DATE_DIM_VW T3 ON T2.DayOfWeek = T3.DayOfWeek
			 			 WHERE SHORTDATE BETWEEN StartDate AND EndDate) T2 ON T1.HRID = T2.HRID AND T2.ShortDate BETWEEN T1.StartDate AND T1.EndDate

LEFT JOIN (SELECT PartyEmployeeID   ----Get Cats data for production
						, CompletedDate
						, SUM(ProdCredit) AS ProdCredits
						FROM PROD_DMA_VW.ACT_LAC_PIT_INTEGRATED_VW
						WHERE TransactionTypeID = 3 AND CompletedDate BETWEEN ADD_MONTHS(CURRENT_DATE, -12)
						AND CURRENT_DATE + INTERVAL '10' DAY
						GROUP BY 1,2) T4
						ON T1.PartyEmployeeID = T4.PartyEmployeeID AND T2.ShortDate = T4.CompletedDate

LEFT JOIN PROD_DMA_VW.ACTIVITY_TO_FCT_VW T5 ON ShortDate = T5.MeetingDate AND T1.PartyEmployeeID = T5.PartyEmployeeID  --Get time out data

WHERE ShortDate BETWEEN (CASE WHEN T1.StartDate < CURRENT_DATE - INTERVAL '36' MONTH
														THEN T2.StartDate ELSE ADD_MONTHS(CURRENT_DATE, -36) END)
AND CURRENT_DATE + INTERVAL '10' DAY
AND T1.RoleID IN (13,15,16,17,19,22) 
AND (PROD_CREDITS IS NOT NULL  OR Actual_Prod_Hrs IS NOT NULL)  --reduces number of records returned.
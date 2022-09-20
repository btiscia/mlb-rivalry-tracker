/*
FILENAME: LA CLAIMS CAPACITY Details
CREATED BY: Jay Johnson
LAST UPDATED: 3/21/2022
CHANGES MADE: Modifications to the source tables.
query runs on vertica as of 3-29-22
Runs on prod as of 5/5
*/
SELECT 
T1.role_id as RoleID
,CASE 
		    WHEN T1.role_nm LIKE 'Life Claim%' THEN 'Life Claim Examiner'
		    WHEN T1.role_nm LIKE 'Life Pay%' THEN 'Life Pay'
		    ELSE T1.role_nm
		    END AS "WorkRole" 
--,T1.TimeOutReportInd
,T1.team_nm as TeamName
,T1.department_nm as DepartmentName
,T1.MMID
,T1.party_type_nm as PartyTypeName
,T1.employee_last_nm || ', ' || T1.employee_first_nm AS Employee
,T1.manager_last_nm || ', ' || T1.manager_first_nm AS Manager
,T2.short_dt AS "Date"
,T5.mtg_title as "Meeting Title"
,T5.Description
,T5.Duration
,T1.FTE AS FTE
,Case 
	When T2.is_holiday = 'false' then 0
	else 1
	end AS "IS_HOLIDAY"
,Case 
	When T2.is_weekday = 'false' then 0
	else 1
	end as IS_WEEKDAY
,T1.team_party_id AS TEAM_PARTY_ID
,T1.department_id AS DEPARTMENT_ID
--,T5.TransDt AS TRANS_DT
,Working_hours AS ScheduledHours
,AdminTime AS ADMIN_TIME
,ProdCredits AS PROD_CREDITS
,Count (*) Over (PARTITION BY short_dt, MMID) AS EE_Day_RowCnt
,Coalesce(ProdCredits,0) AS "Productivity Credits_Whole"
,Coalesce(actual_makeup_hrs,0) AS ACTUAL_MAKEUP_HRS
, CASE 
			WHEN (Coalesce (Sum(all_day_ooo) Over (PARTITION BY short_dt,MMID),0)) = 1 OR (ACTUAL_OOO_HRS >= ScheduledHours AND ScheduledHours <> 0) THEN 0
		    WHEN (ScheduledHours + ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN 0 
		    WHEN (is_holiday = 1 OR ScheduledHours = 0) AND (ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN  0
		    ELSE Coalesce(Cast (ProdCredits/(Count (*) Over (PARTITION BY short_dt, MMID)) AS DECIMAL (12,5)) ,0)/60
		    END AS  "Productivity Hours"
, CASE 
			WHEN (Coalesce (Sum(all_day_ooo) Over (PARTITION BY short_dt,MMID),0)) >= 1 OR (ACTUAL_OOO_HRS >= ScheduledHours AND ScheduledHours <> 0) THEN 0
		    WHEN (ScheduledHours + ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN 0 
		    WHEN (is_holiday = 1 OR ScheduledHours = 0) AND (ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN  0
		    ELSE Coalesce (actual_prod_hrs,0)
		    END AS  "Actual Production Hours"
,"Productivity Hours" + "Actual Production Hours" AS "Hours Productive"
,Coalesce (Sum(all_day_ooo) Over (PARTITION BY short_dt,MMID),0) AS "All_Day_OOO"
,Coalesce (Sum(actual_ot_hrs) Over (PARTITION BY short_dt,MMID),0) AS ACTUAL_OT_HRS
,Coalesce (Sum(actual_ooo_hrs) Over (PARTITION BY short_dt,MMID),0) AS ACTUAL_OOO_HRS
, CASE 
			WHEN (Coalesce (Sum(all_day_ooo) Over (PARTITION BY short_dt,MMID),0)) >= 1 OR (ACTUAL_OOO_HRS >= ScheduledHours AND ScheduledHours <> 0) THEN 0
		    WHEN (ScheduledHours + ACTUAL_OT_HRS +ACTUAL_MAKEUP_HRS) = 0 THEN 0 
		    WHEN (is_holiday = 1 OR ScheduledHours = 0) AND (ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN  0
		    ELSE Coalesce( actual_non_prod_hrs,0)
		    END AS  "Actual Non-Production Hrs"
, CASE 
			WHEN (Coalesce (Sum(all_day_ooo) Over (PARTITION BY short_dt,MMID),0))>= 1 OR (ACTUAL_OOO_HRS >= ScheduledHours AND ScheduledHours <> 0) THEN 'A'
		    WHEN (ScheduledHours + ACTUAL_OT_HRS+ ACTUAL_MAKEUP_HRS) = 0 THEN 'B'
		    WHEN (is_holiday = 1 OR ScheduledHours = 0) AND (ACTUAL_OT_HRS + ACTUAL_MAKEUP_HRS) = 0 THEN  'C'
		    ELSE 'D'
		    END AS  Test
,T5.time_type as TimeType
,actual_prod_hrs AS ACTUAL_PROD_HRS
FROM (SELECT * FROM dma_vw.dma_dim_employee_pit_vw T1 WHERE department_id IN (/*7,*/8)) AS T1
INNER JOIN  (SELECT short_dt, T2.day_of_week, Is_Holiday, Is_Weekday, /*HRID,*/ Working_hours, .250 as "AdminTime", begin_dt, party_employee_id
			FROM dma_vw.timeout_rel_schedule_vw T2
			INNER JOIN dma_vw.dma_dim_date_vw T3 ON T2.day_of_week = T3.day_of_week
			WHERE T3.short_dt BETWEEN begin_dt AND end_dt) AS T2
		    ON T1.party_employee_id = T2.party_employee_id AND T2.short_dt BETWEEN T1.begin_dt AND T1.end_dt
LEFT JOIN (SELECT party_employee_id   ----Get Cats data for production
			, completed_dt
			, Sum(prod_credit) AS ProdCredits
			FROM dma_vw.fact_integrated_lac_pit_vw
			WHERE trans_type_id = 3 AND completed_dt BETWEEN Add_Months(Current_Date, -12)
			AND Current_Date + INTERVAL '10' DAY
			GROUP BY 1,2) AS T4
			ON T1.party_employee_id = T4.party_employee_id AND T2.short_dt = T4.completed_dt
LEFT JOIN dma_vw.fact_timeout_activity_vw AS T5 
	 ON short_dt = T5.meeting_dt AND T1.party_employee_id = T5.party_employee_id  --Get time out data
WHERE short_dt BETWEEN (CASE WHEN T1.begin_dt < Current_Date - INTERVAL '36' MONTH
						THEN T2.begin_dt ELSE Add_Months(Current_Date, -36) END)
AND Current_Date + INTERVAL '10' DAY
AND T1.role_id IN (13,15,16,17,19,22) 
AND (ProdCredits IS NOT NULL OR Actual_Prod_Hrs IS NOT NULL)--reduces number of records returned.
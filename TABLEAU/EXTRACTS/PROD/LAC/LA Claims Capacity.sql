/*
FILENAME: LA CLAIMS CAPACITY
CREATED BY: Jay Johnson
LAST UPDATED: 6/1/2022
CHANGES MADE: Modifications to the source tables. Repointed to Vertica
**NOTES:
**This is a shared data source, used on Executive Forecast dashboard
*This runs as of 3-29-22 in Vertica Dev.  Runs on prod as of 5/5
*/

SELECT
CAST ('TimeOut' AS VARCHAR (50)) AS "TransactionTypeName"
, NULL AS ForecastID
, T2.MMID
, employee_last_nm || ', ' || employee_first_nm AS Employee
, CASE 
			WHEN T3.EE_EndDate = '9999-12-31' THEN 'Curr Employee'
            ELSE 'Termed Emplyee'
            END AS "Active Schedule Ident"
, manager_last_nm || ', ' || manager_first_nm AS Manager
, team_nm AS "Team Name"
, T2.role_id as RoleID
, T2.role_nm AS "Role Name"
, Trim(CASE 
		    WHEN T2.role_nm LIKE 'Life Claim%' THEN 'Life Claim Examiner'
		    WHEN T2.role_nm LIKE 'Life Pay%' THEN 'Life Pay'
		    ELSE T2.role_nm
		    END) AS "WorkRole" 
, EE_Startdate
, RoleStartDate
, EE_EndDate
, short_dt AS "Date"
,Case
	When is_holiday = True then 1
	When is_holiday = False then 0
	end as IsHoliday
--, is_holiday as IsHoliday
,Case
	When is_weekday = True then 1
	When is_weekday = False then 0
	end as IsWeekday
--, is_weekday as IsWeekday
, CASE 
            WHEN T2.role_nm LIKE ('%Consultant') THEN CAST(11 AS INTEGER)
            WHEN age_in_months(short_dt,RoleStartDate) >9 THEN CAST(10 AS INTEGER)
			ELSE Ceil(MONTHS_BETWEEN(Trunc(short_dt,'MON'),RoleStartDate))
			END AS Experience
, CASE 
            WHEN T2.role_nm LIKE ('%Consultant') THEN 'Consultant'
            WHEN age_in_months(short_dt,RoleStartDate)>9 THEN 'Experienced'
			ELSE  'New Hire'
			END AS EE_TYPE
, T4.Effective AS "%Effective"--,(Select Effective From dma_analytics.analytics_capacity_expc_lov WHERE (CASE WHEN T2.role_nm LIKE ('%Consultant') THEN CAST(11 AS INTEGER) WHEN age_in_months(short_dt,RoleStartDate) >9 THEN CAST(10 AS INTEGER) ELSE  age_in_months(short_dt,RoleStartDate) END)=Experiance) as Eff
, CAST(NULL AS FLOAT ) AS "EffectiveFTE"
, CAST(NULL AS FLOAT ) AS "ForecastEffectiveFTE_high95"
, CAST(NULL AS FLOAT ) AS "ForecastEffectiveFTE_high80"
, CAST(NULL AS FLOAT ) AS "ForecastEffectiveFTE_low80"
, CAST(NULL AS FLOAT ) AS "ForecastEffectiveFTE_low95"
, actual_flex_hrs AS "Actual Flex Hours"
, CASE 
			WHEN all_day_ooo >= 1 OR (planned_ooo_hrs >= working_hours AND working_hours <> 0) THEN working_hours 
		    ELSE planned_ooo_hrs
		    END AS "Planned OOO Hours"
, planned_ot_hrs AS "Planned OT Hours"
, planned_excused_hrs AS "Planned Excused Hours"
, actual_makeup_hrs AS "Planned Makeup Hours"
, COALESCE(prod_credit,0) AS "Productivity Credits"
, all_day_ooo AS "All Day OOO"
, working_hours AS "Working Hours"
, CASE
			WHEN all_day_ooo >= 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN  (working_hours)
		    WHEN (working_hours + actual_ot_hrs + actual_makeup_hrs) = 0 THEN 0 
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) = 0 THEN  0
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN  0
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) >= 6 THEN  0
		    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN  working_hours
		    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) >= 6 THEN  working_hours
		    ELSE working_hours
		    END AS "Actual Working Hrs"    
, CASE 
			WHEN all_day_ooo >= 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN  0
		    WHEN (working_hours + actual_ot_hrs + actual_makeup_hrs) = 0 THEN 0 
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) = 0 THEN  0
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN  actual_ot_hrs
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) >= 6 THEN  actual_ot_hrs
		    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN  actual_ot_hrs 
		    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) >= 6 THEN  actual_ot_hrs  
		    ELSE actual_ot_hrs
		    END AS "Actual OT Hrs"
, actual_ot_hrs as "ActualOTHours"
, CASE
			WHEN all_day_ooo >= 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN  0
		    WHEN (working_hours + actual_ot_hrs + actual_makeup_hrs) = 0 THEN 0 
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) = 0 THEN  0
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN   actual_makeup_hrs
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) >= 6 THEN   actual_makeup_hrs
		    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN  actual_makeup_hrs
		    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) >= 6 THEN  actual_makeup_hrs
		    ELSE  actual_makeup_hrs
		    END AS  "Actual Makeup Hrs" --New   
, actual_makeup_hrs as "ActualMakeupHours" 
, CASE 
			WHEN all_day_ooo >= 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN  0
		    WHEN (working_hours + actual_ot_hrs + actual_makeup_hrs) = 0 THEN 0 
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) = 0 THEN  0
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN  actual_excused_hrs
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) >= 6 THEN  actual_excused_hrs
		    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN actual_excused_hrs
		    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) >= 6 THEN actual_excused_hrs
		    ELSE actual_excused_hrs
		    END AS "Actual Excused Hrs" --New   
, actual_excused_hrs as "ActualExcusedHours"
, CASE 
			WHEN all_day_ooo >= 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN  (working_hours)
		    WHEN (working_hours + actual_ot_hrs + actual_makeup_hrs) = 0 THEN 0 
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) = 0 THEN  0
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN  (actual_ot_hrs + actual_makeup_hrs - actual_excused_hrs)   
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) >= 6 THEN  (actual_ot_hrs + actual_makeup_hrs - actual_excused_hrs)
		    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN  (working_hours + actual_ot_hrs + actual_makeup_hrs - actual_excused_hrs)
		    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) >= 6 THEN  (working_hours + actual_ot_hrs + actual_makeup_hrs - actual_excused_hrs) 
		    ELSE (working_hours + actual_ot_hrs + actual_makeup_hrs - actual_excused_hrs)
		    END AS "Actual Capacity" --New    		    		    
, CASE 
			WHEN all_day_ooo >= 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN working_hours 
		    ELSE actual_ooo_hrs
		    END AS "Actual OOO Hrs"  
, CASE 
			WHEN all_day_ooo >= 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN 0
		    WHEN (working_hours + actual_ot_hrs + actual_makeup_hrs) = 0 THEN 0 
		    WHEN (is_holiday = 1 OR working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) = 0 THEN  0
		    ELSE  actual_non_prod_hrs  --ActualNonWorkingHours confirm this is the correct replacement for this column
		    END AS "Actual Non-Production Hrs"		    
, CASE 
		WHEN all_day_ooo >= 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN ( "Actual OOO Hrs" )
	    WHEN (working_hours + actual_ot_hrs + actual_makeup_hrs) = 0 THEN 0 
	    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) = 0 THEN 0 -- "Actual OOO Hrs"
	    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN  ( "Actual Non-Production Hrs" + "Actual OOO Hrs")
	    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) >= 6 THEN  ( "Actual Non-Production Hrs" + "Actual OOO Hrs" + admin_time)
	    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN  ( "Actual Non-Production Hrs" + actual_ooo_hrs)
	    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) >= 6 THEN  ("Actual Non-Production Hrs" + actual_ooo_hrs+ admin_time)
	    ELSE ( "Actual Non-Production Hrs" +  actual_ooo_hrs+ admin_time)
	    END AS "Shrinkage Hrs" 		    
   , ("Actual Capacity" - "Shrinkage Hrs"  )* T4.Effective  AS "Effective Capacity"
, CAST(NULL AS INTEGER) AS "ForecastCapacity_high95"
, CAST(NULL AS INTEGER) AS "ForecastCapacity_high80"
, CAST(NULL AS INTEGER) AS "ForecastCapacity_low80"
, CAST(NULL AS INTEGER) AS "ForecastCapacity_low95" 
, ("Actual Capacity" - "Effective Capacity")-"Shrinkage Hrs" AS "Efficiency Loss"  
, CASE 
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) = 0 THEN  0
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN  0
		    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) >= 6 THEN  admin_time
		    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN  0
		    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) >= 6 THEN admin_time
		    WHEN all_day_ooo >= 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN 0
		    ELSE admin_time
		    END AS "Admin Time"
, actual_ooo_hrs as "ActualOOOHours"
, CAST (NULL AS FLOAT) AS "%Shrinkage"       
, CAST(NULL AS FLOAT) AS "ForecastShrinkage_high95"
, CAST(NULL AS FLOAT) AS "ForecastShrinkage_high80"
, CAST(NULL AS FLOAT) AS "ForecastShrinkage_low80"
, CAST(NULL AS FLOAT) AS "ForecastShrinkage_low95"
, CASE 
			WHEN all_day_ooo = 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN 0
		    WHEN (working_hours + actual_ot_hrs + actual_makeup_hrs) = 0 THEN 0 
		    WHEN (is_holiday = 1 OR working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) = 0 THEN  0
		    ELSE COALESCE(CAST("Productivity Credits" AS DECIMAL(12,5)),0) / 60 
		    END AS "Productivity Hours"  
, CASE 
			WHEN all_day_ooo = 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN 0
		    WHEN (working_hours + actual_ot_hrs + actual_makeup_hrs) = 0 THEN 0 
		    WHEN (is_holiday = 1 OR working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) = 0 THEN  0
		    ELSE actual_prod_hrs   -----ActualWorkingHours  confirm this is the right replacement column
		    END AS "Actual Production Hours"    		    
, "Productivity Hours" + "Actual Production Hours" AS "Hours Productive"
FROM dma_vw.fact_aggregated_performance_vw T1
JOIN dma_vw.dma_dim_employee_pit_vw T2 ON T1.team_party_id = T2.team_party_id
JOIN ( SELECT DISTINCT MMID
							,role_id
							,role_nm
							,MIN(CASE 
							                  WHEN EXTRACT(YEAR FROM begin_dt) = '1900' THEN hire_dt
				                               ELSE begin_dt
				                               END) OVER (PARTITION  BY MMID) AS EE_Startdate
							,MIN(CASE 
				                               WHEN EXTRACT(YEAR FROM begin_dt) = '1900' THEN hire_dt
				                               ELSE begin_dt
				                               END) OVER (PARTITION BY MMID,role_id) AS RoleStartDate
							,MAX(end_dt) OVER (PARTITION BY MMID) AS EE_EndDate
				FROM dma_vw.dma_dim_employee_pit_vw ) T3 ON T2.MMID = T3.MMID AND T2.role_id = T3.role_id
JOIN dma_analytics.Analytics_Capacity_Expc_LOV T4 ON --Experience = T4.Experiance
		CASE 
		 	WHEN T2.role_nm LIKE ('%Consultant') THEN 11
			WHEN age_in_months(short_dt,RoleStartDate) >9 THEN 10
			ELSE Ceil(MONTHS_BETWEEN(Trunc(short_dt,'MON'),RoleStartDate))
			END = T4.Experiance
AND T1.department_id IN (8)
AND T2.role_id IN (13,15,16,17,19,22) 
AND party_type_nm = 'EMPLOYEE'
UNION ALL
SELECT
CAST ('Forecast' AS VARCHAR (50)) AS "TransactionTypeName"
, T1.ForecastID
, CAST(NULL AS VARCHAR(50)) AS "MMID"
, CAST(NULL AS VARCHAR(100)) AS "Employee"
, CAST(NULL AS VARCHAR(100)) AS "Active Schedule Ident"
, CAST(NULL AS VARCHAR(100)) AS "Manager"
, CAST(NULL AS VARCHAR(100)) AS "Team Name"
, CAST(NULL AS INTEGER) AS "RoleID"
, CAST(NULL AS VARCHAR(100)) AS "Role Name"
, T1.WorkRole 
, CAST(NULL AS DATE) AS "EE_Startdate"
, CAST(NULL AS DATE) AS "RoleStartDate"
, CAST(NULL AS DATE) AS "EE_EndDate"
,T1.ForecastDate AS "Date" 
, CAST(NULL AS INTEGER) AS "IsHoliday"
, CAST(NULL AS INTEGER) AS "IsWeekday"
, CAST(NULL AS INTEGER) AS "Experience"
, CAST(NULL AS VARCHAR(100)) AS "EE_TYPE"
,CAST(NULL AS INTEGER) AS "%Effective"
, T1.ForecastEffectiveFTE "EffectiveFTE"
, T1.ForecastEffectiveFTE_high95
, T1.ForecastEffectiveFTE_high80
, T1.ForecastEffectiveFTE_low80
, T1.ForecastEffectiveFTE_low95
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
, CAST(NULL AS INTEGER) AS "ActualOTHours"
, CAST(NULL AS INTEGER) AS "Actual Makeup Hrs"
, CAST(NULL AS INTEGER) AS "ActualMakeupHours"
, CAST(NULL AS INTEGER) AS "Actual Excused Hrs"
, CAST(NULL AS INTEGER) AS "ActualExcusedHours" 
, CAST(NULL AS INTEGER) AS "Actual Capacity"
, CAST(NULL AS INTEGER) AS "Actual OOO Hrs" 
, CAST(NULL AS INTEGER) AS "Actual Non-Production Hrs"
, CAST(NULL AS INTEGER) AS "Shrinkage Hrs" 
, Round(T1.ForecastCapacity,2) AS "Effective Capacity"
, T1.ForecastCapacity_high95
, T1.ForecastCapacity_high80
, T1.ForecastCapacity_low80
, T1.ForecastCapacity_low95
, CAST(NULL AS INTEGER) AS "Efficiency Loss"   
, CAST(NULL AS INTEGER) AS "Admin Time"
, CAST(NULL AS INTEGER) AS "ActualOOOHours"
, T1.ForecastShrinkage AS "%Shrinkage"
, T1.ForecastShrinkage_high95
, T1.ForecastShrinkage_high80
, T1.ForecastShrinkage_low80
, T1.ForecastShrinkage_low95
, CAST(NULL AS INTEGER) AS "Productivity Hours"  
, CAST(NULL AS INTEGER) AS "Actual Production Hours"
, CAST(NULL AS INTEGER) AS "Hours Productive"
FROM dma_analytics.analytics_capacity_fx AS T1
INNER JOIN
(SELECT DISTINCT Department, ForecastDate ,MAX(ForecastID) OVER (PARTITION BY Department,ForecastDate) AS FxID 
FROM dma_analytics.analytics_capacity_fx
WHERE   EXTRACT(YEAR FROM ForecastDate) = EXTRACT (YEAR FROM CURRENT_DATE- INTERVAL '0' YEAR)
AND Department = 'Life Claims') AS T2
ON (ForecastID = FxID AND T1.ForecastDate = T2.ForecastDate AND T1.Department=T2.Department)
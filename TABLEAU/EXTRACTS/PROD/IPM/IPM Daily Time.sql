/*
FILENAME: IPM Daily Time
CREATED BY: Paul Gyasi
LAST UPDATED: 12/06/2022
CHANGES MADE: Vertica SQL Creation.
*/

SELECT T1.short_dt AS "Date"
, CAST(T1.is_holiday AS INT) AS IsHoliday
, CAST(T1.is_weekday AS INT) AS IsWeekday
, COALESCE(T2.employee_last_nm || ', ' || T2.employee_first_nm, 'Unknown') AS 'Employee'
, COALESCE(T2.manager_last_nm || ', ' || T2.manager_first_nm , 'Unknown') AS 'Manager'
, CASE WHEN T1.fte < 1 THEN 'Non_Production' ELSE 'Production' END AS "Employee Type"
, T2.team_nm AS "Team Name"
, T2.role_nm AS "Role Name"
, T2.role_grade_nm AS "Role Grade Name"
, T1.prod_goal AS "Prod Goal"
, T1.non_prod_goal AS "Non Prod Goal"
, T1.actual_flex_hrs AS "Actual Flex Hours"
, CASE WHEN all_day_ooo = 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN 0
    WHEN (working_hours + actual_ot_hrs + actual_makeup_hrs) = 0 THEN 0 
    WHEN (is_holiday = 1 OR working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) = 0 THEN  0
    ELSE actual_non_prod_hrs
  END AS "Actual Non-Production Hours"
, CASE WHEN all_day_ooo = 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN working_hours 
    ELSE actual_ooo_hrs
  END AS "Actual OOO Hours"
, actual_ot_hrs AS "Actual OT Hours"
, CASE WHEN all_day_ooo = 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN 0
    WHEN (working_hours + actual_ot_hrs + actual_makeup_hrs) = 0 THEN 0 
    WHEN (is_holiday = 1 OR working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) = 0 THEN  0
    ELSE actual_prod_hrs
  END AS "Actual Production Hours"
, T1.actual_excused_hrs AS "Actual Excused Hours"
, T1.actual_makeup_hrs AS "Actual Makeup Hours"
, T1.planned_flex_hrs AS "Planned Flex Hours"
, CASE WHEN all_day_ooo >= 1 OR (planned_ooo_hrs >= working_hours AND working_hours <> 0) THEN 0
    WHEN (working_hours + planned_ot_hrs + planned_makeup_hrs) = 0 THEN 0 
    WHEN (is_holiday = 1 OR working_hours = 0) AND (planned_ot_hrs + planned_makeup_hrs) = 0 THEN  0
    ELSE planned_non_prod_hrs
  END AS "Planned Non-Production Hours"
, CASE WHEN all_day_ooo >= 1 OR (planned_ooo_hrs >= working_hours AND working_hours <> 0) THEN working_hours 
   ELSE planned_ooo_hrs
  END AS "Planned OOO Hours"  
, T1.planned_ot_hrs AS "Planned OT Hours"
, CASE WHEN all_day_ooo >= 1 OR (planned_ooo_hrs >= working_hours AND working_hours <> 0) THEN 0
    WHEN (working_hours + planned_ot_hrs + planned_makeup_hrs) = 0 THEN 0 
    WHEN (is_holiday = 1 OR working_hours = 0) AND (planned_ot_hrs + planned_makeup_hrs) = 0 THEN  0
    ELSE planned_prod_hrs
  END AS "Planned Prod Hours"
, T1.planned_excused_hrs AS "Planned Excused Hours"
, T1.planned_makeup_hrs AS "Planned Makeup Hours"
, T1.working_hours AS "Working Hours"
, T1.admin_time AS "Admin Time"
, COALESCE(T1.prod_credit,0) AS "Productivity Credits"
, T1.all_day_ooo AS "All Day OOO" 
, CASE WHEN all_day_ooo = 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN 0
    WHEN (working_hours + actual_ot_hrs + actual_makeup_hrs) = 0 THEN 0 
    WHEN (is_holiday = 1 OR working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) = 0 THEN  0
    ELSE COALESCE(CAST("Productivity Credits" AS DECIMAL(12,5)),0) / 60 
  END AS "Productivity Hours"
, "Productivity Hours" + "Actual Production Hours" AS "Hours Productive"
, CASE WHEN all_day_ooo >= 1 OR (actual_ooo_hrs >= working_hours AND working_hours <> 0) THEN 0 
    WHEN (working_hours + actual_ot_hrs + actual_makeup_hrs) = 0 THEN 0 
    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) = 0 THEN  0
    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN  (actual_ot_hrs + actual_makeup_hrs - actual_excused_hrs - "Actual Non-Production Hours" - actual_ooo_hrs)
    WHEN (is_holiday = 1) AND (actual_ot_hrs + actual_makeup_hrs) > 6 THEN  (actual_ot_hrs + actual_makeup_hrs - actual_excused_hrs - "Actual Non-Production Hours" - actual_ooo_hrs - admin_time)
    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) < 6 THEN  (working_hours + actual_ot_hrs + actual_makeup_hrs - actual_excused_hrs - "Actual Non-Production Hours" - actual_ooo_hrs)
    WHEN (working_hours = 0) AND (actual_ot_hrs + actual_makeup_hrs) >= 6 THEN  (working_hours + actual_ot_hrs + actual_makeup_hrs - actual_excused_hrs - "Actual Non-Production Hours" - actual_ooo_hrs - admin_time)
    ELSE (working_hours + actual_ot_hrs + actual_makeup_hrs - actual_excused_hrs - "Actual Non-Production Hours" - actual_ooo_hrs - admin_time) 
  END AS "Available Time"
,CASE WHEN all_day_ooo >= 1 OR (planned_ooo_hrs >= working_hours AND working_hours <> 0) THEN 0 
    WHEN (working_hours + planned_ot_hrs + planned_makeup_hrs) = 0 THEN 0 
    WHEN (is_holiday = 1) AND (planned_ot_hrs + planned_makeup_hrs) = 0 THEN  0
    WHEN (is_holiday = 1) AND (planned_ot_hrs + planned_makeup_hrs) < 6 THEN  (planned_ot_hrs + planned_makeup_hrs - planned_excused_hrs - planned_non_prod_hrs - planned_ooo_hrs)
    WHEN (is_holiday = 1) AND (planned_ot_hrs + planned_makeup_hrs) > 6 THEN  (planned_ot_hrs + planned_makeup_hrs - planned_excused_hrs - planned_non_prod_hrs - planned_ooo_hrs - admin_time)
    WHEN (working_hours = 0) AND (planned_ot_hrs + planned_makeup_hrs) < 6 THEN  (working_hours + planned_ot_hrs + planned_makeup_hrs - planned_excused_hrs - planned_non_prod_hrs - planned_ooo_hrs)
    WHEN (working_hours = 0) AND (planned_ot_hrs + planned_makeup_hrs) >= 6 THEN  (working_hours + planned_ot_hrs + planned_makeup_hrs - planned_excused_hrs - planned_non_prod_hrs - planned_ooo_hrs - admin_time)
    ELSE (working_hours + planned_ot_hrs + planned_makeup_hrs - planned_excused_hrs - planned_non_prod_hrs - planned_ooo_hrs - admin_time) 
    END AS "Planned Available Time"
FROM dma_vw.fact_aggregated_performance_vw T1
LEFT JOIN dma.dma_dim_employee_pit T2 ON T1.team_party_id = T2.team_party_id
WHERE "Date" BETWEEN (Current_Date - INTERVAL '3' MONTH) AND (Current_Date + INTERVAL '10' DAY)
AND T1.department_id = 14
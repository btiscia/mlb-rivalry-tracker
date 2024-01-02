/*
Name: MMUS Operations TimeOut Analysis Aggregated
Author: Jess Madru
Last Updated: 11/20/2023
11/20/2023 - revised to separate aggregated daily time by employee to separate extract
**/

--returns the schedule by employee
WITH schedule_pit AS (
    SELECT row_process_dtm,
    t2.short_dt,
    t2.is_holiday,
    t2.is_weekday,
    t2.day_nm, 
    party_employee_id,
    mmid,
    working_hours
    FROM dma_vw.dma_dim_schedule_pit_vw t1
    LEFT JOIN dma_vw.dma_dim_date_vw t2 on t1.day_of_week = t2.day_of_week and t2.short_dt between t1.begin_dt and t1.end_dt
    where t2.short_dt between add_months(current_date,-24) and current_date - interval '1' day 
    ),
    
   --pulls time records just 'Time Capture Only' 
    time_details_tc AS (
    SELECT party_employee_id,
    mmid,
    meeting_dt,
    sum(actual_flex_hrs) as actual_flex_hrs,
    sum(actual_ooo_hrs) as actual_ooo_hrs, 
    sum(actual_ot_hrs) as actual_ot_hrs,
    sum(actual_excused_hrs) as actual_excused_hrs,
    sum(actual_makeup_hrs) as actual_makeup_hrs,
    sum(all_day_ooo) as all_day_ooo 
    
    FROM dma_vw.sem_fact_timeout_activity_history_vw
    WHERE time_type = 'Time Capture Only'
    and parent_time_category is not null
    and meeting_dt between add_months(current_date,-24) and current_date - interval '1' day 
    GROUP BY 1,2,3
    ),
    
    --pulls employee details
    employees AS (
    SELECT party_employee_id,
    begin_dt,
    end_dt, 
    fte,
    team_nm,
    role_nm,
    role_id,
    department_id,
    department_nm,
    coalesce(employee_last_nm || ', ' || employee_first_nm, 'Unknown') AS employee_nm, 
    coalesce(manager_last_nm || ', ' || manager_first_nm, 'Unknown') AS manager_nm
    
    FROM dma_vw.dma_dim_employee_pit_vw 
    )   
SELECT t1.row_process_dtm as "TransDt"
	, short_dt as "Date"
	, day_nm as "Day Name"
	, is_holiday
	, is_weekday
	, employee_nm as "Employee"
	, t4.party_employee_id as "Party Employee ID"
	, t4.mmid as "MMID"
	, t3.team_nm "Team Name"
	, t3.role_nm "Employee Role Name"
	, t3.role_id  AS "RoleID"
	, t3.department_id  AS "DepartmentID"
	, t3.department_nm AS "Department Name"
	, manager_nm as "Manager"
	, working_hours AS "Working Hours"
	, coalesce(actual_flex_hrs,0) "Actual Flex Hours"
	, coalesce(actual_ooo_hrs,0) "Actual OOO Hours"
	, coalesce(actual_ot_hrs,0) "Actual OT Hours"
	, coalesce(actual_excused_hrs,0) "Actual Excused Hours"
	, coalesce(actual_makeup_hrs,0) "Actual Makeup Hours"
	, coalesce(all_day_ooo,0) "All Day OOO"
	
FROM schedule_pit t1
JOIN time_details_tc t4 on t1.short_dt = t4.meeting_dt and t1.party_employee_id = t4.party_employee_id
JOIN employees t3 on t4.meeting_dt between t3.begin_dt and t3.end_dt and t4.party_employee_id = t3.party_employee_id
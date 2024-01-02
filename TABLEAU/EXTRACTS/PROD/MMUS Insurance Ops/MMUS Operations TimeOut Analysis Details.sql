/*
Name: MMUS Operations TimeOut Analysis Details
Author: Jess Madru
Last Updated: 11/20/2023
11/20/2023 - revised to include weekend and holiday time entries
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
    where t2.short_dt between add_months(current_date,-24) and current_date - interval '1' day --update to 24 months after testing
    ),
    
    --pulls time records excluding 'Time Capture Only' 
    time_details AS (
    SELECT party_employee_id,
    mmid,
    meeting_dt,
    time_type,
    parent_time_category,
    time_category,
    planned_actual,
    sum(actual_prod_hrs) as actual_prod_hrs,
    sum(actual_non_prod_hrs) as actual_non_prod_hrs,
    description

    FROM dma_vw.sem_fact_timeout_activity_history_vw
    WHERE time_type <> 'Time Capture Only'
    and parent_time_category is not null
    and meeting_dt between add_months(current_date,-24) and current_date - interval '1' day 
    GROUP BY 1,2,3,4,5,6,7,10
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
	, fte
	, case when fte < 1 then 'Non-Production'
            else 'Production' end as "Employee Type"
	, is_holiday
	, is_weekday
	, employee_nm as "Employee"
	, t2.party_employee_id "Party Employee ID"
	, t2.mmid as "MMID"
	, t3.team_nm "Team Name"
	, t3.role_nm "Employee Role Name"
	, t3.role_id  AS "RoleID"
	, t3.department_id  AS "DepartmentID"
	, t3.department_nm AS "Department Name"
	, manager_nm as "Manager"
	, working_hours AS "Working Hours"
	, time_type AS "Time Type"
	, parent_time_category AS "Category"
	, time_category AS "Time Category"
	, planned_actual AS "Planned Actual"
	, description AS "Meeting Description"
    , t5.goal_val AS "Non Prod Goal"
	, case when planned_actual = 'PLANNED-ACTUAL' then 'Planned'
		    when planned_actual = 'ACTUAL' then 'Unplanned' end as "Planned or Actual"
	, coalesce(actual_prod_hrs,0) "Prod Hours"
	, coalesce(actual_non_prod_hrs,0) "Non-Prod Hours"
	
FROM schedule_pit t1
JOIN time_details t2 on t1.short_dt = t2.meeting_dt and t1.party_employee_id = t2.party_employee_id
JOIN employees t3 on t2.meeting_dt between t3.begin_dt and t3.end_dt and t2.party_employee_id = t3.party_employee_id
LEFT JOIN dma_vw.dma_dim_goal_pit_vw t5 on t1.short_dt between t5.begin_dt and t5.end_dt and t5.department_id = t3.department_id and t5.role_id = t3.role_id and goal_type_id = 4
/*
This routine pulls TimeOut data for past 13 months 
Created: 6/15/2022 initial Vertica load -Kristin Carlile
Updated to include individuals with employee ID changes - Bill Trombley
10/20/2023: updated to go back 24 months rather than 13 months - Bill Tiscia
*/


select T1.row_process_dtm as "TransDt"
		, t2.short_dt as "Date"
	    , t2.day_nm as "Day Name"
	    , t3.fte
	    , case when t3.fte < 1 then 'Non-Production'
            else 'Production' end as "Employee Type"
	    , t2.is_holiday
	    , t2.is_weekday
	    , coalesce(t3.employee_last_nm || ', ' || t3.employee_first_nm, 'Unknown') AS Employee
	    , t3.team_nm "Team Name"
	    , t3.role_nm "Employee Role Name"
	    , t3.role_id  AS "RoleID"
	    , t3.department_id  AS "DepartmentID"
	    , t3.department_nm AS "Department Name"
	    , coalesce(t3.manager_last_nm || ', ' || t3.manager_first_nm, 'Unknown') AS Manager
	    , working_hours AS "Working Hours"
	    , time_type AS "Time Type"
	    , parent_time_category AS "Category"
	    , time_category AS "Time Category"
	    , planned_actual AS "Planned Actual"
		, t4.description AS "Meeting Description"
        , t5.goal_val AS "Non Prod Goal"
	    , case when planned_actual = 'PLANNED-ACTUAL' then 'Planned'
		    when planned_actual = 'ACTUAL' then 'Unplanned' end as "Planned or Actual"
	    , coalesce(sum(actual_flex_hrs),0) "Actual Flex Hours"
	    , coalesce(sum(actual_non_prod_hrs),0) "Non-Prod Hours"
	    , coalesce(sum(actual_ooo_hrs),0) "Actual OOO Hours"
	    , coalesce(sum(actual_ot_hrs),0) "Actual OT Hours"
	    , coalesce(sum(actual_prod_hrs),0) "Prod Hours"
	    , coalesce(sum(actual_excused_hrs),0) "Actual Excused Hours"
	    , coalesce(sum(actual_makeup_hrs),0) "Actual Makeup Hours"
	    , coalesce(sum(all_day_ooo),0) "All Day OOO"
	    , case when "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) then 0
		    when ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours") = 0 then 0
		    when (is_holiday = 1 OR "Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") = 0 then  0
		    else "Prod Hours" end as "Actual Production Hours"
	    ,case when "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) then 0
		    when ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours") = 0 then 0
		    when (is_holiday = 1 OR "Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") = 0 then  0
		    else "Non-Prod Hours"end as "Actual Non-Production Hours"
	    ,case when "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) then "Working Hours"
		    else "Actual OOO Hours" end as "Actual OOO Hrs"
from dma_vw.dma_dim_schedule_pit_vw t1
join dma_vw.dma_dim_date_vw t2 on t1.day_of_week = t2.day_of_week and t2.short_dt between t1.begin_dt and t1.end_dt
join dma_vw.dma_dim_employee_pit_vw t3 on t2.short_dt between t3.begin_dt and t3.end_dt and t1.party_employee_id = t3.party_employee_id
left join dma_vw.sem_fact_timeout_activity_history_vw t4 on t4.meeting_dt = t2.short_dt and t1.party_employee_id = t4.party_employee_id
left join dma_vw.dma_dim_goal_pit_vw t5 on t2.short_dt between t5.begin_dt and t5.end_dt and t5.department_id = t3.department_id and t5.role_id = t3.role_id and goal_type_id = 4
where t2.short_dt between add_months(current_date,-24) and current_date - interval '1' day
    and parent_time_category is not null
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22
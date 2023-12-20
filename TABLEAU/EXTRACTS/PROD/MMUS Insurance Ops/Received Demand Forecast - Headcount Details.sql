select
	distinct department_id as "Department Id"
	, department_nm
	, role_nm as "Role"
    , employee_first_nm as "Emp First Name"
	, employee_last_nm as "Emp Last Name"
	, MMID
	, team_nm as "Team Name"
	, manager_first_nm as "Mgr First Name"
	, manager_last_nm as "Mgr Last Name"
	, manager_mmid as "Mgr MMID"
	, effective_dt as "Effective Date"
	, termination_dt as "Termination Date"
	, active_ind as "Active Ind"
	, fte as FTE
	, to_rep_ind as "To Report Indicator"
	, fte_count as "FTE Count"
from
	dma_analytics.received_demand_forecast_headcount_details_vw
where
	department_id in (4, 5, 8, 7)
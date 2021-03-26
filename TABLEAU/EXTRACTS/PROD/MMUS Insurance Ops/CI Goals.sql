/* This is a MySQL query*/

select
  a.id as team_party_id
, a.team_id
, b.hours as goal_hours
, d.name as organization_nm
, e.name as department_nm
, f.name as team_nm
, c.owner_team_id
, 2021 as benefit_year
, case when sum(c.benefit_count)   is null then 0 else sum(c.benefit_count)   end as sum_benefit_count
, case when sum(c.benefit_dollars) is null then 0 else sum(c.benefit_dollars) end as sum_benefit_dollars
, case when sum(c.benefit_minutes) is null then 0 else sum(c.benefit_minutes) end as sum_benefit_minutes
, e.sum_total_benefit_dollars
, e.sum_total_benefit_minutes
, e.sum_total_benefit_minutes / 60 as sum_total_benefit_hours
from io_ci_opportunities.user_trees a
join io_ci_opportunities.goals b on a.id = b.user_tree_id and a.employee_id = -98
left outer join io_ci_opportunities.reporting_vw c on a.team_id = c.owner_team_id and c.current_status = 'complete' and year(c.status_date) = 2020
left outer join io_ci_opportunities.organizations d on a.organization_id = d.id
left outer join io_ci_opportunities.departments e on a.department_id = e.id
left outer join io_ci_opportunities.teams f on a.team_id = f.id
left outer join (select
                      owner_team_id
                    , sum(total_benefit_dollars) as sum_total_benefit_dollars
                    , sum(total_benefit_minutes) as sum_total_benefit_minutes
                    from
                    (select
                      owner_team_id
                    , (case when benefit_count is null then 0 else benefit_count end) * (case when benefit_dollars is null then 0 else benefit_dollars end) as total_benefit_dollars
                    , (case when benefit_count is null then 0 else benefit_count end) * (case when benefit_minutes is null then 0 else benefit_minutes end) as total_benefit_minutes
                    from io_ci_opportunities.reporting_vw
                    where current_status = 'complete' and year(status_date) = 2021) A
                    group by owner_team_id) e on a.team_id = e.owner_team_id
group by
  a.id
, a.team_id
, b.hours
, d.name
, e.name
, c.owner_team_id
, f.name
, b.hours
, e.sum_total_benefit_dollars
, e.sum_total_benefit_minutes
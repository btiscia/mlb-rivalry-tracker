/*
Name: CI Opportunities
Author/Editor: Bill Trombley
Last Updated: 03/08/2024
Updates: 
11/21/2022 - Data connection: iobi-auroramy-prd-kaizen.cluster-ckfbr84lggsy.us-east-1.rds.amazonaws.com
03/08/2024 - Data connection moved to Vertica - B. Tiscia
*/

select
  opportunities_id
, opportunities_title
, opportunities_description
, status_date
, current_status
, opportunities_effort
, opportunities_impact
, opportunities_created_by
, opportunities_updated_by
, benefits_opportunity_id
, owner_name
, owner_manager
, owner_manager_2
, owner_manager_3
, owner_team_nm
, owner_team_id
, owner_department_nm
, owner_organization_nm
, benefit_manager
, benefit_manager_2
, benefit_manager_3
, benefit_team_nm
, benefit_department_nm
, benefit_organization_nm
, benefit_type
, benefit_count
, benefit_minutes
, benefit_dollars
, goal_hours
, benefit_and_owner_same
from dma_vw.kaizen_reporting_vw
where current_status = 'complete'
/*  
FILENAME: VOC INTEGRATED VIEW
CREATED BY: Kristin Carlile
LAST UPDATED: 5/2/2022
CHANGES MADE: Vertica SQL Creation
CHANGES MADE: Additional fields added for the Annuity CES dash: product, product_category, agency_id, firm_nm, channel, logical_delete_ind=FALSE 10/11/2022 Modified by LC
*/

SELECT survey_id
, survey_number as "Survey Number"
, survey_alias as "Survey Alias"
, survey_nm as "Survey Name"
, survey_response_id as "Survey Response ID"
, survey_question_id as "Survey Question ID"
, survey_question_name as "Survey Question Name"
, survey_question_description as "Survey Question Description"
, survey_question_target as "Survey Question Target"
, survey_question_target_met as "Survey Question Target Met"
, survey_question_weight as "Survey Question Weight"
, survey_question_response as "Survey Question Response"
, survey_question_response_text as "Survey Question Response Text"
, metric_id as "Metric ID"
, metric_name as "Metric Name"
, response_date as "Response Date"
, lob_id as "LOB ID" 
, lob_name as "LOB Name"
, product
, product_category
, work_department_id as "Work Department ID"
, work_organization_nm as "Work Organization Name"
, department_nm as "Department Name"
, function_nm as "Function Name"
, segment_nm as "Segment Name"
, work_event_nm as "Work Event Name"
, primary_role_nm as "Primary Role Name"
, system_nm as "System Name"
, work_event_num as "Work Event Number"
, department_cd as "Department Code"
, division_cd as "Division Code"
, prod_credit as "Prod Credit"
, employee_organization_id as "Employee Organization ID"
, employee_team_id as "Employee Team ID"
, employee_department_id as "Employee Department ID"
, employee_organization_nm as "Employee Organization Name"
, employee_department_nm as "Employee Department Name"
, team_nm as "Team Name"
, role_nm as "Role Name"
, mmid as "MMID"
, employee_last_nm ||', ' || employee_first_nm as "Employee Name"
, manager_mmid as "Manager MMID"
, manager_last_nm || ', ' || manager_first_nm  as "Manager Name"
, agent_id as "Agent ID"
, agency_id as "Agency ID"
, firm_nm
, channel 
FROM dma_vw.fact_VOC_integrated_vw
WHERE logical_delete_ind=FALSE-- ***************** THIS FILTER is ANNUITY *** survey_id =6 and survey_question_id=20 and response_date between '2022-01-01' and '2022-08-31'/*)AS MAIN*/
ORDER BY survey_response_id
/*survey_response_id not in
('67f0641f-953d-a9f8-b02c-bd1b3cfe2849',
'add8c099-4545-2682-ca64-9d79ad56fb58',
'bfeaa0a6-1ee7-673b-5a19-93511ff24ab0',
'060946e2-a028-ef37-4604-6372bdf347fd',
'59bd4ff9-f184-b37c-ff05-8dd41e66a5f0',
'4979ab46-c02e-313e-bdf8-df543ab2ea65',
'572a0ce9-54d0-f63f-a3d9-d3b60075d514',
'b174e320-60b6-f751-684e-7b038c4f382c',
'd13231ac-6a92-5d2c-5776-b512333cf364',
'a9475a5e-b193-6953-47bf-7916a4c0c55d',
'3f65e7d8-d5a2-3571-96f1-77266cedcd46',
'01227761-f01e-9230-7a5e-5af7145bb65b',
'a29a4448-3086-9e07-e5c4-c087e53edc1d',
'c3e78d04-75e8-18bb-2654-a3938c8ad62b',
'42632554-9395-4010-8700-20b042e2c153'
,'5a94c295-c6f5-7b4c-6ff9-30279a978a70')*/
/*
FILENAME: LA Claims Actual and Forecast
CREATED BY: Jay Johnson
LAST UPDATED: 11/22/2021
CHANGES MADE: Modifications to the source tables.
--as of 4/13 does not run in Vertica Dev
--as of 5/3 first part of union runs on dev
--as of 5/4 second part runs
--as of 5/5 the last part runs. Union also now runs as whole also runs in prod
*/

SELECT
transaction_type_nm as TransactionTypeName
,NULL AS ForecastID
,source_transaction_id as SourceTransactionID
,agreement_nr as HoldingKey
, CASE
WHEN (T1.work_event_function_nm in (/*'Operations 1st Notice',*/ 'Life 1st Notice','Life Proofs', 'Life Complex', 'Bene Admin BAU', 'Life 2nd Exam', 'Life Other', 'Life Holds') OR (work_event_function_nm = 'Phone Claims' AND work_event_nm IN ('{LC} TC Live Claim Call', '{LC} TC OUTBOUND CLAIM', '{LC} Triage-Outbound Claim')) OR (work_event_function_nm = 'Life Follow Ups' AND work_event_segment_nm <> 'Life Follow Ups RM'))  THEN 'Life Claim Examiner'
WHEN work_event_function_nm LIKE 'Life Pay%' THEN 'Life Pay'
WHEN work_event_function_nm = 'Operations Setup' AND work_event_segment_nm = 'Life Setup' THEN 'Operations Setup'
WHEN work_event_function_nm LIKE 'Life Calc%' THEN 'Life Calc and Quotes'
END AS "Workrole"
,Date(TRUNC(received_dt,'MON')) AS "Date"
,employee_role_nm as EmployeeRoleName
,COALESCE(employee_last_nm|| ', ' || employee_first_nm, 'Unknown') AS "Employee"   
,COALESCE(employee_last_nm|| ', ' || manager_first_nm, 'Unkonwn') AS "Manager"
,employee_team_nm as TeamName
,work_event_function_nm as FunctionName
,CASE
WHEN work_event_function_nm = 'Operations Setup' AND work_event_segment_nm = 'Life Setup' THEN 'Operations Setup'
ELSE work_event_function_nm
END AS "WorkFunction"
,work_event_segment_nm as SegmentName
,work_event_nm as WorkEventName
,priority_nm as Priority   
,admn_sys_cde as AdminSystem   
,process_nm as ProcessName   
,process_id  as ProcessID
,process_order as ProcessOrder
,chnl_dspy_nm as ServiceChannelName
,party_type_nm as PartyTypeName
,employee_organization_nm as EmployeeOrganizationName
,employee_department_nm as EmployeeDepartmentName
,site_nm as SiteName
,work_event_organization_nm as WorkEventOranizationName
,work_event_department_nm as WorkEventDepartmentName
,work_event_primary_role_nm as PrimaryRoleName
,work_event_system_nm as SystemName
,work_event_num as WorkEventNumber
,department_cd as DepartmentCode
,division_cd as DivisionCode
,tat as TAT
,sht_cmnt_des as ShortComment
,CAST (NULL AS SMALLINT) AS ComplexityLevel
,MAX(row_process_dtm) AS "MaxTransDate"
,COUNT(DISTINCT fact_integrated_natural_key_hash_uuid)  AS "Volume"
,CASE 
WHEN "WorkFunction" = 'Operations 1st Notice' THEN SUM(28.50/60.00)
WHEN "WorkFunction" = 'Life Holds' THEN SUM(17.00/60.00)
ELSE SUM(current_prod_credit)/(60.00)
END AS "Demand"
,CAST (NULL AS INTEGER) AS ForecastVolume_high95
,CAST (NULL AS INTEGER) AS ForecastVolume_high80
,CAST (NULL AS INTEGER) AS ForecastVolume_low80
,CAST (NULL AS INTEGER) AS ForecastVolume_low95
,CAST (NULL AS INTEGER) AS ForecastDemand_high95
,CAST (NULL AS INTEGER) AS ForecastDemand_high80
,CAST (NULL AS INTEGER) AS ForecastDemand_low80
,CAST (NULL AS INTEGER) AS ForecastDemand_low95
FROM dma_vw.fact_integrated_lac_pit_vw T1
WHERE  (work_event_department_id IN (8)
OR employee_department_id IN (8))
AND trans_type_id = 1
--AND SequenceNumber = 1
AND admn_sys_cde <> 'PALLM'
AND employee_role_nm IS NOT NULL
AND EXTRACT(YEAR FROM received_dt) >= EXTRACT(YEAR FROM CURRENT_DATE)-5
AND "WorkRole" IN ('Life Claim Examiner', 'Operations Setup', 'Life Pay', 'Life Calc and Quotes')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34
UNION ALL
SELECT 
CAST ('Forecast' AS VARCHAR (50)) AS "TransactionTypeName"
,ForecastID
,NULL AS "SourceTransactionID" 
,CAST (NULL AS  VARCHAR (40)) AS "HoldingKey" 
,WorkRole
,T1.ForecastDate AS "Date"
,CAST (NULL AS VARCHAR (50)) AS "EmployeeRoleName"
,CAST (NULL AS VARCHAR (100))  AS "Employee" 
,CAST (NULL AS VARCHAR (100)) AS "Manager"
,CAST (NULL AS VARCHAR (100)) AS "TeamName"
,CAST(NULL  AS VARCHAR(50)) AS "FunctionName"  
,WorkFunction
,CAST (NULL AS VARCHAR (100)) AS "SegmentName"  
,CAST ('Forecast' AS VARCHAR (100)) AS "WorkEventName"   
,CAST (NULL AS VARCHAR (100)) AS "Priority"       
,CAST (NULL AS VARCHAR (100)) AS "AdminSystem"     
,CAST (NULL AS VARCHAR (100)) AS "ProcessName"   
,CAST(NULL AS INTEGER ) AS "ProcessID"  
,CAST(NULL AS INTEGER ) AS "ProcessOrder" 
,CAST(NULL AS VARCHAR (100)) AS "ServiceChannelName"   
,CAST(NULL AS VARCHAR (100)) AS "PartyTypeName"  
,CAST(NULL AS VARCHAR (100)) AS "EmployeeOrganizationName"  
,CAST(NULL AS VARCHAR (100)) AS "EmployeeDepartmentName" 
,CAST(NULL AS VARCHAR (100)) AS "SiteName"  
,CAST(NULL AS VARCHAR (100)) AS "WorkEventOranizationName"  
,CAST(NULL AS VARCHAR (100)) AS "WorkEventDepartmentName"  
,CAST(NULL AS VARCHAR (100)) AS "PrimaryRoleName"  
,CAST(NULL AS VARCHAR (100)) AS  "SystemName" 
,CAST(NULL AS INTEGER) AS  "WorkEventNumber" 
,CAST (NULL AS VARCHAR (2)) AS  "DepartmentCode" 
,CAST (NULL AS VARCHAR (2)) AS "DivisionCode" 
,CAST (NULL AS INTEGER) AS "TAT"
,CAST (NULL AS VARCHAR (50)) AS  "ShortComment" 
,ComplexityLevel
,CAST (NULL AS DATE) AS "MaxTransDate"
, ForecastVolume AS "Volume"
, ForecastDemand AS "Demand"
, ForecastVolume_high95
, ForecastVolume_high80
, ForecastVolume_low80
, ForecastVolume_low95
, ForecAStDemand_high95
, ForecAStDemand_high80
, ForecAStDemand_low80
, ForecAStDemand_low95
FROM dma_analytics.analytics_demand_fx AS T1
INNER JOIN
(SELECT DISTINCT Department, ForecastDate ,MAX(ForecastID) OVER (PARTITION BY Department,ForecastDate) AS FxID 
FROM dma_analytics.analytics_demand_fx
WHERE   EXTRACT(YEAR FROM ForecastDate) = EXTRACT (YEAR FROM CURRENT_DATE- INTERVAL '0' YEAR)
AND Department = 'Life Claims') AS T2
ON (T1.ForecastID = FxID AND T1.ForecastDate = T2.ForecastDate AND T1.Department=T2.Department)
UNION ALL
SELECT
CAST ('Received' AS VARCHAR (50)) AS "TransactionTypeName"
,NULL AS "ForecastID"
,NULL AS "SourceTransactionID" 
,CAST (NULL AS  VARCHAR (40)) AS "HoldingKey" 
,RoleName AS "WorkRole"
,Date(TRUNC(MeetingDate,'MON')) AS "Date"
,RoleName AS "EmployeeRoleName"
,COALESCE(EmployeeLAStName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"   
,COALESCE(ManagerlAStName || ', ' || ManagerFirstName, 'Unkonwn') AS "Manager"
,TeamName
,CAST(NULL  AS VARCHAR(50)) AS "FunctionName"  
,'Non-Recorded Production' AS "WorkFunction"
,CAST (NULL AS VARCHAR (100)) AS "SegmentName"  
,CAST (NULL AS VARCHAR (100)) AS "WorkEventName"   
,CAST (NULL AS VARCHAR (100)) AS "Priority"       
,CAST (NULL AS VARCHAR (100)) AS "AdminSystem"     
,CAST (NULL AS VARCHAR (100)) AS "ProcessName"   
,CAST(NULL AS INTEGER ) AS "ProcessID"  
,CAST(NULL AS INTEGER ) AS "ProcessOrder" 
,CAST(NULL AS VARCHAR (100)) AS "ServiceChannelName"   
,CAST('EMPLOYEE' AS VARCHAR (100)) AS "PartyTypeName"  
,OrganizationName AS "EmployeeOrganizationName"  
,DepartmentName AS "EmployeeDepartmentName" 
,CAST(NULL AS VARCHAR (100)) AS "SiteName"  
,CAST(NULL AS VARCHAR (100)) AS "WorkEventOranizationName"  
,CAST(NULL AS VARCHAR (100)) AS "WorkEventDepartmentName"  
,CAST(NULL AS VARCHAR (100)) AS "PrimaryRoleName"  
,CAST(NULL AS VARCHAR (100)) AS  "SystemName" 
,CAST(NULL AS INTEGER) AS  "WorkEventNumber" 
,CAST (NULL AS VARCHAR (2)) AS  "DepartmentCode" 
,CAST (NULL AS VARCHAR (2)) AS "DivisionCode" 
,CAST (NULL AS INTEGER) AS "TAT"
,CAST (NULL AS VARCHAR (50)) AS  "ShortComment" 
,CAST (NULL AS SMALLINT) AS ComplexityLevel
,CAST (NULL AS DATE) AS "MaxTransDate"
,CAST (NULL AS INTEGER) AS "Volume"
,Duration AS "Demand"
,CAST (NULL AS INTEGER) AS ForecastVolume_high95
,CAST (NULL AS INTEGER) AS ForecastVolume_high80
,CAST (NULL AS INTEGER) AS ForecastVolume_low80
,CAST (NULL AS INTEGER) AS ForecastVolume_low95
,CAST (NULL AS INTEGER) AS ForecastDemand_high95
,CAST (NULL AS INTEGER) AS ForecastDemand_high80
,CAST (NULL AS INTEGER) AS ForecastDemand_low80
,CAST (NULL AS INTEGER) AS ForecastDemand_low95
FROM (
SELECT
 role_nm as RoleName
,TRUNC(meeting_dt,'MON') AS "MeetingDate"
,employee_first_nm as EmployeeFirstName
,employee_last_nm as EmployeeLastName
,manager_first_nm as ManagerFirstName
,manager_last_nm as ManagerLastName
,team_nm as TeamName
,organization_nm as OrganizationName  
,department_nm as DepartmentName
,CASE
WHEN (IsHoliday = 1) THEN 0
WHEN (IsWeekday = 0) THEN 0
WHEN all_day = True THEN 0
ELSE Duration  
END AS "Duration"
FROM dma_vw.sem_timeout_activity_history_vw A
LEFT JOIN (
SELECT
	short_dt, --as shortShortDate,
	Case when is_holiday =TRUE then 1 else 0 end as IsHoliday,
	case when is_weekday = TRUE then 1 else 0 end as IsWeekday
FROM  dma_vw.dma_dim_date_vw) B
ON B.short_dt = TRUNC(meeting_dt,'MON')
WHERE department_id = 8 
AND time_type = 'Production'
AND parent_time_category = 'Non-Recorded Production'
AND EXTRACT(YEAR FROM meeting_dt) >= EXTRACT(YEAR FROM CURRENT_DATE)-5
AND role_nm IN ('Life Claim Examiner', 'Operations Setup', 'Life Pay', 'Life Calc and Quotes')) C
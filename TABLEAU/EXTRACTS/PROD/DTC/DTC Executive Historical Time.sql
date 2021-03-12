/* This routine provides Historical Time for Executive Dashboard
*  Peer Review & Change Log:  
*  Peer Review Date: 
*  Source for this routine is PROD_DMA_VW.TIME_ACTIVITY_CURR_IVW; PROD_DMA_VW.GOAL_DIM_VW; PROD_DMA_VW.SCHEDULE_VW;
*										PROD_DMA_VW.EMPLOYEE_CURR_DIM_VW; PROD_DMA_VW.DATE_DIM_VW; PROD_DMA_VW.ACTIVITY_FCT_VW; 
*										PROD_DMA_VW.WORK_EVENT_CURR_DIM_VW*
*  Author: David Washburn
*  Created: 11/14/2017
*  Revised:  7/19/2018
*  Revision Made:  7/19/2018 - Department ID changed from 5 (LPI) to 20 (RMM) and Department Name.  Revision made by Lorraine Christian.
*/



SELECT
"Date"
,IsHoliday
,IsWeekday
,Employee
,CASE 
	WHEN FTE < 1 THEN 'Non-Production'
	ELSE 'Production'
END AS "Employee Type"
,Manager
,"Team Name"
,"Role Name"
,(SELECT GoalValue FROM PROD_DMA_VW.GOAL_DIM_VW WHERE EndDate = '9999-12-31' AND DepartmentID = 20 AND GoalTypeID = 3 AND RoleName = UnionSubB."Role Name") AS "Prod Goal"
,(SELECT GoalValue FROM PROD_DMA_VW.GOAL_DIM_VW WHERE EndDate = '9999-12-31' AND DepartmentID = 20 AND GoalTypeID = 4 AND RoleName = UnionSubB."Role Name") AS "Non Prod Goal"
,"Actual Flex Hours"
,CASE
	WHEN "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0
	WHEN ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours") = 0 THEN 0 
	WHEN (IsHoliday = 1 OR "Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") = 0 THEN  0
	ELSE "Actual Non-Prod Hours"
END AS "Actual Non-Production Hours"
,CASE 
	WHEN "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN "Working Hours" 
	ELSE "Actual OOO Hours"
END AS "Actual OOO Hours"
,"Actual OT Hours"
,CASE
	WHEN "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0
	WHEN ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours") = 0 THEN 0 
	WHEN (IsHoliday = 1 OR "Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") = 0 THEN  0
	ELSE "Actual Prod Hours"
END AS "Actual Production Hours"
,"Actual Excused Hours"
,"Actual Makeup Hours"
,"Planned Flex Hours"
,CASE
	WHEN "All Day OOO" >= 1 OR ("Planned OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0
	WHEN ("Working Hours" + "Planned OT Hours" + "Planned Makeup Hours") = 0 THEN 0 
	WHEN (IsHoliday = 1 OR "Working Hours" = 0) AND ("Planned OT Hours" + "Planned Makeup Hours") = 0 THEN  0
	ELSE "Planned Non-Production Hours"
END AS "Planned Non-Production Hours"
,CASE 
	WHEN "All Day OOO" >= 1 OR ("Planned OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN "Working Hours" 
	ELSE "Planned OOO Hours"
END AS "Planned OOO Hours"
,"Planned OT Hours"
,CASE
	WHEN "All Day OOO" >= 1 OR ("Planned OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0
	WHEN ("Working Hours" + "Planned OT Hours" + "Planned Makeup Hours") = 0 THEN 0 
	WHEN (IsHoliday = 1 OR "Working Hours" = 0) AND ("Planned OT Hours" + "Planned Makeup Hours") = 0 THEN  0
	ELSE "Planned Prod Hours"
END AS "Planned Prod Hours"
,"Planned Excused Hours"
,"Planned Makeup Hours"
,"Working Hours"
,"Productivity Credits"
,"All Day OOO"
,CASE
	WHEN "All Day OOO" = 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0
	WHEN ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours") = 0 THEN 0 
	WHEN (IsHoliday = 1 OR "Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") = 0 THEN  0
	ELSE CAST("Productivity Credits" AS DECIMAL(12,5)) / 60 
END AS "Productivity Hours"
,"Productivity Hours" + "Actual Production Hours" AS "Hours Productive"
,CASE
	WHEN "All Day OOO" >= 1 OR ("Actual OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0 
	WHEN ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours") = 0 THEN 0 
	WHEN (IsHoliday = 1) AND ("Actual OT Hours" + "Actual Makeup Hours") = 0 THEN  0
	WHEN (IsHoliday = 1) AND ("Actual OT Hours" + "Actual Makeup Hours") < 6 THEN  ("Actual OT Hours" + "Actual Makeup Hours" - "Actual Excused Hours" - "Actual Non-Production Hours" - "Actual OOO Hours")
	WHEN (IsHoliday = 1) AND ("Actual OT Hours" + "Actual Makeup Hours") > 6 THEN  ("Actual OT Hours" + "Actual Makeup Hours" - "Actual Excused Hours" - "Actual Non-Production Hours" - "Actual OOO Hours" - .25)
	WHEN ("Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") < 6 THEN  ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours" - "Actual Excused Hours" - "Actual Non-Production Hours" - "Actual OOO Hours")
	WHEN ("Working Hours" = 0) AND ("Actual OT Hours" + "Actual Makeup Hours") >= 6 THEN  ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours" - "Actual Excused Hours" - "Actual Non-Production Hours" - "Actual OOO Hours" - .25)
	ELSE ("Working Hours" + "Actual OT Hours" + "Actual Makeup Hours" - "Actual Excused Hours" - "Actual Non-Production Hours" - "Actual OOO Hours" - .25) 
END AS "Available Time"
,CASE
	WHEN "All Day OOO" >= 1 OR ("Planned OOO Hours" >= "Working Hours" AND "Working Hours" <> 0) THEN 0 
	WHEN ("Working Hours" + "Planned OT Hours" + "Planned Makeup Hours") = 0 THEN 0 
	WHEN (IsHoliday = 1) AND ("Planned OT Hours" + "Planned Makeup Hours") = 0 THEN  0
	WHEN (IsHoliday = 1) AND ("Planned OT Hours" + "Planned Makeup Hours") < 6 THEN  ("Planned OT Hours" + "Planned Makeup Hours" - "Planned Excused Hours" - "Planned Non-Production Hours" - "Planned OOO Hours")
	WHEN (IsHoliday = 1) AND ("Planned OT Hours" + "Planned Makeup Hours") > 6 THEN  ("Planned OT Hours" + "Planned Makeup Hours" - "Planned Excused Hours" - "Planned Non-Production Hours" - "Planned OOO Hours" - .25)
	WHEN ("Working Hours" = 0) AND ("Planned OT Hours" + "Planned Makeup Hours") < 6 THEN  ("Working Hours" + "Planned OT Hours" + "Planned Makeup Hours" - "Planned Excused Hours" - "Planned Non-Production Hours" - "Planned OOO Hours")
	WHEN ("Working Hours" = 0) AND ("Planned OT Hours" + "Planned Makeup Hours") >= 6 THEN  ("Working Hours" + "Planned OT Hours" + "Planned Makeup Hours" - "Planned Excused Hours" - "Planned Non-Production Hours" - "Planned OOO Hours" - .25)
	ELSE ("Working Hours" + "Planned OT Hours" + "Planned Makeup Hours" - "Planned Excused Hours" - "Planned Non-Production Hours" - "Planned OOO Hours" - .25) 
END AS "Planned Available Time"
FROM
(SELECT
"Date"
,IsHoliday
,IsWeekday
,Employee
,Manager
,"Team Name"
,"Role Name"
,COALESCE(SUM(CASE WHEN "Meeting Type" = 'Flex Time' AND "Planned Or Actual" IN ('PLANNED-ACTUAL','ACTUAL') THEN "Meeting Length" END), 0) AS "Actual Flex Hours"
,COALESCE(SUM(CASE WHEN "Time Type" = 'Non-Production' AND "Planned Or Actual" IN ('PLANNED-ACTUAL','ACTUAL') THEN "Meeting Length" END), 0) AS "Actual Non-Prod Hours"
,COALESCE(SUM(CASE WHEN "Meeting Type" = 'Out of Office' AND "Planned Or Actual" IN ('PLANNED-ACTUAL','ACTUAL') THEN "Meeting Length" END), 0) AS "Actual OOO Hours"
,COALESCE(SUM(CASE WHEN "Meeting Type" = 'Additional Time' AND "Planned Or Actual" IN ('PLANNED-ACTUAL','ACTUAL') THEN "Meeting Length" END), 0) AS "Actual OT Hours"
,COALESCE(SUM(CASE WHEN "Time Type" = 'Production' AND "Planned Or Actual" IN ('PLANNED-ACTUAL','ACTUAL') THEN "Meeting Length" END), 0) AS "Actual Prod Hours"
,COALESCE(SUM(CASE WHEN "Meeting Type" = 'Flex Time' AND "Planned Or Actual" IN ('PLANNED-ACTUAL','PLANNED') THEN "Meeting Length" END), 0) AS "Planned Flex Hours"
,COALESCE(SUM(CASE WHEN "Time Type" = 'Non-Production' AND "Planned Or Actual" IN ('PLANNED-ACTUAL','PLANNED') THEN "Meeting Length" END), 0) AS "Planned Non-Production Hours"
,COALESCE(SUM(CASE WHEN "Meeting Type" = 'Out of Office' AND "Planned Or Actual" IN ('PLANNED-ACTUAL','PLANNED') THEN "Meeting Length" END), 0) AS "Planned OOO Hours"
,COALESCE(SUM(CASE WHEN "Meeting Type" = 'Additional Time' AND "Planned Or Actual" IN ('PLANNED-ACTUAL','PLANNED') THEN "Meeting Length" END), 0) AS "Planned OT Hours"
,COALESCE(SUM(CASE WHEN "Time Type" = 'Production' AND "Planned Or Actual" IN ('PLANNED-ACTUAL','PLANNED') THEN "Meeting Length" END), 0) AS "Planned Prod Hours"
,COALESCE(SUM(CASE WHEN "Meeting Type" = 'Excused Time' AND  "Planned Or Actual" IN ('PLANNED-ACTUAL','PLANNED') THEN "Meeting Length" END), 0) AS "Planned Excused Hours"
,COALESCE(SUM(CASE WHEN "Meeting Type" = 'Excused Time' AND "Planned Or Actual" IN ('PLANNED-ACTUAL','ACTUAL') THEN "Meeting Length" END), 0) AS "Actual Excused Hours"
,COALESCE(SUM(CASE WHEN "Meeting Type" = 'Makeup Time' AND  "Planned Or Actual" IN ('PLANNED-ACTUAL','ACTUAL') THEN "Meeting Length" END), 0) AS "Actual Makeup Hours"
,COALESCE(SUM(CASE WHEN "Meeting Type" = 'Makeup Time' AND "Planned Or Actual" IN ('PLANNED-ACTUAL','PLANNED') THEN "Meeting Length" END), 0) AS "Planned Makeup Hours"
,COALESCE(SUM(CASE WHEN "Time Type" = 'Working Hours' THEN "Meeting Length" END), 0) AS "Working Hours"
,COALESCE(SUM(CASE WHEN "Meeting Type" = 'Out of Office' THEN AllDay ELSE 0 END), 0) AS "All Day OOO"
,SUM(FTE) AS FTE
,COALESCE(SUM("Productivity Credits"), 0) AS "Productivity Credits"
FROM
(SELECT 
MeetingDt AS "Date"
,TimeType AS "Time Type"
,PlannedActual AS "Planned Or Actual"
,MeetingTitle AS "Meeting Type"
,Description AS "Meeting Description"
,NULL AS FTE
,COALESCE(EmpLastName|| ', ' || EmpFirstName, 'Unknown') AS Employee
,TeamName AS "Team Name"
,RoleName AS "Role Name"
,COALESCE(ManagerLastName || ', ' || ManagerFirstName, 'Unknown') AS Manager
,COALESCE(OwnerLastName || ', ' || OwnerFirstName, 'Unknown') AS "Meeting Owner"
,Duration AS "Meeting Length"
,AllDay 
,NULL AS "Productivity Credits"
FROM PROD_DMA_VW.TIME_ACTIVITY_CURR_IVW
WHERE DepartmentName= 'Retiree Middle Market'
AND "Date" BETWEEN ADD_MONTHS(CURRENT_DATE, -36) AND CURRENT_DATE + INTERVAL '10' DAY 

UNION ALL

SELECT
ShortDate
,'Working Hours' AS "Time Type"
,'Working Hours' AS "Planned Or Actual"
,'Working Hours' AS "Meeting Type"
,'Working Hours' AS "Meeting Description"
,FTE
,COALESCE(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS Employee
,TeamName
,RoleName
,COALESCE(ManagerLastName || ', ' || ManagerFirstName, 'Unknown') AS Manager
,CAST(NULL AS VARCHAR(10))
,WorkingHours
,NULL
,ProdCredits AS "Productivity Hours"
FROM PROD_DMA_VW.SCHEDULE_VW S
INNER JOIN PROD_DMA_VW.EMPLOYEE_CURR_DIM_VW E
ON S.MMID = E.MMID
LEFT JOIN PROD_DMA_VW.DATE_DIM_VW DD
ON S.DayOfWeek = DD.DayOfWeek
LEFT JOIN 
(SELECT PartyEmployeeID, CompletedDate, SUM(WE.ProductivityCredit) AS ProdCredits
FROM  PROD_DMA_VW.ACTIVITY_FCT_VW  AF
LEFT JOIN PROD_DMA_VW.WORK_EVENT_CURR_DIM_VW WE
ON AF.WorkEventID = WE.WorkEventID
WHERE CompletedIndicator = 1
AND CompletedDate BETWEEN ADD_MONTHS(CURRENT_DATE, -36) AND CURRENT_DATE + INTERVAL '10' DAY
GROUP BY 1,2) AF
ON E.PartyEmployeeID = AF.PartyEmployeeID
AND DD.ShortDate = AF.CompletedDate
WHERE DepartmentID = 20
AND E.EndDate = '9999-12-31'
AND ShortDate BETWEEN ADD_MONTHS(CURRENT_DATE, -36) AND CURRENT_DATE + INTERVAL '10' DAY
AND S.EndDt = '9999-12-31'
AND E.DepartmentID = 20) UnionSubA
LEFT JOIN PROD_DMA_VW.DATE_DIM_VW
ON "Date" = ShortDate
GROUP BY 1,2,3,4,5,6,7) UnionSubB
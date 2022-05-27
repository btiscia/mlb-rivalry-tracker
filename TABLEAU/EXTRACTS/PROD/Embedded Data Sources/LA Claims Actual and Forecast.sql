/*
FILENAME: LA Claims Actual and Forecast
CREATED BY: Jay Johnson
LAST UPDATED: 11/22/2021
CHANGES MADE: Modifications to the source tables.
*/

SELECT
TransactionTypeName
,NULL AS ForecastID
,SourceTransactionID
,HoldingKey
, CASE
WHEN (FunctionName IN('Operations 1st Notice', 'Life Proofs', 'Life Complex', 'Bene Admin BAU', 'Life 2nd Exam', 'Life Other', 'Life Holds') OR (FunctionName = 'Phone Claims' AND WorkEventName IN ('{LC} TC Live Claim Call', '{LC} TC OUTBOUND CLAIM', '{LC} Triage-Outbound Claim')) OR (FunctionName = 'Life Follow Ups' AND SegmentName <> 'Life Follow Ups RM'))  THEN 'Life Claim Examiner'
WHEN FunctionName LIKE 'Life Pay%' THEN 'Life Pay'
WHEN FunctionName = 'Operations Setup' AND SegmentName = 'Life Setup' THEN 'Operations Setup'
WHEN FunctionName LIKE 'Life Calc%' THEN 'Life Calc and Quotes'
END AS "Workrole"
,Trunc(ReceivedDate,'MON') AS "Date"
,EmployeeRoleName
,Coalesce(EmployeeLAStName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"   
,Coalesce(ManagerlAStName || ', ' || ManagerFirstName, 'Unkonwn') AS "Manager"
,TeamName
,FunctionName
,CASE
WHEN FunctionName = 'Operations Setup' AND SegmentName = 'Life Setup' THEN 'Operations Setup'
ELSE FunctionName
END AS "WorkFunction"
,SegmentName
,WorkEventName
,Priority   
,AdminSystem   
,ProcessName   
,ProcessID
,ProcessOrder
,ServiceChannelName
,PartyTypeName
,EmployeeOrganizationName
,EmployeeDepartmentName
,SiteName
,WorkEventOranizationName
,WorkEventDepartmentName
,PrimaryRoleName
,SystemName
,WorkEventNumber
,DepartmentCode
,DivisionCode
,TAT
,ShortComment
,Cast (NULL AS SMALLINT) AS ComplexityLevel
,Max(TransDate) AS "MaxTransDate"
,Count(DISTINCT IntegratedActivityID)  AS "Volume"
,CASE 
WHEN "WorkFunction" = 'Operations 1st Notice' THEN Sum(28.50/60.00)
WHEN "WorkFunction" = 'Life Holds' THEN Sum(17.00/60.00)
ELSE Sum(CurrentProdCredit)/(60.00)
END AS "Demand"
,Cast (NULL AS INTEGER) AS ForecastVolume_high95
,Cast (NULL AS INTEGER) AS ForecastVolume_high80
,Cast (NULL AS INTEGER) AS ForecastVolume_low80
,Cast (NULL AS INTEGER) AS ForecastVolume_low95
,Cast (NULL AS INTEGER) AS ForecastDemand_high95
,Cast (NULL AS INTEGER) AS ForecastDemand_high80
,Cast (NULL AS INTEGER) AS ForecastDemand_low80
,Cast (NULL AS INTEGER) AS ForecastDemand_low95
FROM PROD_DMA_VW.ACT_LAC_PIT_INTEGRATED_VW T1
WHERE  (WorkEventDepartmentID IN (8)
OR DepartmentID IN (8))
AND TransactionTypeID = 1
AND SequenceNumber = 1
AND AdminSystem <> 'PALLM'
AND EmployeeRoleName IS NOT NULL
AND Extract(YEAR From ReceivedDate) >= Extract(YEAR From Current_Date)-5
AND "WorkRole" IN ('Life Claim Examiner', 'Operations Setup', 'Life Pay', 'Life Calc and Quotes')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34

UNION ALL

SELECT 
Cast ('Forecast' AS VARCHAR (50)) AS "TransactionTypeName"
,ForecastID
,NULL AS "SourceTransactionID" 
,Cast (NULL AS  VARCHAR (40)) AS "HoldingKey" 
,WorkRole
,T1.ForecastDate AS "Date"
,Cast (NULL AS VARCHAR (50)) AS "EmployeeRoleName"
,Cast (NULL AS VARCHAR (100))  AS "Employee" 
,Cast (NULL AS VARCHAR (100)) AS "Manager"
,Cast (NULL AS VARCHAR (100)) AS "TeamName"
,Cast(NULL  AS VARCHAR(50)) AS "FunctionName"  
,WorkFunction
,Cast (NULL AS VARCHAR (100)) AS "SegmentName"  
,Cast ('Forecast' AS VARCHAR (100)) AS "WorkEventName"   
,Cast (NULL AS VARCHAR (100)) AS "Priority"       
,Cast (NULL AS VARCHAR (100)) AS "AdminSystem"     
,Cast (NULL AS VARCHAR (100)) AS "ProcessName"   
,Cast(NULL AS INTEGER ) AS "ProcessID"  
,Cast(NULL AS INTEGER ) AS "ProcessOrder" 
,Cast(NULL AS VARCHAR (100)) AS "ServiceChannelName"   
,Cast(NULL AS VARCHAR (100)) AS "PartyTypeName"  
,Cast(NULL AS VARCHAR (100)) AS "EmployeeOrganizationName"  
,Cast(NULL AS VARCHAR (100)) AS "EmployeeDepartmentName" 
,Cast(NULL AS VARCHAR (100)) AS "SiteName"  
,Cast(NULL AS VARCHAR (100)) AS "WorkEventOranizationName"  
,Cast(NULL AS VARCHAR (100)) AS "WorkEventDepartmentName"  
,Cast(NULL AS VARCHAR (100)) AS "PrimaryRoleName"  
,Cast(NULL AS VARCHAR (100)) AS  "SystemName" 
,Cast(NULL AS INTEGER) AS  "WorkEventNumber" 
,Cast (NULL AS VARCHAR (2)) AS  "DepartmentCode" 
,Cast (NULL AS VARCHAR (2)) AS "DivisionCode" 
,Cast (NULL AS INTEGER) AS "TAT"
,Cast (NULL AS VARCHAR (50)) AS  "ShortComment" 
,ComplexityLevel
,Cast (NULL AS DATE) AS "MaxTransDate"
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
FROM DMA_GRP_DL.Analytics_DemandFx AS T1
INNER JOIN

(SELECT DISTINCT Department, ForecastDate ,Max(ForecastID) Over (PARTITION BY Department,ForecastDate) AS FxID 
FROM DMA_GRP_DL.Analytics_DemandFx
WHERE   Extract(YEAR From ForecastDate) = Extract (YEAR From Current_Date- INTERVAL '0' YEAR)
AND Department = 'Life Claims') AS T2
ON (T1.ForecastID = FxID AND T1.ForecastDate = T2.ForecastDate AND T1.Department=T2.Department)

UNION ALL

SELECT
Cast ('Received' AS VARCHAR (50)) AS "TransactionTypeName"
,NULL AS "ForecastID"
,NULL AS "SourceTransactionID" 
,Cast (NULL AS  VARCHAR (40)) AS "HoldingKey" 
,RoleName AS "WorkRole"
,Trunc(MeetingDate,'MON') AS "Date"
,RoleName AS "EmployeeRoleName"
,Coalesce(EmployeeLAStName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"   
,Coalesce(ManagerlAStName || ', ' || ManagerFirstName, 'Unkonwn') AS "Manager"
,TeamName
,Cast(NULL  AS VARCHAR(50)) AS "FunctionName"  
,'Non-Recorded Production' AS "WorkFunction"
,Cast (NULL AS VARCHAR (100)) AS "SegmentName"  
,Cast (NULL AS VARCHAR (100)) AS "WorkEventName"   
,Cast (NULL AS VARCHAR (100)) AS "Priority"       
,Cast (NULL AS VARCHAR (100)) AS "AdminSystem"     
,Cast (NULL AS VARCHAR (100)) AS "ProcessName"   
,Cast(NULL AS INTEGER ) AS "ProcessID"  
,Cast(NULL AS INTEGER ) AS "ProcessOrder" 
,Cast(NULL AS VARCHAR (100)) AS "ServiceChannelName"   
,Cast('EMPLOYEE' AS VARCHAR (100)) AS "PartyTypeName"  
,OrganizationName AS "EmployeeOrganizationName"  
,DepartmentName AS "EmployeeDepartmentName" 
,Cast(NULL AS VARCHAR (100)) AS "SiteName"  
,Cast(NULL AS VARCHAR (100)) AS "WorkEventOranizationName"  
,Cast(NULL AS VARCHAR (100)) AS "WorkEventDepartmentName"  
,Cast(NULL AS VARCHAR (100)) AS "PrimaryRoleName"  
,Cast(NULL AS VARCHAR (100)) AS  "SystemName" 
,Cast(NULL AS INTEGER) AS  "WorkEventNumber" 
,Cast (NULL AS VARCHAR (2)) AS  "DepartmentCode" 
,Cast (NULL AS VARCHAR (2)) AS "DivisionCode" 
,Cast (NULL AS INTEGER) AS "TAT"
,Cast (NULL AS VARCHAR (50)) AS  "ShortComment" 
,Cast (NULL AS SMALLINT) AS ComplexityLevel
,Cast (NULL AS DATE) AS "MaxTransDate"
,Cast (NULL AS INTEGER) AS "Volume"
,Duration AS "Demand"
,Cast (NULL AS INTEGER) AS ForecastVolume_high95
,Cast (NULL AS INTEGER) AS ForecastVolume_high80
,Cast (NULL AS INTEGER) AS ForecastVolume_low80
,Cast (NULL AS INTEGER) AS ForecastVolume_low95
,Cast (NULL AS INTEGER) AS ForecastDemand_high95
,Cast (NULL AS INTEGER) AS ForecastDemand_high80
,Cast (NULL AS INTEGER) AS ForecastDemand_low80
,Cast (NULL AS INTEGER) AS ForecastDemand_low95
FROM (
SELECT
 RoleName
,Trunc(MeetingDate,'MON') AS "MeetingDate"
,EmployeeFirstName
,EmployeeLastName
,ManagerFirstName
,ManagerLastName
,TeamName
,OrganizationName  
,DepartmentName
,CASE
WHEN (IsHoliday = 1) THEN 0
WHEN (IsWeekday = 0) THEN 0
WHEN AllDayOOO >= 1 THEN 0
ELSE Duration 
END AS "Duration"
FROM PROD_DMA_VW.TIMEOUT_ACTIVITY_PIT_IVW A
LEFT JOIN (
SELECT
	ShortDate,
	IsHoliday,
	IsWeekday
FROM  PROD_DMA_VW.DATE_DIM_VW) B
ON B.ShortDate=A.MeetingDate
WHERE DepartmentID = 8
AND TimeType = 'Production'
AND ParentTimeCategory = 'Non-Recorded Production'
AND Extract(YEAR From MeetingDate) >= Extract(YEAR From Current_Date)-5
AND RoleName IN ('Life Claim Examiner', 'Operations Setup', 'Life Pay', 'Life Calc and Quotes')) C

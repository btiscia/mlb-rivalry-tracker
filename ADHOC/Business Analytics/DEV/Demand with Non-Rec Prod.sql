SELECT
TransactionTypeName
,Null AS ForecastID
,SourceTransactionID
,HoldingKey
, CASE
WHEN (FunctionName IN('Operations 1st Notice', 'Life Proofs', 'Life Complex', 'Bene Admin BAU', 'Life 2nd Exam', 'Life Other', 'Life Holds') OR (FunctionName = 'Phone Claims' AND WorkEventName IN ('{LC} TC Live Claim Call', '{LC} TC OUTBOUND CLAIM', '{LC} Triage-Outbound Claim')) OR (FunctionName = 'Life Follow Ups' AND SegmentName <> 'Life Follow Ups RM'))  THEN 'Life Claim Examiner'
WHEN FunctionName LIKE 'Life Pay%' THEN 'Life Pay'
WHEN FunctionName = 'Operations Setup' AND SegmentName = 'Life Setup' THEN 'Operations Setup'
END AS "Workrole"
,TRUNC(ReceivedDate,'MON') AS "Date"
,EmployeeRoleName
,COALESCE(EmployeeLAStName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"   
,COALESCE(ManagerlAStName || ', ' || ManagerFirstName, 'Unkonwn') AS "Manager"
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
,CAST (Null AS SmallInt) AS ComplexityLevel
,MAX(TransDate) AS "MaxTransDate"
,COUNT(distinct IntegratedActivityID)  AS "Volume"
,CASE 
WHEN "WorkFunction" = 'Operations 1st Notice' THEN SUM(28.50/60.00)
WHEN "WorkFunction" = 'Life Holds' THEN SUM(17.00/60.00)
ELSE SUM(CurrentProdCredit)/(60.00)
END AS "Demand"
,CAST (NULL AS INTEGER) AS ForecastVolume_high95
,CAST (NULL AS INTEGER) AS ForecastVolume_high80
,CAST (NULL AS INTEGER) AS ForecastVolume_low80
,CAST (NULL AS INTEGER) AS ForecastVolume_low95
,CAST (NULL AS INTEGER) AS ForecastDemand_high95
,CAST (NULL AS INTEGER) AS ForecastDemand_high80
,CAST (NULL AS INTEGER) AS ForecastDemand_low80
,CAST (NULL AS INTEGER) AS ForecastDemand_low95
FROM PROD_DMA_VW.ACT_LAC_PIT_INTEGRATED_VW T1
WHERE  (WorkEventDepartmentID IN (8)
OR DepartmentID IN (8))
AND TransactionTypeID = 1
AND SequenceNumber = 1
AND AdminSystem <> 'PALLM'
AND EmployeeRoleName IS NOT NULL
AND EXTRACT(YEAR FROM ReceivedDate) >= EXTRACT(YEAR FROM CURRENT_DATE)-5
AND "WorkRole" IN ('Life Claim Examiner', 'Operations Setup', 'Life Pay', 'Life Calc and Quotes')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34

UNION ALL

SELECT 
CAST ('Forecast' AS VARCHAR (50)) AS "TransactionTypeName"
,ForecastID
,NULL AS "SourceTransactionID" 
,CAST (NULL AS  VARCHAR (40)) AS "HoldingKey" 
,WorkRole
,"ForecastDate" AS "Date"
,CAST (NULL AS Varchar (50)) AS "EmployeeRoleName"
,CAST (NULL AS Varchar (100))  AS "Employee" 
,CAST (NULL AS Varchar (100)) AS "Manager"
,CAST (NULL AS Varchar (100)) AS "TeamName"
,CAST(NULL  AS Varchar(50)) AS "FunctionName"  
,WorkFunction
,CAST (NULL AS Varchar (100)) AS "SegmentName"  
,CAST ('Forecast' AS Varchar (100)) AS "WorkEventName"   
,CAST (NULL AS Varchar (100)) AS "Priority"       
,CAST (NULL AS Varchar (100)) AS "AdminSystem"     
,CAST (NULL AS Varchar (100)) AS "ProcessName"   
,CAST(NULL AS Integer ) AS "ProcessID"  
,CAST(NULL AS Integer ) AS "ProcessOrder" 
,CAST(NULL AS Varchar (100)) AS "ServiceChannelName"   
,CAST(NULL AS Varchar (100)) AS "PartyTypeName"  
,CAST(NULL AS Varchar (100)) AS "EmployeeOrganizationName"  
,CAST(NULL AS Varchar (100)) AS "EmployeeDepartmentName" 
,CAST(NULL AS Varchar (100)) AS "SiteName"  
,CAST(NULL AS Varchar (100)) AS "WorkEventOranizationName"  
,CAST(NULL AS Varchar (100)) AS "WorkEventDepartmentName"  
,CAST(NULL AS Varchar (100)) AS "PrimaryRoleName"  
,CAST(NULL AS Varchar (100)) AS  "SystemName" 
,CAST(NULL AS Integer) AS  "WorkEventNumber" 
,CAST (NULL AS Varchar (2)) AS  "DepartmentCode" 
,CAST (NULL AS Varchar (2)) AS "DivisionCode" 
,CAST (NULL AS integer) AS "TAT"
,CAST (NULL AS Varchar (50)) AS  "ShortComment" 
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
From DMA_GRP_DL.RT20_00002983_LC_Forecast_New
INNER JOIN
(SELECT MAX(ForecastID) AS FxID 
FROM DMA_GRP_DL.RT20_00002983_LC_Forecast_New) D2
ON ForecastID = FxID

UNION ALL

SELECT
CAST ('Received' AS VARCHAR (50)) AS "TransactionTypeName"
,NULL AS "ForecastID"
,NULL AS "SourceTransactionID" 
,CAST (NULL AS  VARCHAR (40)) AS "HoldingKey" 
,RoleName as "WorkRole"
,TRUNC(MeetingDate,'MON') AS "Date"
,RoleName AS "EmployeeRoleName"
,COALESCE(EmployeeLAStName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"   
,COALESCE(ManagerlAStName || ', ' || ManagerFirstName, 'Unkonwn') AS "Manager"
,TeamName
,CAST(NULL  AS Varchar(50)) AS "FunctionName"  
,'Non-Recorded Production' AS "WorkFunction"
,CAST (NULL AS Varchar (100)) AS "SegmentName"  
,CAST (NULL AS Varchar (100)) AS "WorkEventName"   
,CAST (NULL AS Varchar (100)) AS "Priority"       
,CAST (NULL AS Varchar (100)) AS "AdminSystem"     
,CAST (NULL AS Varchar (100)) AS "ProcessName"   
,CAST(NULL AS Integer ) AS "ProcessID"  
,CAST(NULL AS Integer ) AS "ProcessOrder" 
,CAST(NULL AS Varchar (100)) AS "ServiceChannelName"   
,CAST('EMPLOYEE' AS Varchar (100)) AS "PartyTypeName"  
,OrganizationName AS "EmployeeOrganizationName"  
,DepartmentName AS "EmployeeDepartmentName" 
,CAST(NULL AS Varchar (100)) AS "SiteName"  
,CAST(NULL AS Varchar (100)) AS "WorkEventOranizationName"  
,CAST(NULL AS Varchar (100)) AS "WorkEventDepartmentName"  
,CAST(NULL AS Varchar (100)) AS "PrimaryRoleName"  
,CAST(NULL AS Varchar (100)) AS  "SystemName" 
,CAST(NULL AS Integer) AS  "WorkEventNumber" 
,CAST (NULL AS Varchar (2)) AS  "DepartmentCode" 
,CAST (NULL AS Varchar (2)) AS "DivisionCode" 
,CAST (NULL AS integer) AS "TAT"
,CAST (NULL AS Varchar (50)) AS  "ShortComment" 
,CAST (Null AS SmallInt) AS ComplexityLevel
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
FROM PROD_DMA_VW.TIMEOUT_ACTIVITY_PIT_IVW
WHERE DepartmentID = 8
AND TimeType = 'Production'
AND ParentTimeCategory = 'Non-Recorded Production'
AND EXTRACT(YEAR FROM MeetingDate) >= EXTRACT(YEAR FROM CURRENT_DATE)-5
AND "WorkRole" IN ('Life Claim Examiner', 'Operations Setup', 'Life Pay', 'Life Calc and Quotes')
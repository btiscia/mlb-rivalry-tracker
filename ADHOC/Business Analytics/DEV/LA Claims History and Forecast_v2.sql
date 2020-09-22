

SELECT 
TransactionTypeName
,Null AS ForecastID
,SourceTransactionID  
,HoldingKey
, CASe 
when FunctionName ='Operations 1st Notice' Then 'Life Claim Examiner'
When SegmentName = 'Life Setup' and FunctionName = 'Operations Setup'  then 'Operations Setup'
End AS "Workrole" 
,TRUNC(ReceivedDate,'MON') AS "Date"
,EmployeeRoleName
,coalesce(EmployeeLAStName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"    
,coalesce(ManagerlAStName || ', ' || ManagerFirstName, 'Unkonwn') AS "Manager"
,TeamName
,FunctionName 
,CASe 
When SegmentName = 'Life Setup' and FunctionName = 'Operations Setup'  then 'Operations Setup'
Else FunctionName 
End AS "WorkFunction" 
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
,CASt (Null AS SmallInt) AS ComplexityLevel
,MAX(TransDate) AS "MaxTransDate"
,COUNT(distinct IntegratedActivityID)  AS "Volume"
,SUM(CurrentProdCredit) /60 AS "Demand" 

,CAST (NULL as Integer) as  ForecastVolume_high95
,CAST (NULL as Integer) as  ForecastVolume_high80
,CAST (NULL as Integer) as  ForecastVolume_low80
,CAST (NULL as Integer) as  ForecastVolume_low95
,CAST (NULL as Integer) as  ForecAStDemand_high95
,CAST (NULL as Integer) as  ForecAStDemand_high80
,CAST (NULL as Integer) as  ForecAStDemand_low80
,CAST (NULL as Integer) as  ForecAStDemand_low95

FROM PROD_DMA_VW.ACT_LAC_PIT_INTEGRATED_VW T1
WHERE  (WorkEventDepartmentID in (8)
OR DepartmentID in (8))
AND TransactionTypeID = 1
AND SequenceNumber = 1
AND AdminSystem <> 'PALLM'
AND EXTRACT(YEAR FROM ReceivedDate) >= EXTRACT(YEAR FROM CURRENT_DATE)-5
AND (FunctionName in('Operations 1st Notice') OR  ( FunctionName = 'Operations Setup' AND SegmentName = 'Life Setup'))
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34

UNION ALL

Select 
CAST ('Forecast' AS VARCHAR (50)) AS "TransactionTypeName"
,ForecastID
,NULL AS SourceTransactionID 
,CAST (NULL AS  VARCHAR (40))  HOLDINGKEY 
,WorkRole
,"ForecastDate" AS "Date"
,CAST (NULL AS Varchar (50)) AS EmployeeRoleName
,CAST (NULL AS Varchar (100))  AS "Employee" 
,CAST (NULL AS Varchar (100)) AS "Manager"
,CAST (NULL AS Varchar (100)) AS TeamName
,CAST(NULL  AS Varchar(50)) AS "FunctionName"  
,WorkFunction
,CAST (NULL AS Varchar (100)) AS SegmentName  
,CAST ('Forecast' AS Varchar (100)) AS WorkEventName   
,CAST (NULL AS Varchar (100)) AS Priority       
,CAST (NULL AS Varchar (100)) AS AdminSystem     
,CAST (NULL AS Varchar (100)) AS ProcessName   
,CAST(NULL AS Integer ) AS ProcessID  
,CAST(NULL AS Integer ) AS ProcessOrder 
,CAST(NULL AS Varchar (100)) AS ServiceChannelName   
,CAST(NULL AS Varchar (100)) AS PartyTypeName  
,CAST(NULL AS Varchar (100)) AS EmployeeOrganizationName  
,CAST(NULL AS Varchar (100)) AS EmployeeDepartmentName 
,CAST(NULL AS Varchar (100)) AS SiteName  
,CAST(NULL AS Varchar (100)) AS WorkEventOranizationName  
,CAST(NULL AS Varchar (100)) AS WorkEventDepartmentName  
,CAST(NULL AS Varchar (100)) AS PrimaryRoleName  
,CAST(NULL AS Varchar (100)) AS  SystemName 
,CAST(NULL AS Integer) AS  WorkEventNumber 
,CAST (NULL AS Varchar (2)) AS  DepartmentCode 
,CAST (NULL AS Varchar (2)) AS  DivisionCode 
,CAST (NULL AS integer) AS TAT
,CAST (NULL AS Varchar (50)) AS  ShortComment 
,ComplexityLevel
,CAST (NULL AS DATE) AS    "MaxTransDate"
, ForecAStVolume AS Volume
, ForecAStDemand AS Demand
, ForecastVolume_high95
, ForecastVolume_high80
, ForecastVolume_low80
, ForecastVolume_low95
, ForecAStDemand_high95
, ForecAStDemand_high80
, ForecAStDemand_low80
, ForecAStDemand_low95
From DMA_GRP_DL.RT20_00002983_LC_Forecast_Flat
where ForecastID = (Select Max(ForecastID) as ForecastID From DMA_GRP_DL.RT20_00002983_LC_Forecast_Flat)



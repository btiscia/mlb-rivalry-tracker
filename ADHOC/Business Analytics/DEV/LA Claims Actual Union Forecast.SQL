

SELECT 
Null as ForecastID
,SourceTransactionID  
,HoldingKey
,'Actual' as "Metric"
, Case 
when SegmentName like ('Life 1st Notice%') Then 'Life 1st Notice' 
When SegmentName = 'Life Setup' then 'Setup'
End as "Transaction Type" 
,TRUNC(ReceivedDate,'MON') as "Date"
,EmployeeRoleName
,Cast (Null as char (50))as "Role"
,coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') as "Employee"    
,coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unkonwn') as "Manager"
,TeamName
,FunctionName as "Function"
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
,Cast (Null as SmallInt) as ComplexityLevel
,MAX(TransDate) as "MaxTransDate"
,COUNT(distinct HoldingKey)  as "Measure"
,SUM(CurrentProdCredit) as "ProductivityCredits" 

FROM PROD_DMA_VW.ACT_LAC_PIT_INTEGRATED_VW
WHERE  (WorkEventDepartmentID in (8)
OR DepartmentID in (8))
AND SequenceNumber = 1
AND AdminSystem <> 'PALLM'
AND EXTRACT(YEAR FROM ReceivedDate) >= EXTRACT(YEAR FROM CURRENT_DATE)-5
AND (FunctionName in('Operations 1st Notice', 'Life 1st Notice') OR  ( FunctionName = 'Operations Setup' AND SegmentName = 'Life Setup'))
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33


UNION All 

Select 
ForecastID
,Null as SourceTransactionID 
,CAST (Null as  VARCHAR (40))  HOLDINGKEY 
,Metric--
,'Forecast'  as "Transaction Type" 
,"Date"
,Cast (Null as Varchar (50)) as EmployeeRoleName
,"Role"
,cast (Null as Varchar (100))  as "Employee" 
,Cast (Null As Varchar (100)) as "Manager"
,Cast (Null As Varchar (100)) as TeamName
,cast("Function" as Varchar(50)) as "Function"
,Cast (Null As Varchar (100)) as SegmentName  
,Cast (Null As Varchar (100)) as WorkEventName   
,Cast (Null As Varchar (100)) as Priority       
,Cast (Null As Varchar (100)) as AdminSystem     
,Cast (Null As Varchar (100)) as ProcessName   
,Cast(Null AS Integer ) as ProcessID  
,Cast(Null AS Integer ) as ProcessOrder 
,Cast(Null As Varchar (100)) as ServiceChannelName   
,Cast(Null As Varchar (100)) as PartyTypeName  
,Cast(Null As Varchar (100)) as EmployeeOrganizationName  
,Cast(Null As Varchar (100)) as EmployeeDepartmentName 
,Cast(Null As Varchar (100)) as SiteName  
,Cast(Null As Varchar (100)) as WorkEventOranizationName  
,Cast(Null As Varchar (100)) as WorkEventDepartmentName  
,Cast(Null As Varchar (100)) as PrimaryRoleName  
,Cast(Null As Varchar (100)) as  SystemName 
,Cast(Null as Integer) as  WorkEventNumber 
,Cast (Null as Varchar (2)) as  DepartmentCode 
,CAst (Null as Varchar (2)) as  DivisionCode 
,CAST (Null as integer) as TAT
,Cast (Null as Varchar (50)) as  ShortComment 
,ComplexityLevel
,Cast (Null as DATE) as    "MaxTransDate"
,Measure as  Measure 
--,Sum (T1.Measure)  as  Measure 
,Null as "ProductivityCredits"
/*
ForecastID
,Metric
,Role
,"Function"
,"Date"
,Null as "Example"
,Sum(Measure) as "Measure"
*/

From
   (Select
    ForecastID
   ,Metric
  ,"Role"
   ,"Function"
  ,ComplexityLevel
 ,"Date"
  ,Measure
From DMA_GRP_DL.RT20_00002983_LC_Forecast) T1
--Group by 
--ForecastID
--,Metric
--,"Role"
--,"Function"
--,"Date"



--Select Count(*) From T 
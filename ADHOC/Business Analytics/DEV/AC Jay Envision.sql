
With T As (
SELECT
'Received' AS "Transaction Type"
,systemDivisionname AS "Line of Business"
,ReceivedDate
,WorkEventOranizationName
,WorkEventDepartmentName
,WorkEventDepartmentID
,DepartmentID
,T1.SourceTransactionID-- AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,ReceivedDate AS "Date"
,EmployeeRoleName AS "Employee Role Name"
,COALESCE(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"
,COALESCE(ManagerlastName || ', ' || ManagerFirstName, 'Unkonwn') AS "Manager"
,TeamName
,FunctionName AS "Function Name"
,SegmentName AS "Segment Name"
,WorkEventName AS "Work Event Name"
,Priority
,AdminSystem AS "Admin System"
,ProcessName "Process Name"
,ProcessID AS "Process ID"
,ProcessOrder
,ServiceChannelName
,PartyTypeName
,EmployeeOrganizationName AS "Employee Organization Name"
,EmployeeDepartmentName AS "Employee Department Name"
,SiteName AS "Site Name"
/*,WorkEventOranizationName
,WorkEventDepartmentName*/
,PrimaryRoleName
,SystemName
,WorkEventNumber
,DepartmentCode
,DivisionCode
--,TAT
,ShortComment
,CurrentProdCredit

 ,LOB_NME
 ,LOB_CDE
 ,Major_Prod_NME as "Contract Type"
,Minor_Prod_NME
,Prod_TYP_NME
 ,ISSUE_DT
 

--,MAX(TransDate)
,COUNT(DISTINCT ActivityID) AS "Transaction Count"
,SUM(CurrentProdCredit) AS "Productivity Credits"
FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW T1

Left Join (
			Select
            SOURCETRANSACTIONID
            ,AGREEMENTID
            --,MAX(SEQUENCENUMBER) AS MAXSEQ
        
        FROM PROD_DMA_VW.ACT_LAC_CURR_INTEGRATED_VW
        
        WHERE WorkEventDepartmentID in (7)
              -- AND WorkEventName LIKE '{LC} CLAIM EXAM%'
              -- AND RoleID='22' --Role = Operations Setup 
               -- AND AdminSystem IN ('CM2000','MPR','VUL','PE1', 'LIFCOM', 'LVRGVL', 'OPM', 'UNIV', 'VNT', 'VNTAGE', 'VNTG1')
        
        GROUP BY 1,2
    ) AS LAC ON T1.SOURCETRANSACTIONID=LAC.SOURCETRANSACTIONID
--LEFT OUTER JOIN (SELECT GoalValue, DepartmentID, FunctionID FROM PROD_DMA_VW.GOAL_DIM_VW WHERE EndDate = '9999-12-31' AND GoalTypeID = 5) T2 --added 4/16/20
--ON T1.FunctionID = T2.FunctionID AND T1.DepartmentID = T2.DepartmentID --added 4/16/20
LEFT JOIN
        (
                SELECT
                        ACV.AGREEMENT_ID,
                        ACV.HLDG_KEY,
                        ACV.AGREEMENT_SOURCE_CD, 
                        ACV.ISSUE_DT,
                        ACV.FACE_AMOUNT,
                      --  ACV.CONV_IND,
                       -- ACV.REINS_IND,
                        CASE 
                            WHEN ACV.HLDG_STUS='TM' THEN 'Terminated'
                            WHEN ACV.HLDG_STUS='IF' THEN 'Inforce'
                            WHEN ACV.HLDG_STUS='NB' THEN 'NewBusiness'
                            WHEN ACV.HLDG_STUS='NR' THEN 'NotRecorded'
                            ELSE  'Unknown' END AS PolicyStatus,
                        ACV.LOB_NME,
                        ACV.LOB_CDE,
                        ACV.CTRT_JURISDICTION,
                         ACV.TERM_DT,
                        --MAX(CDV.GOVT_ID_NR) AS InsuredGovtID          
                        ACV.Distribution_Channel,
                        ACV.SRC_Distribution_Channel,
                        ACV.Major_Prod_NME,
                        ACV.Minor_Prod_NME,
                        ACV.Prod_TYP_NME,
                        ACV.Admn_SYS_CDE                      
                   FROM PROD_USIG_STND_VW.AGMT_CMN_VW AS ACV
                where Issue_DT between '1990-01-01' and  '2021-12-31'
        ) AS InforceData ON     InforceData.HLDG_KEY = T1.HoldingKey and InforceData.Agreement_ID = T1.AgreementID
     
 
WHERE  (WorkEventDepartmentID in (7,8)
OR DepartmentID  IN (7,8))
AND SequenceNumber = 1
And ReceivedDate Between '2017-01-01' and '2020-12-31'
And FunctionName in ('Annuity 2nd Exam','Annuity Approval','Annuity Check Audit','Annuity Death Payout','Annuity First Notice','Annuity Hold','Annuity Other','Annuity Phone Calls','Annuity Proofs','Annuity Proofs - Approvals','Income Settlement Claims','Income Settlement')
--And LOB_CDE = 'ANN' 
--OR LOB_CDE is null
--And ("Line of Business" = 'Annuities'OR "Department code" <> 'LC' or "Function Name" = 'Income Settlement')
--AND "Date" >= CURRENT_DATE - INTERVAL '5' YEAR
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40--,41,42,43
)

Select Distinct
"Function Name"
,"Segment Name"
,"Work Event Name"
,"Contract Type"
,Min("Productivity Credits")
,Max("Productivity Credits")
-- ,"Transaction Count"
,Coalesce (CAST(Sum(Case when Extract (YEAR FROM ReceivedDate) = '2017' Then "Transaction Count" End)AS REAL),0) as "2017 Total"
,Coalesce (CAST(Sum(Case when Extract (YEAR FROM ReceivedDate) = '2018' Then "Transaction Count" End)AS REAL),0) as "2018 Total"
,Coalesce(CAST(Sum(Case when Extract (YEAR FROM ReceivedDate) = '2019' Then "Transaction Count" End)AS REAL),0) as "2019 Total"
,Coalesce(CAST(Sum(Case when Extract (YEAR FROM ReceivedDate) = '2020' Then "Transaction Count" End)AS REAL),0) as "2020 Total"
,CAST (Sum("Transaction Count") AS REAL) as "4Yr Total"
--,CAST(Sum(Case when Extract (YEAR FROM ReceivedDate) in ('2018','2019','2020') Then "Transaction Count" End)AS REAL) as  "2018-2020 Total"
--,Coalesce( "2018 Total" / "2017 Total",0) as "2018_Growth"
--,Coalesce("2019 Total" / "2018 Total",0)  as "2019_Growth"
--,Coalesce("2020 Total" / "2019 Total",0)  as "2020_Growth"
--, Coalesce("2018 Total"/"2018-2020 Total",0)  as "2018 Factor"
--, Coalesce("2019 Total"/"2018-2020 Total",0)  as "2019 Factor"
--, Coalesce("2020 Total"/"2018-2020 Total",0)  as "2020 Factor"
,CAST(Sum(Case when Extract (MONTH FROM ReceivedDate) = '1' Then "Transaction Count" End) AS REAL) as "Jan Total"
,CAST(Sum(Case when Extract (MONTH FROM ReceivedDate) = '2' Then "Transaction Count" End)AS REAL) as "Feb Total"
,CAST(Sum(Case when Extract (MONTH FROM ReceivedDate) = '3' Then "Transaction Count" End)AS REAL) as "Mar Total"
,CAST(Sum(Case when Extract (MONTH FROM ReceivedDate) = '4' Then "Transaction Count" End)AS REAL) as "Apr Total"
,CAST(Sum(Case when Extract (MONTH FROM ReceivedDate) = '5' Then "Transaction Count" End)AS REAL) as "May Total"
,CAST(Sum(Case when Extract (MONTH FROM ReceivedDate) = '6' Then "Transaction Count" End) AS REAL)as "Jun Total"
,CAST(Sum(Case when Extract (MONTH FROM ReceivedDate) = '7' Then "Transaction Count" End)AS REAL) as "Jul Total"
,CAST(Sum(Case when Extract (MONTH FROM ReceivedDate) = '8' Then "Transaction Count" End)AS REAL) as "Aug Total"
,CAST(Sum(Case when Extract (MONTH FROM ReceivedDate) = '9' Then "Transaction Count" End) AS REAL)as "Sept Total"
,CAST(Sum(Case when Extract (MONTH FROM ReceivedDate) = '10' Then "Transaction Count" End) AS REAL)as "Oct Total"
,CAST(Sum(Case when Extract (MONTH FROM ReceivedDate) = '11' Then "Transaction Count" End) AS REAL)as "Nov Total"
,CAST(Sum(Case when Extract (MONTH FROM ReceivedDate) = '12' Then "Transaction Count" End) AS REAL)as "Dec Total"
, "Jan Total"/"4Yr Total" as Jan_pct
,  "Feb Total"/"4Yr Total" as Feb_pct
, "Mar Total"/"4Yr Total" as Mar_pct
, "Apr Total"/"4Yr Total" as Apr_pct
, "May Total"/"4Yr Total" as May_pct
,  "Jun Total"/"4Yr Total" as Jun_pct
, "Jul Total"/"4Yr Total" as Jul_pct
, "Aug Total"/"4Yr Total" as Aug_pct
,"Sept Total"/"4Yr Total" as Sep_pct
, "Oct Total"/"4Yr Total" as Oct_pct
, "Nov Total"/"4Yr Total" as Nov_pct
, "Dec Total"/"4Yr Total" as Dec_pct
,'' as "Team Alignment"
,'' as "CI Indicator"
,''as "EWMA20"                
,''as "EWMA21"
,''as "EWMA22"
,''as "EWMA23"
,''as "EWMA24"
from T
group by 1,2,3,4
Order by 1,2,3,4

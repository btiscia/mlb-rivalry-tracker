/* This routine provides Historical Point In Time  for Annuity Operations

*  Peer Review & Change Log:  
*  Peer Review Date: 
*  Source for this routine is  PROD_DMA_VW.ANO_ADO_PIT_INTEGRATED_FCT_VW
*  Author: Christina Valenti, Lorraine Christian, Kristin Carlile
*  Created: NA
*  Revised:  7/8/2019
*  Revision Made:  7/8/2019 - Pending removed entirely .  GoalValue field removed along with the left join to the goal table, CompletedLongDate added.  
 * Goals added back in 4/16/2020
 * 7/14/2020 Added an addition NIGO Code of '361'.  This is applicable for Annuity Only.  Refer to IGO Count.  - LC
====================================================================== */
/*
Jay copy notes:  

Min Date:  1/26/2016 on 3/10/2021
Switched from Point in time to current view based on Todd B. recomendation
====================*/

With T as (


SELECT 
TransactionTypeName AS "Transaction Type"
,T1.SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,T1.SystemHoldingKey
,T1.AgreementID
/*
,CASE WHEN BCCIndicator = 0
	THEN 'N'
	ELSE 'Y'
END AS "Society 1851"
*/
,systemDivisionname AS "Line of Business"
,ReceivedDate
/*     
,CASE 
     WHEN TRANSACTIONTYPEID = 1 THEN ReceivedDate
--     WHEN TRANSACTIONTYPEID = 2 THEN LoadDate
     WHEN TRANSACTIONTYPEID = 3 THEN CompletedDate
END AS "Date"    
     
,EmployeeRoleName AS "Employee Role Name"
,Coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"    
,Coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
,TeamName AS "Team Name"
*/
,FunctionName AS "Function Name"
,SegmentName AS "Segment Name"
,WorkEventName AS "Work Event Name"
,AdminSystemID AS "Admin System ID"
,AdminSystemCode AS "Admin System"
,ProcessName AS "Process Name"
,ProcessID AS "Process ID"
,ProcessOrder AS "Process Order"
,ServiceChannelName AS "Service Channel Code"
,PartyTypeName AS "Party Type Name"
,EmployeeOrganizationName AS "Employee Organization Name"
,EmployeeDepartmentName AS "Employee Department Name"             
,SiteName AS "Site Name"
--,WorkEventOranizationName AS "Work Event Organization Name"
--,WorkEventDepartmentName AS "Work Event Department Name"
,PrimaryRoleName AS "Primary Role Name"
,SystemName AS "System Name"
,WorkEventNumber AS "Work Event Number"
,DepartmentCode AS "Department Code"
,DivisionCode AS "Division Code"
--,CompletedIndicator AS "Completed Indicator"
--,TAT
,NIGODescription
,TransDate AS "Transaction Date"
--,LongCompletedDate AS "Completed Time Stamp"
--,CATSexpectedcompleteddate AS "Follow Up Date" 
--,ShortComment AS "Short Comments"
,ItemCount AS "Transaction Count"
,DaysPastTAT AS "Total TAT Days"
--,CASE WHEN MetExpectedIndicator = 1 AND DaysPastTAT <= 0 THEN 1 ELSE 0 END AS "Met Expected Count"
--,MetExpectedIndicator AS "Met Expected Ind Count"
--,CurrentProdCredit AS "Productivity Credits"  Removed 4/29 and added case statement below

 , CASE
            WHEN SrcSysID = 24 THEN ProdCredit
            ELSE CurrentProdCredit
            END AS "Productivity Credits"

,CASE WHEN IGOIndicator = 1 AND NIGOCode = '-99' THEN 1 ELSE 0 END AS "NIGO Count"
,CASE WHEN IGOIndicator = 1 AND NIGOCode IN ('090','361') THEN 1 ELSE 0 END AS "IGO Count"  -- REPLACES LINE BELOW '361' is applicable for Annuity Only. 
--,CASE WHEN IGOIndicator = 1 AND NIGOCode = '090' THEN 1 ELSE 0 END AS "IGO Count"   REMOVED THIS LINE 7/14/2020 
,IGOIndicator AS "IGO NIGO Count"
--,GoalValue AS "IGO Goal" --added 4/16
,FlexIndicator AS "Flex Count"
--,MajorProductName AS "Contract Type" REMOVED 4/6/2020
, CASE 
 		WHEN T1.MajorProductName IS NULL AND PrimaryLogID IN (6, 10) THEN 'Unknown' 
 		WHEN T1.MajorProductName IS NULL AND PrimaryLogID NOT IN (6, 10) THEN NULL 
 		ELSE T1.MajorProductName 
 		END AS "Contract Type"
/*,CASE WHEN DaysPastTAT <= 0 THEN 1 ELSE 0 END AS "Met TAT Count"
,CASE WHEN DaysPastTAT = 1 THEN 1 ELSE 0 END AS "Past TAT 1"
,CASE WHEN DaysPastTAT = 2 THEN 1 ELSE 0 END AS "Past TAT 2"
,CASE WHEN DaysPastTAT = 3 THEN 1 ELSE 0 END AS "Past TAT 3"
,CASE WHEN DaysPastTAT >= 4 THEN 1 ELSE 0 END AS "Past TAT 4+"*/
 ,ISSUE_DT
 ,PolicyStatus
 ,LOB_NME
 ,LOB_CDE
,CTRT_JURISDICTION
,Distribution_Channel
,SRC_Distribution_Channel
,Major_Prod_NME
,Minor_Prod_NME
,Prod_TYP_NME
,Admn_SYS_CDE  
,MinIss.Min_Iss_Dt  
FROM PROD_DMA_VW.ACT_ANO_CURR_INTEGRATED_VW T1
 Left Join (
		SELECT
            SOURCETRANSACTIONID
            ,AGREEMENTID
            ,MAX(SEQUENCENUMBER) AS MAXSEQ
        
        FROM PROD_DMA_VW.ACT_LAC_CURR_INTEGRATED_VW
        
        WHERE WorkEventDepartmentID in (9,11)
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
                where Issue_DT between '1970-01-01' and  '2021-12-31'
        ) AS InforceData ON 
     					   InforceData.HLDG_KEY = T1.HoldingKey and InforceData.Agreement_ID = T1.AgreementID
                     --   (LAC.AGREEMENTID IS NOT NULL AND InforceData.AGREEMENT_ID=LAC.AgreementID) 
                      --  OR 
                      --  (LAC.AGREEMENTID IS NULL AND TRIM(LEADING '0' FROM InforceData.HLDG_KEY)=TRIM(LEADING '0' FROM T1.HoldingKey) AND 
                     --   InforceData.AGREEMENT_SOURCE_CD=T1.AdminSystemCode)
Left Join (
					select 
					HLDG_KEY
					,Min (Issue_DT) as Min_Iss_Dt
					FROM PROD_USIG_STND_VW.AGMT_CMN_VW 
					Where LOB_CDE = 'ANN'
					group by 1 ) as MinIss ON  MinIss.HLDG_KEY = Coalesce (T1.HoldingKey , T1.SystemHoldingKey) 

WHERE (WorkEventDepartmentID in (9,11) 
OR T1. DepartmentID in (9, 11))
AND TransactionTypeId IN (1)--,3)
And "Line of Business" = 'Annuities'
--And ("Function Name" <> 'Tax/Maturities' and "Segment Name" <> 'Annuity')  --Removes Tax team work ----this removed too much...trouble shoot
And "Contract Type" Not In ('Disability Income','Group Non-Traditional Life','Non-Traditional Life','Pay Out','Traditional Long Term Care','Traditional Permanent','Traditional Term')
And ReceivedDate Between '2017-01-01' and '2020-12-31'

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
,CAST(Sum(Case when Extract (YEAR FROM ReceivedDate) in ('2018','2019','2020') Then "Transaction Count" End)AS REAL) as  "2018-2020 Total"
--,Coalesce( "2018 Total" / "2017 Total",0) as "2018_Growth"
--,Coalesce("2019 Total" / "2018 Total",0)  as "2019_Growth"
--,Coalesce("2020 Total" / "2019 Total",0)  as "2020_Growth"
--, Coalesce("2018 Total"/"2018-2020 Total",0)  as "2018 Factor"
--, Coalesce("2019 Total"/"2018-2020 Total",0)  as "2019 Factor"
--, Coalesce("2020 Total"/"2018-2020 Total",0)  as "2020 Factor"
--,''as "Weighted_Growth"
,'' as "4yrCAGR"
,'' as "3yrCAGR"
,''as "Fx_2021"
,''as "Fx_2022"
--,'' as "CAGR2022"
,''as "Fx_2023"
--,''as "CAGR2023"
,''as "Fx_2024"
--,''as "CAGR2024"
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
from T
group by 1,2,3,4
Order by 1,2,3,4

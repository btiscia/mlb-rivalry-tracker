
With T as (

Select  T1. * 
,'1' as  "Transaction Count"
 ,LOB_NME
 ,LOB_CDE
 ,Major_Prod_NME
,Minor_Prod_NME
,Prod_TYP_NME
 ,ISSUE_DT
From PROD_DMA_VW.ACT_LAC_CURR_INTEGRATED_VW T1
Left Join (
		SELECT
            SOURCETRANSACTIONID
            ,AGREEMENTID
            ,MAX(SEQUENCENUMBER) AS MAXSEQ
        
        FROM PROD_DMA_VW.ACT_LAC_CURR_INTEGRATED_VW
        
        WHERE WorkEventDepartmentID in (7,8)
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
	WHERE  (WorkEventDepartmentID   IN (7,8)
OR DepartmentID IN (7,8))
AND SequenceNumber = 1
And T1.ReceivedDate Between '2017-01-01' and '2020-12-31'
And (WorkEventDepartmentName = 'Annuity Claims' or FunctionName= 'Income Settlement Claims')
--And (systemDivisionname = 'Annuities' or (LOB_NME = 'Annuity' or LOB_NME is null))

)

Select
-- LOB_NME
--,Major_Prod_NME
 --"Line of Business"

--systemDivisionname as "Line of Business" 
"FunctionName"
,"SegmentName"
,"WorkEventName"
,WorkEventOranizationName
,WorkEventDepartmentName
,LOB_NME
,Major_Prod_NME
--,"Department Code"
,Coalesce (CAST(Sum(Case when Extract (YEAR FROM ReceivedDate) = '2017' Then "Transaction Count" End)AS REAL),0) as "2017 Total"
,Coalesce (CAST(Sum(Case when Extract (YEAR FROM ReceivedDate) = '2018' Then "Transaction Count" End)AS REAL),0) as "2018 Total"
,Coalesce(CAST(Sum(Case when Extract (YEAR FROM ReceivedDate) = '2019' Then "Transaction Count" End)AS REAL),0) as "2019 Total"
,Coalesce(CAST(Sum(Case when Extract (YEAR FROM ReceivedDate) = '2020' Then "Transaction Count" End)AS REAL),0) as "2020 Total"
,Count (*) as "2017-2020 Cnt"
From T
group by 1,2,3,4,5,6,7
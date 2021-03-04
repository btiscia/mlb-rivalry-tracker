
----Creats view: DMA_GRP_DL.Waiver_Claim_Jay

SELECT DISTINCT
CPV.PolicyNumber,
CPV.AdminSystemCode,
CPV.WorkEventName, 
CPV.ReceivedDate,
CPV.SourceTransactionID,
CPV.WorkEventDepartmentID,  
CPV.TransactionDate AS LatestUpdatedDate,
CPV.FunctionName,
CPV.SegmentName, 
CPV.EmployeeDepartmentName, 
CPV.TeamName, 
CPV.EmployeeRoleName, 
CPV.EmployeeName,
CPV.InsuredName,
CPV.InsuredLastName,
CPV.InsuredFirstName,
CPV.InsuredMiddleName,
LAC.AgreementID, 
CPV.LoggedDate,
InforceData.AGREEMENT_ID, 
InforceData.ISSUE_DT,
InforceData.FACE_AMOUNT,
InforceData.CONV_IND,
InforceData.REINS_IND,
InforceData.PolicyStatus,
InforceData.LOB_NME,
InforceData.LOB_CDE,
InforceData.CTRT_JURISDICTION,
Comments.CMNT_TYP_CDE, 
--Comments.TXT_DES,
InforceData.InsuredGovtID,
QUAL.QualifyingPlanIndicator
--,Sum  (InforceData.Face_Amount) Over (Partition by InforceData.InsuredgovtID) as Tot_Face
--,Count (CPV.PolicyNumber) over (Partition by InforceData.InsuredgovtID, CPV.PolicyNumber) Cnt
--,(Sum  (InforceData.Face_Amount) Over (Partition by InforceData.InsuredgovtID)) /(Count (PolicyNumber) over (Partition by InsuredgovtID, PolicyNumber)) as Claim_Face

FROM PROD_DMA_VW.CURR_PEND_VW AS CPV
LEFT JOIN 
    (
        SELECT
            SOURCETRANSACTIONID
            ,AGREEMENTID
            ,MAX(SEQUENCENUMBER) AS MAXSEQ
        
        FROM PROD_DMA_VW.ACT_LAC_CURR_INTEGRATED_VW --AS TEST ON CPV.SOURCETRANSACTIONID=TEST.SOURCETRANSACTIONID
        
        WHERE WorkEventDepartmentID = '8'
               AND WorkEventName LIKE '{LC} CLAIM EXAM%'
               AND RoleID='22' --Role = Operations Setup 
                AND AdminSystem IN ('CM2000','MPR','VUL','PE1', 'LIFCOM', 'LVRGVL', 'OPM', 'UNIV', 'VNT', 'VNTAGE', 'VNTG1')
        
        GROUP BY 1,2
    ) AS LAC ON CPV.SOURCETRANSACTIONID=LAC.SOURCETRANSACTIONID

LEFT JOIN
        (
                SELECT
                        ACV.AGREEMENT_ID,
                        ACV.HLDG_KEY,
                        ACV.AGREEMENT_SOURCE_CD, 
                        ACV.ISSUE_DT,
                        ACV.FACE_AMOUNT,
                        ACV.CONV_IND,
                        ACV.REINS_IND,
                        CASE 
                            WHEN ACV.HLDG_STUS='TM' THEN 'Terminated'
                            WHEN ACV.HLDG_STUS='IF' THEN 'Inforce'
                            WHEN ACV.HLDG_STUS='NB' THEN 'NewBusiness'
                            WHEN ACV.HLDG_STUS='NR' THEN 'NotRecorded'
                            ELSE  'Unknown' END AS PolicyStatus,
                        ACV.LOB_NME,
                        ACV.LOB_CDE,
                        ACV.CTRT_JURISDICTION,
                        MAX(CDV.GOVT_ID_NR) AS InsuredGovtID 
                
                
                FROM PROD_USIG_STND_VW.AGMT_CMN_VW AS ACV
                LEFT JOIN PROD_USIG_STND_VW.CUST_AGMT_CMN_VW AS CAC ON ACV.AGREEMENT_ID=CAC.AGREEMENT_ID 
                    AND PRTY_AGMT_RLE_CD='INSD' AND PRTY_AGMT_RLE_STYP_CD='PRMR' 
                    AND CAC.AGREEMENT_SOURCE_CD IN ('CM2000','MPR','VUL','PE1', 'LIFCOM', 'LVRGVL', 'OPM', 'UNIV', 'VNT', 'VNTAGE', 'VNTG1') 
                LEFT JOIN PROD_USIG_STND_VW.CUST_DEMOGRAPHICS_VW AS CDV ON CAC.PRTY_ID=CDV.PRTY_ID AND CDV.GOVT_ID_NR IS NOT NULL
                
                WHERE ACV.AGREEMENT_SOURCE_CD IN ('CM2000','MPR','VUL','PE1', 'LIFCOM', 'LVRGVL', 'OPM', 'UNIV', 'VNT', 'VNTAGE', 'VNTG1') 
                AND LOB_CDE IN ('LIFE','DI')
                
                GROUP BY 1,2,3,4,5,6,7,8,9,10,11
                
        ) AS InforceData ON 
                        (LAC.AGREEMENTID IS NOT NULL AND InforceData.AGREEMENT_ID=LAC.AgreementID) 
                        OR 
                        (LAC.AGREEMENTID IS NULL AND TRIM(LEADING '0' FROM InforceData.HLDG_KEY)=TRIM(LEADING '0' FROM CPV.PolicyNumber) AND 
                        InforceData.AGREEMENT_SOURCE_CD=CPV.AdminSystemCode) 
                        
LEFT JOIN PROD_CATS_VW.CATS_WRK_TXT_CMNT_VW AS Comments ON CPV.SourceTransactionID=Comments.FK_WRK_IDENT      
LEFT JOIN PROD_DMA_VW.DBO_WRK_XTN_VW AS QUAL ON CPV.SourceTransactionID=QUAL.FKWrkIdent --identify pensions 11/11/2020  
              
WHERE CPV.WorkEventDepartmentID = '8'
--AND CPV.WorkEventName LIKE '{LC} CLAIM EXAM%'
--AND CPV.EmployeeRoleID='22' --Role = Operations Setup 
--AND CPV.AdminSystemCode IN ('CM2000','MPR','VUL','PE1', 'LIFCOM', 'LVRGVL', 'OPM', 'UNIV', 'VNT', 'VNTAGE', 'VNTG1')


) 

----Tableau Extract runs this query on above view:  

Select DMA_GRP_DL.Waiver_Claim_Jay.*
,Case 
	When DMA_GRP_DL.Waiver_Claim_Jay.InsuredgovtID is Null then DMA_GRP_DL.Waiver_Claim_Jay.Face_Amount
	When DMA_GRP_DL.Waiver_Claim_Jay.InsuredgovtID = '' Then DMA_GRP_DL.Waiver_Claim_Jay.Face_Amount
	Else B.tot_Claim_FaceAmount
	End as Claims_Face_Corrected
,B.tot_Claim_FaceAmount
From DMA_GRP_DL.Waiver_Claim_Jay
	Left Join(Select 
					InsuredGovtID
					,Sum(FACE_AMOUNT) As tot_Claim_FaceAmount
					From (
					Select Distinct 
					InsuredGovtID
					,AgreementID
					,PolicyNumber
					,FACE_AMOUNT
					From DMA_GRP_DL.Waiver_Claim_Jay)a
					Group by 1)B
					On DMA_GRP_DL.Waiver_Claim_Jay.InsuredGovtid = B.InsuredGovtID






--Select * From T 
--Where TXT_DES Like ('%No Death Cert%')
--Only 12 records Identified in all of inventory on 3/3/21
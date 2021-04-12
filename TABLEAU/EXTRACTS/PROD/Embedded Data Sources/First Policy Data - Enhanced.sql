--------First Policy Producer for LIFE and DI------

SELECT DISTINCT
MRG_AGENCY_SRC_SYS_PRTY_ID AGENCY
--,CASE 
--                WHEN PRTY_TERR_RLE_CD = 'DI/LTCI PC External' THEN 'DI/LTC'
--                ELSE 'LIFE'
--END LOB
,CASE
                WHEN PRTY_TERR_RLE_CD = 'DI/LTCI PC EXTERNAL' THEN 'DI'
                WHEN PRTY_TERR_RLE_CD = 'LIFE EXTERNAL' THEN 'LIFE'
END       LOB_JOIN
,CASE 
                WHEN ORGANIZATION_BUSINESS_TYPE_CD IN ('TERM','UL/VL','WHOLE LIFE') THEN 'LIFE'
                WHEN ORGANIZATION_BUSINESS_TYPE_CD IN ('Indiv','SMBIZ','WorkSite') THEN 'DI'
                END        LOB_JOIN2                      
,CASE 
                WHEN TERR_DIVISION LIKE ('%PCG%') THEN 'PCG'
                WHEN TERR_DIVISION LIKE ('%N/A%') THEN 'DDC'
                ELSE TERR_DIVISION
END                                                          DIVISION
,CASE 
                WHEN WHLSLR_FULL_NM LIKE ('OPEN%') THEN SUBSTR(WHLSLR_FULL_NM, POSITION(',' IN WHLSLR_FULL_NM) + 2, LENGTH(WHLSLR_FULL_NM))
                ELSE SUBSTR(WHLSLR_FULL_NM,1,POSITION(',' IN WHLSLR_FULL_NM)-1) 
END                                                                                           Territory
,COALESCE(SALES_UNIT_MANAGER, 'NO MANAGER') "Sales Mgr/ Brokerage Director"
,SUBMIT. SOLICITING_AGT_FULL_NM                                                         Producer
,CASE
                                 WHEN ORGANIZATION_BUSINESS_TYPE_CD = 'Whole LIFE'                 AND PROD_ID = 'CC1' THEN 'CC1'
                                ELSE ORGANIZATION_BUSINESS_TYPE_CD
                                                END                                                                                                                 Product               --USED for Reports and filters to display  (Whole Life, Term, UL/VL, CC1)                       
,CASE
                WHEN ORGANIZATION_BUSINESS_TYPE_CD IN ('INDIV','SMBIZ','WORKSITE') THEN ANNL_PREM
                ELSE WEIGHTED_ANNUAL_PREM_AMT
END                                                                                                           "Weighted Premium"
,ESTIMATED_FYC
,Submit.SOLICITING_AGT_SRC_SYS_PRTY_ID                        Producer_ID
,CURR_STATUS_EVENT_DETAIL                                                 InventoryStatus
,SUBMISSION_DATE                                                                            Submit_Date
,HLDG_KEY                                                                                               POLICY_NUMBER
--,CASE
--		WHEN LOB_JOIN2 = 'DI'OR LOB_JOIN2 = 'Worksite' THEN Product_TYPE
--		ELSE Prod_ID
--	END                                                                                                          PLAN_CODE
,PROD_ID                                                                                                   PLAN_CODE
,INS_LAST_NAME INSURED_LAST_NAME
,MRG_ENT_NM
,CASE
                                                                                                                                WHEN MRG_AGENCY_SRC_SYS_PRTY_ID IN ('113','249','226') THEN 'DB'
                                                                                                                                WHEN MRG_AGENCY_SRC_SYS_PRTY_ID IN ('244') THEN 'SDP'
                                WHEN SOLICITING_AGT_TYP_CD= 'Y' THEN 'CAS'
                                WHEN SOLICITING_AGT_TYP_CD = 'N' THEN 'CAB' 
                                 WHEN SOLICITING_AGT_TYP_CD = 'CAS' THEN 'CAS'
                                WHEN SOLICITING_AGT_TYP_CD = 'CAB' THEN 'CAB'
                                 ELSE 'Unknown'
               END  AGY_CAS_IND       
,SOLICITING_AGT_TYP_DESC
,CURR_STATUS_EVENT_DT
,CURR_STATUS_EVENT_DETAIL
,PREPAID_PREMIUM_IND
,ANNL_PREM
,COV_ADL_PREM
,APPL_1035_AS_PREM
,INS_FIRST_NAME
,INS_FULL_NAME
,REPL_TYP_DESC
,REPLACEMENT_INSURANCE_IND
,REPLACEMENT_CNT
,SIGN_METH
,ESIGN_CNT
,GRADED_PREMIUM
,GROUP_SRC_SYS_PRTY_ID
,GROUP_FULL_NM
,SRC_SYS
,COMP_SOL_AGT_SRC_SYS_PRTY_ID
,COMP_SOL_AGT_FULL_NM
,COMP_PCT
,COMP_WEIGHTED_ANNUAL_PREM_AMT
,COMP_ESTIMATED_FYC
,COMP_ANNUAL_PREMIUM
,Product_TYPE2
,NUM_POL
,Min_Submit_Date
,Life_Counts
,DI_Counts
,Annuity_Counts
,LTC_Counts
,TeamHIER.Region                                                                                                    Region2
,AgencyDisplayName                                                                                                                           "Firm Name"
,CASE
		WHEN MET_Indicator = 0 THEN 'Legacy'
		WHEN MET_Indicator = 1 THEN 'PCG'
		END                                                                                                    PCG   
FROM PROD_NBR_VW.NB_BLDED_SUBMIT_APPL_DTL_VW            SUBMIT 

INNER JOIN PROD_USIG_ACCESS_VW.AFT_WHLSLR_HIER_VW       HIER
ON HIER.MEMBER_ID = SUBMIT.MRG_AGENCY_SRC_SYS_PRTY_ID


INNER JOIN  ----------to create unique instences at the Product level
(SELECT DISTINCT SOLICITING_AGT_SRC_SYS_PRTY_ID
, SOLICITING_AGT_FULL_NM   
,CASE
                                                                WHEN ORGANIZATION_BUSINESS_TYPE_CD = 'Whole LIFE' AND PROD_ID = 'CC1' THEN 'CC1'
                                                                                ELSE ORGANIZATION_BUSINESS_TYPE_CD
                                                                END                                                                           Product_TYPE2-------Combination of (Poduct_TYPE2, NUM_POL, MIN_HLDG_KEY, MIN_Submit_Date) makes  this a unique record to join on so records wont duplicate. -----
,COUNT(DISTINCT HLDG_KEY)                                NUM_POL
,MIN (HLDG_KEY)                                                               Min_HLDG_KEY
,MIN (DISTINCT Submission_Date)                          Min_Submit_Date
FROM PROD_NBR_VW.NB_BLDED_SUBMIT_APPL_DTL_VW
GROUP BY  1,2,3)                                   First_Sub
                ON Producer_ID = FIRST_SUB.SOLICITING_AGT_SRC_SYS_PRTY_ID     
                AND Product = Product_TYPE2
                AND POLICY_NUMBER = Min_HLDG_KEY
                AND Submit_Date = Min_Submit_Date       

                                                                
INNER  JOIN  ----To create a calculation to sum all the policies sold for that LOB
( SELECT DISTINCT SOLICITING_AGT_SRC_SYS_PRTY_ID
,SOLICITING_AGT_FULL_NM
,COUNT (DISTINCT CASE 
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD  IN ('TERM','UL/VL','WHOLE LIFE')
                                THEN HLDG_KEY
                                END)                                              Life_Counts
,COUNT (DISTINCT CASE 
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD  IN ('Indiv','SMBIZ','WorkSite')
                                THEN HLDG_KEY
                                END)                                              DI_Counts
,COUNT (DISTINCT CASE 
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD  IN ('MassMutual Evolution','MassMutual Artistry','MassMutual Transitions Select','MassMutual Capital Vantage','MassMutual RetireEase Select','MassMutual Stable Voyage','Transitions Select II','MassMutual RetireEase','MassMutual RetireEase Choice')
                                THEN HLDG_KEY
                                END)                                           Annuity_Counts
,COUNT (DISTINCT CASE 
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD  IN ('SignatureCare')
                                THEN  HLDG_KEY
                                END)                                          LTC_Counts
FROM PROD_NBR_VW.NB_BLDED_SUBMIT_APPL_DTL_VW
GROUP BY  1,2)           FIRST_Sub_Counts
                               ON Producer_ID =  FIRST_Sub_Counts.SOLICITING_AGT_SRC_SYS_PRTY_ID



LEFT OUTER JOIN -- Determine max role for brokerage agencies---
                (SELECT MEMBER_ID, MAX(PRTY_TERR_RLE_CD) AS                              MaxPartyRole
                FROM PROD_USIG_ACCESS_VW.AFT_WHLSLR_HIER_VW
                WHERE MEMBER_ID NOT IN -- brokerage agencies
                                (SELECT  DISTINCT MEMBER_ID
                            FROM PROD_USIG_ACCESS_VW.AFT_WHLSLR_HIER_VW
                            WHERE MEMBER_RLE = 'AGCY'
                            AND PRTY_TERR_RLE_CD IN   ('DI/LTCI PC EXTERNAL','Annuity External','LIFE EXTERNAL'))
                                GROUP BY MEMBER_ID )                                                                                           BrokerageRole 
ON SUBMIT.MRG_AGENCY_SRC_SYS_PRTY_ID = BrokerageRole.MEMBER_ID

LEFT OUTER JOIN   DMA_GRP_DL.Agencies                                                            TeamHIER   ----To add the AFT Team alignment to the main data set---
ON MRG_AGENCY_SRC_SYS_PRTY_ID = OriginalAgencyCode

WHERE 

                SUBMIT_DATE > CURRENT_DATE - INTERVAL '2' YEAR   
                
                AND (
                
                -- CAS AGENCIES
                (MEMBER_RLE = 'AGCY'
                AND LOB_JOIN = LOB_JOIN2
                AND PRTY_TERR_RLE_CD  IN ('DI/LTCI PC External', 'Life External'))
    
                                OR            
    
    --  BROKERAGE IN HIERARCHY
    
                (MEMBER_RLE = 'AGCY' AND SUBMIT.MRG_AGENCY_SRC_SYS_PRTY_ID NOT IN  -- Non-CAS agencies with max role found
                                (SELECT DISTINCT MEMBER_ID
                                FROM PROD_USIG_ACCESS_VW.AFT_WHLSLR_HIER_VW
                                WHERE MEMBER_RLE = 'AGCY'
                                AND PRTY_TERR_RLE_CD IN  ('DI/LTCI PC EXTERNAL','Annuity External','LIFE EXTERNAL') )
                    AND PRTY_TERR_RLE_CD = BrokerageRole.MaxPartyRole ) 
                
                  OR
                  
    --  BROKERAGE NOT IN HIERARCHY    
    
                MRG_AGENCY_SRC_SYS_PRTY_ID IN    
                                (SELECT DISTINCT MRG_AGENCY_SRC_SYS_PRTY_ID
                                FROM PROD_NBR_VW.NB_PENDING_INVENTORY_DTL_VW        
                                 WHERE MRG_AGENCY_SRC_SYS_PRTY_ID  NOT IN 
                                         (SELECT DISTINCT MEMBER_ID
                                         FROM PROD_USIG_ACCESS_VW.AFT_WHLSLR_HIER_VW
                                         WHERE  MEMBER_RLE = 'AGCY')
)
                
                ) -- CLOSE AND
                
                
UNION




--------FIrst Policy producer for LTC and ANNUITY

   SELECT DISTINCT
MRG_AGENCY_SRC_SYS_PRTY_ID AGENCY
--,CASE 
--                WHEN PRTY_TERR_RLE_CD = 'DI/LTCI PC External' THEN 'DI/LTC'
--                ELSE 'LIFE'
--END LOB
,CASE
                WHEN PRTY_TERR_RLE_CD = 'DI/LTCI PC EXTERNAL' THEN 'LTC'
                WHEN PRTY_TERR_RLE_CD = 'Annuity EXTERNAL' THEN 'ANN'
END       LOB_JOIN
,CASE 
                WHEN ORGANIZATION_BUSINESS_TYPE_CD IN ('SignatureCare') THEN 'LTC'
                WHEN ORGANIZATION_BUSINESS_TYPE_CD IN ('MassMutual Evolution','MassMutual Artistry','MassMutual Transitions Select','MassMutual Capital Vantage','MassMutual RetireEase Select','MassMutual Stable Voyage','Transitions Select II','MassMutual RetireEase','MassMutual RetireEase Choice') THEN 'ANN'
                END        LOB_JOIN2
,CASE 
                WHEN TERR_DIVISION LIKE ('%PCG%') THEN 'PCG'
                WHEN TERR_DIVISION LIKE ('%N/A%') THEN 'DDC'
                ELSE TERR_DIVISION
END                                                          DIVISION
,CASE 
                WHEN WHLSLR_FULL_NM LIKE ('OPEN%') THEN SUBSTR(WHLSLR_FULL_NM, POSITION(',' IN WHLSLR_FULL_NM) + 2, LENGTH(WHLSLR_FULL_NM))
                ELSE SUBSTR(WHLSLR_FULL_NM,1,POSITION(',' IN WHLSLR_FULL_NM)-1) 
END                                                                                           Territory
,COALESCE(SALES_UNIT_MANAGER, 'NO MANAGER') "Sales Mgr/ Brokerage Director"
,SUBMIT. SOLICITING_AGT_FULL_NM                                                         Producer
,CASE  ---to  create common product hierarchy with Life/DI table and level of uniqueness for logic to identify first policy submitted
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%Capital Vantage%')
                                THEN 'Variable'
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('Transitions Select II')
                                THEN 'Variable'
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%RetireEase Choice%')
                                THEN 'Income'
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%RetireEase%')
                                THEN 'Income'
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%Stable Voyage%')
                                THEN 'Fixed'
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%Odyssey Select%')
                                THEN 'Fixed'
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('MassMutual Transitions SELECT')
                                THEN 'Variable' 
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%MassMutual Evolution%')
                                THEN 'Variable'
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%Artistry%')
                                THEN 'Variable'
                                 WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%UltraCare Life%')
                                THEN 'LTC'
                                 WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%SignatureCare%')
                                THEN 'LTC'
                                ELSE  ORGANIZATION_BUSINESS_TYPE_CD
                                END                                                                                            Product --USED for Reports and filters                       
,CASE
                WHEN ORGANIZATION_BUSINESS_TYPE_CD IN ('INDIV','SMBIZ','WORKSITE') THEN ANNL_PREM
                ELSE WEIGHTED_ANNUAL_PREM_AMT
END 																											 "Weighted Premium"
,ESTIMATED_FYC
,Submit.SOLICITING_AGT_SRC_SYS_PRTY_ID                       Producer_ID
,CURR_STATUS_EVENT_DETAIL                                                 InventoryStatus
,SUBMISSION_DATE                                                                            Submit_Date
,HLDG_KEY                                                                                               POLICY_NUMBER
,CASE
		WHEN LOB_JOIN2 = 'ANN' THEN Product_TYPE
		ELSE Prod_ID
	END                                                                                                          PLAN_CODE
--,PROD_ID                                                                                                   PLAN_CODE
,INS_LAST_NAME INSURED_LAST_NAME
,MRG_ENT_NM
,CASE
                                                                                                                                WHEN MRG_AGENCY_SRC_SYS_PRTY_ID IN ('113','249','226') THEN 'DB'
                                                                                                                                WHEN MRG_AGENCY_SRC_SYS_PRTY_ID IN ('244') THEN 'SDP'
                                WHEN SOLICITING_AGT_TYP_CD= 'Y' THEN 'CAS'
                                WHEN SOLICITING_AGT_TYP_CD = 'N' THEN 'CAB' 
                                 WHEN SOLICITING_AGT_TYP_CD = 'CAS' THEN 'CAS'
                                WHEN SOLICITING_AGT_TYP_CD = 'CAB' THEN 'CAB'
                                 ELSE 'Unknown'
               END  AGY_CAS_IND       
,SOLICITING_AGT_TYP_DESC
,CURR_STATUS_EVENT_DT
,CURR_STATUS_EVENT_DETAIL
,PREPAID_PREMIUM_IND
,ANNL_PREM
,COV_ADL_PREM
,APPL_1035_AS_PREM
,INS_FIRST_NAME
,INS_FULL_NAME
,REPL_TYP_DESC
,REPLACEMENT_INSURANCE_IND
,REPLACEMENT_CNT
,SIGN_METH
,ESIGN_CNT
,GRADED_PREMIUM
,GROUP_SRC_SYS_PRTY_ID
,GROUP_FULL_NM
,SRC_SYS
,COMP_SOL_AGT_SRC_SYS_PRTY_ID
,COMP_SOL_AGT_FULL_NM
,COMP_PCT
,COMP_WEIGHTED_ANNUAL_PREM_AMT
,COMP_ESTIMATED_FYC
,COMP_ANNUAL_PREMIUM
,Product_TYPE2
,NUM_POL
,Min_Submit_Date
,Life_Counts
,DI_Counts
,Annuity_Counts
,LTC_Counts
,TeamHIER.Region                                                                                                    Region2
,AgencyDisplayName                                                                                                                           "Firm Name"
,CASE
                                WHEN MET_Indicator = 0 THEN 'Legacy'
                                WHEN MET_Indicator = 1 THEN 'PCG'
                                END                                                                                                    PCG   
FROM PROD_NBR_VW.NB_BLDED_SUBMIT_APPL_DTL_VW            SUBMIT 

INNER JOIN PROD_USIG_ACCESS_VW.AFT_WHLSLR_HIER_VW       HIER
ON HIER.MEMBER_ID = SUBMIT.MRG_AGENCY_SRC_SYS_PRTY_ID


INNER JOIN 
(SELECT DISTINCT SOLICITING_AGT_SRC_SYS_PRTY_ID
, SOLICITING_AGT_FULL_NM   
,CASE  ---to  create common product hierarchy with Life/DI table and level of uniqueness for logic to identify first policy submitted
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%Capital Vantage%')
                                THEN 'Variable'
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('Transitions Select II')
                                THEN 'Variable'
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%RetireEase Choice%')
                                THEN 'Income'
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%RetireEase%')
                                THEN 'Income'
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%Stable Voyage%')
                                THEN 'Fixed'
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%Odyssey Select%')
                                THEN 'Fixed'
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('MassMutual Transitions SELECT')
                                THEN 'Variable' 
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%MassMutual Evolution%')
                                THEN 'Variable'
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%Artistry%')
                                THEN 'Variable'
                                 WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%UltraCare Life%')
                                THEN 'LTC'
                                 WHEN ORGANIZATION_BUSINESS_TYPE_CD LIKE ('%SignatureCare%')
                                THEN 'LTC'
                                ELSE  ORGANIZATION_BUSINESS_TYPE_CD
                                END                                                                                            Product_TYPE2 --USED for Reports and filters  -------Combination of (Poduct_TYPE2, NUM_POL, MIN_HLDG_KEY, MIN_Submit_Date) makes  this a unique record to join on so records wont duplicate. -----                                                                                                                        
,COUNT(DISTINCT HLDG_KEY)                                NUM_POL
,MIN (HLDG_KEY)                                                               Min_HLDG_KEY
,MIN (DISTINCT Submission_Date)                          Min_Submit_Date
FROM PROD_NBR_VW.NB_BLDED_SUBMIT_APPL_DTL_VW
GROUP BY  1,2,3)                                   First_Sub
                ON Producer_ID = FIRST_SUB.SOLICITING_AGT_SRC_SYS_PRTY_ID     
                AND Product = Product_TYPE2
                AND POLICY_NUMBER = Min_HLDG_KEY
                AND Submit_Date = Min_Submit_Date       

                                                                
INNER  JOIN
( SELECT DISTINCT SOLICITING_AGT_SRC_SYS_PRTY_ID
,SOLICITING_AGT_FULL_NM
,COUNT (DISTINCT CASE 
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD  IN ('TERM','UL/VL','WHOLE LIFE')
                                THEN HLDG_KEY
                                END)                                              Life_Counts
,COUNT (DISTINCT CASE 
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD  IN ('Indiv','SMBIZ','WorkSite')
                                THEN HLDG_KEY
                                END)                                              DI_Counts
,COUNT (DISTINCT CASE 
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD  IN ('MassMutual Evolution','MassMutual Artistry','MassMutual Transitions Select','MassMutual Capital Vantage','MassMutual RetireEase Select','MassMutual Stable Voyage','Transitions Select II','MassMutual RetireEase','MassMutual RetireEase Choice')
                                THEN HLDG_KEY
                                END)                                           Annuity_Counts
,COUNT (DISTINCT CASE 
                                WHEN ORGANIZATION_BUSINESS_TYPE_CD  IN ('SignatureCare')
                                THEN  HLDG_KEY
                                END)                                          LTC_Counts
FROM PROD_NBR_VW.NB_BLDED_SUBMIT_APPL_DTL_VW
GROUP BY  1,2)           FIRST_Sub_Counts
                               ON Producer_ID =  FIRST_Sub_Counts.SOLICITING_AGT_SRC_SYS_PRTY_ID



LEFT OUTER JOIN -- Determine max role for brokerage agencies
                (SELECT MEMBER_ID, MAX(PRTY_TERR_RLE_CD) AS                              MaxPartyRole
                FROM PROD_USIG_ACCESS_VW.AFT_WHLSLR_HIER_VW
                WHERE MEMBER_ID NOT IN -- brokerage agencies
                                (SELECT  DISTINCT MEMBER_ID
                            FROM PROD_USIG_ACCESS_VW.AFT_WHLSLR_HIER_VW
                            WHERE MEMBER_RLE = 'AGCY'
                            AND PRTY_TERR_RLE_CD IN   ('DI/LTCI PC EXTERNAL','Annuity External','LIFE EXTERNAL'))
                                GROUP BY MEMBER_ID )                                                                                           BrokerageRole 
ON SUBMIT.MRG_AGENCY_SRC_SYS_PRTY_ID = BrokerageRole.MEMBER_ID

LEFT OUTER JOIN   DMA_GRP_DL.Agencies                                                            TeamHIER
ON MRG_AGENCY_SRC_SYS_PRTY_ID = OriginalAgencyCode

WHERE 

                SUBMIT_DATE > CURRENT_DATE - INTERVAL '2' YEAR
                
                AND (
                
                -- CAS AGENCIES
                (MEMBER_RLE = 'AGCY'
                AND LOB_JOIN = LOB_JOIN2
                AND PRTY_TERR_RLE_CD  IN ('DI/LTCI PC External', 'Annuity External'))
    
                                OR            
    
    --  BROKERAGE IN HIERARCHY
    
                (MEMBER_RLE = 'AGCY' AND SUBMIT.MRG_AGENCY_SRC_SYS_PRTY_ID NOT IN  -- Non-CAS agencies with max role found
                                (SELECT DISTINCT MEMBER_ID
                                FROM PROD_USIG_ACCESS_VW.AFT_WHLSLR_HIER_VW
                                WHERE MEMBER_RLE = 'AGCY'
                                AND PRTY_TERR_RLE_CD IN  ('DI/LTCI PC EXTERNAL','Annuity External','LIFE EXTERNAL') )
                    AND PRTY_TERR_RLE_CD = BrokerageRole.MaxPartyRole ) 
                
                  OR
                  
    --  BROKERAGE NOT IN HIERARCHY    
    
                MRG_AGENCY_SRC_SYS_PRTY_ID IN    
                                (SELECT DISTINCT MRG_AGENCY_SRC_SYS_PRTY_ID
                                FROM PROD_NBR_VW.NB_PENDING_INVENTORY_DTL_VW        
                                 WHERE MRG_AGENCY_SRC_SYS_PRTY_ID  NOT IN 
                                         (SELECT DISTINCT MEMBER_ID
                                         FROM PROD_USIG_ACCESS_VW.AFT_WHLSLR_HIER_VW
                                         WHERE  MEMBER_RLE = 'AGCY')
)
                
                ) -- CLOSE AND

---IF LOB_JOIN2 is null, then in the tableau report these are filtered out.
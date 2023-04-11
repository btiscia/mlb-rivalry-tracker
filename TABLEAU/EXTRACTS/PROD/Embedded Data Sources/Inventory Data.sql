/*  
FILENAME: Inventory Data
CREATED BY: Bill Trombley
LAST UPDATED: 1/24/2023
CHANGES MADE: Vertica SQL Creation
CHANGES MADE:
*/

SELECT 
AGENCY AS "Agency"
,underwriter_nm           AS "UW_FULL_NM"
,underwriting_team_nm     AS "UW_TEAM_NM"
,underwriter_team_nm      AS "UW_TEAM"
,case_manager_last_nm     AS "CM_LAST_NAME"
,case_manager_first_nm    AS "CM_FIRST_NAME"
,case_manager_team_cde    AS "CM_TEAM"
,case_manager_team_nm     AS "CM_TEAM_NAME"
,POLICY_NUMBER AS "Policy Number"
,line_of_business_cde     AS "LOB_FLAG"
,HIER.prty_terr_rle_cd    AS "PRTY_TERR_RLE_CD" 
,HIER.member_rle          AS "MEMBER_RLE"
,CASE 
  WHEN HIER.terr_division   LIKE ('%PCG%') THEN 'PCG'
  WHEN HIER.terr_division   LIKE ('%N/A%') THEN 'DDC'
  ELSE HIER.terr_division
END AS "DIVISION"
,HIER.terr_nm              AS "TERR_NM"
,HIER.terr_typ_cd          AS "TERR_TYP_CD"
,HIER.member_id            AS "MEMBER_ID"
,submission_dt             AS "Submit Date" 
,approved_dt               AS "Approved Date"
,HIER.whlslr_full_nm       AS "WHLSLR_FULL_NM"
,CASE 
 WHEN HIER.whlslr_full_nm IN ('DI/LTC, UNASSIGNED','BROKERAGE, UNASSIGNED') THEN 'T&H' 
 WHEN HIER.whlslr_full_nm LIKE ('OPEN%') THEN SUBSTR(HIER.whlslr_full_nm, POSITION(',' IN HIER.whlslr_full_nm) + 2, LENGTH(HIER.whlslr_full_nm))
 ELSE SUBSTR(HIER.whlslr_full_nm,1,POSITION(',' IN HIER.whlslr_full_nm)-1) 
 END AS "WHLSLR_LST_NM"
,inventory_status_text                               AS "Inventory Status"
,prepaid_premium_ind                                 AS "PREPAID_PREMIUM_IND"
,organization_business_type_cde                      AS "ORGANIZATION_BUSINESS_TYPE_CD"
,organization_business_type_cde                      AS "Product"
,product_id                                          AS "Product Type"
,soliciting_agent_full_nm                            AS "Advisor"
,COALESCE(sales_unit_manager_full_nm, 'NO MANAGER')  AS "Sales Mgr/ Brokerage Director"
,calendar_days_since_approved                        AS "CAL_DAYS_SINCE_APROVED"
,weighted_annual_premium_amt                         AS "Weighted Premium"
,annual_premium_amt                                  AS "Base Annual Premium"
,estimated_first_year_commision_amt                  AS "Estimated FYC"
,applied_1035_as_premium_amt                         AS "1035 Premium"
,face_amt                                            AS "Face Amount"
,requirements_desc                                   AS "REQUIREMENTS"
,inventory_status_reason_text                        AS "INVENTORY_REASON"
,calendar_days_since_submit                          AS "CAL_DAYS_SINCE_SUBMIT"
,calendar_days_since_issued                          AS "CAL_DAYS_SINCE_ISSUE"
,group_nr                                            AS "GROUP_SRC_SYS_PRTY_ID"
,group_nm                                            AS "GROUP_SRC_SYS_PRTY_NM"
,insured_last_nm                                     AS "INS_LAST_NAME"
,total_annual_premium_amt                            AS "AGMT_TOT_ANNUAL_PREM_AMT"
,soliciting_agent_source_system_party_id             AS "SOLICITING_AGT_SRC_SYS_PRTY_ID"
,CASE
  WHEN AGCYDATA.distributionchannelcode IN ('DDC', 'SDP', 'MMSD', 'OTHR') THEN 'MMSD' 
  WHEN soliciting_agent_type_cde = 'CAS' THEN 'CAS'
  WHEN soliciting_agent_type_cde = 'CAB' THEN 'CAB'
  ELSE 'Unknown'
END AS "AGY_CAS_IND"
,SRC_SOLICITING_AGY 
,agreement_status_reason_cde                         AS "AGMT_STUS_CD"
,application_issue_dt                                AS "APPLICATION_ISSUE_DATE"
,top_blue_ind                                        AS "TOP_BLUE_IND"
,soliciting_agent_type_cde                           AS "SOLICITING_AGT_TYP_CD"
,application_type_cde                                AS "APPL_TYPE"
,graded_premium_ind                                  AS "GRD_PREM_IND"
,calendar_days_since_approval                        AS "DAYS_SINCE_APPROVAL"
,coverage_additional_premium_amt                     AS "COV_ADL_PREM"
,replacement_type_cde                                AS "REPL_TYP"
,replacement_type_desc                               AS "REPL_DESC"
,ezap_policy_ind                                     AS "EZAPP_IND"
,sign_method_type_cde                                AS "SIGN_METH"
,soliciting_advisor_class_experience                 AS "EXP_LVL"
,AGCYDATA.agencyname                                 AS "AgencyName"
,AGCYDATA.region           							 AS "Region"
,AGCYDATA.agencydisplayname   						 AS "Firm Name"
,CASE
     WHEN AGCYDATA.met_indicator = 0 THEN 'Legacy'
     WHEN AGCYDATA.met_indicator = 1 THEN 'PCG'
END AS "PCG"   
,CASE
   WHEN HIER.prty_terr_rle_cd  = 'DI/LTCI PC EXTERNAL' THEN 'DI'
   WHEN HIER.prty_terr_rle_cd  = 'LIFE EXTERNAL'  THEN  'LIFE'
END AS "LOB_JOIN"
,product_id                                           AS "PROD_ID"
,PlacementAlgorithm.PreApvlScore                      AS "PlacementScore"
---
FROM 
(SELECT *
,RIGHT(merge_agency_id, 3)                "AGENCY"
,CAST(agreement_nr as int)                   "POLICY_NUMBER"
,source_soliciting_agency       "SRC_SOLICITING_AGY"
from edw_semantic_vw.sem_nb_pending_inventory_detail_vw)  INV
---
LEFT OUTER JOIN (
     SELECT 
         CAST(hldg_key AS INT) AS "PolicyNumber"
    --     ,score_dt as             "date_scored"
         ,pre_approval_score as   "PreApvlScore"
    --   ,post_approval_score as  "PostApvlScore" 
	 FROM edw_new_business_vw.nb_anltcs_placement_vw
     where nb_placement_to_dt  =  '9999-12-31 00:00:00.00000'
    ) PlacementAlgorithm ON INV.POLICY_NUMBER = PlacementAlgorithm.PolicyNumber
LEFT OUTER JOIN  dma.grp_dl_agencies AGCYDATA
ON INV.AGENCY = AGCYDATA.originalagencycode
LEFT OUTER JOIN 
(select 
 CAST(member_id as int)                              as member_id
,member_rle                                          as member_rle
,concat(concat(whlslr_lst_nm, ', '), whlslr_frst_nm) as whlslr_full_nm
,upper(prty_terr_rle_cd)                             as prty_terr_rle_cd
,upper(terr_division)                                as terr_division
,upper(terr_nm)                                      as terr_nm
,upper(terr_typ_cd)                                  as terr_typ_cd
from dma_vw.aft_whlslr_hier_vw)   HIER
ON INV.AGENCY = HIER.member_id
LEFT OUTER JOIN -- Determine max role for brokerage agencies
    (SELECT CAST(member_id as int) as member_id_int, MAX(upper(prty_terr_rle_cd)) AS MaxPartyRole
     FROM dma_vw.aft_whlslr_hier_vw
     WHERE member_id_int NOT IN -- brokerage agencies
    (SELECT DISTINCT CAST(member_id as int) FROM dma_vw.aft_whlslr_hier_vw
     WHERE member_rle = 'AGCY'
     AND upper(prty_terr_rle_cd) IN ('DI/LTCI PC EXTERNAL','ANNUITY EXTERNAL','LIFE EXTERNAL'))
     GROUP BY member_id_int)  BrokerageRole 
ON INV.AGENCY  = BrokerageRole.member_id_int
WHERE (member_rle = 'AGCY' AND prty_terr_rle_cd  IN ('DI/LTCI PC EXTERNAL', 'LIFE EXTERNAL') AND line_of_business_cde = LOB_JOIN) -- CAS agencies with expected wholesaler roles
OR(member_rle = 'AGCY' 
   AND AGENCY IN (BrokerageRole.member_id_int) -- Non-CAS agencies with max role found
   AND prty_terr_rle_cd = BrokerageRole.MaxPartyRole) 
OR AGENCY NOT IN    -- Brokerage agencies not even in the hierarchy   
   (SELECT DISTINCT CAST(member_id as int)
    FROM dma_vw.aft_whlslr_hier_vw
    WHERE member_rle = 'AGCY')
                   
UNION

SELECT 
AGENCY AS "Agency"
,underwriter_nm                AS "UW_FULL_NM"
,underwriting_team_nm          AS "UW_TEAM_NM"
,underwriting_team_cde         AS "UW_TEAM"
,case_manager_last_nm          AS "CM_LAST_NAME"
,case_manager_first_nm         AS "CM_FIRST_NAME"
,case_manager_team_nm          AS "CM_TEAM"
,case_manager_team_cde         AS "CM_TEAM_NAME"
,POLICY_NUMBER AS "Policy Number"
,line_of_business_cde          AS "LOB_FLAG"
,HIER.prty_terr_rle_cd         AS "PRTY_TERR_RLE_CD" 
,HIER.member_rle               AS "MEMBER_RLE"
,CASE 
  WHEN HIER.terr_division   LIKE ('%PCG%') THEN 'PCG'
  WHEN HIER.terr_division   LIKE ('%N/A%') THEN 'DDC'
  ELSE HIER.terr_division
END AS "DIVISION"
,HIER.terr_nm                  AS "TERR_NM"
,HIER.terr_typ_cd              AS "TERR_TYP_CD"
,HIER.member_id                AS "MEMBER_ID"
,submission_dt                 AS "SUBMIT_DATE" 
,application_approved_dt       AS "APPROVED_DATE"
,HIER.whlslr_full_nm           AS "WHLSLR_FULL_NM"
,CASE 
 WHEN HIER.whlslr_full_nm IN ('DI/LTC, UNASSIGNED','BROKERAGE, UNASSIGNED') THEN 'T&H' 
 WHEN HIER.whlslr_full_nm LIKE ('OPEN%') THEN SUBSTR(HIER.whlslr_full_nm, POSITION(',' IN HIER.whlslr_full_nm) + 2, LENGTH(HIER.whlslr_full_nm))
 ELSE SUBSTR(HIER.whlslr_full_nm,1,POSITION(',' IN HIER.whlslr_full_nm)-1) 
 END AS "WHLSLR_LST_NM"
,CASE 
    WHEN inventory_status_text = 'Submitted' THEN 'Submitted, Not Approved'
    ELSE inventory_status_text
 END AS "Inventory Status"
,CAST(prepaid_premium_ind as boolean)                AS "PREPAID_PREMIUM_IND"
,organization_business_type_cde                      AS "ORGANIZATION_BUSINESS_TYPE_CD"
,CAST(COALESCE(market_desc,'LTC') AS VARCHAR (20))   AS "Product"
,CASE  ---to  create common product hierarchy with Life/DI table. 
    WHEN organization_business_type_cde LIKE ('%Capital Vantage%')
    THEN 'Capital Vantage'
    WHEN organization_business_type_cde LIKE ('Transitions Select II')
    THEN 'Transition Select II'
    WHEN organization_business_type_cde LIKE ('%RetireEase Choice%')
    THEN 'RetireEase Choice'
    WHEN organization_business_type_cde LIKE ('%RetireEase%')
    THEN 'RetireEase'
    WHEN organization_business_type_cde LIKE ('%Stable Voyage%')
    THEN 'Stable Voyage'
    WHEN organization_business_type_cde LIKE ('%Odyssey Select%')
    THEN 'Odyssey Select'
    WHEN organization_business_type_cde LIKE ('MassMutual Transitions SELECT')
    THEN 'Transition Select' 
    WHEN organization_business_type_cde LIKE ('%MassMutual Evolution%')
    THEN 'Evolution'
    WHEN organization_business_type_cde LIKE ('%Artistry%')
    THEN 'Artistry'
    WHEN organization_business_type_cde LIKE ('%UltraCare Life%')
    THEN 'UltrCare'
    WHEN organization_business_type_cde LIKE ('%SignatureCare%')
    THEN 'SignatureCare'
    ELSE 'Unknown'
    END AS "Product Type"
,soliciting_agent_nm                                           AS "Advisor"
,COALESCE(salesmanager_broker_dealer_nm,'NO MANAGER')          AS "Sales Mgr/ Brokerage Director"
,calendar_days_since_approved                                  AS "CAL_DAYS_SINCE_APROVED"
,weighted_annual_premium_amt                                   AS "Weighted Premium"
,annual_premium_amt                                            AS "Base Annual Premium"
,estimated_first_year_commision_amt                            AS "Estimated FYC"
,applied_1035_as_premium_amt                                   AS "1035 Premium"
,face_amt                                                      AS "Face Amount"
,requirements_desc                                             AS "REQUIREMENTS"
,inventory_status_reason_text                                  AS "INVENTORY_REASON"
,calendar_days_since_submit                                    AS "CAL_DAYS_SINCE_SUBMIT"
,calendar_days_since_issued                                    AS "CAL_DAYS_SINCE_ISSUE"
,group_nr                                                      AS "GROUP_SRC_SYS_PRTY_ID"  
,group_nm                                                      AS "GROUP_SRC_SYS_PRTY_NM"
,insured_last_nm                                               AS "INS_LAST_NAME"
,total_annual_premium_amt                                      AS "AGMT_TOT_ANNUAL_PREM_AMT"
,soliciting_agent_source_system_party_id                       AS "SOLICITING_AGT_SRC_SYS_PRTY_ID"
,CASE
  WHEN AGCYDATA.distributionchannelcode IN ('DDC', 'SDP', 'MMSD', 'OTHR') THEN 'MMSD'
  WHEN soliciting_agent_type_cde = 'CAS' THEN 'CAS'
  WHEN soliciting_agent_type_cde = 'CAB' THEN 'CAB'
  ELSE 'Unknown'
END AS "AGY_CAS_IND"
,SRC_SOLICITING_AGY
,agreement_status_reason_cde                                 AS "AGMT_STUS_CD"
,application_issue_dt                                        AS "APPLICATION_ISSUE_DATE"
,CAST(top_blue_ind as boolean)                               AS "TOP_BLUE_IND"
,soliciting_agent_type_cde                                   AS "SOLICITING_AGT_TYP_CD"
,application_type_cde                                        AS "APPL_TYPE"
,CAST(graded_premium_ind as boolean)                         AS "GRD_PREM_IND"  
,CAST(days_since_approval_cnt as varchar)                    AS "DAYS_SINCE_APPROVAL"
,coverage_additional_premium_amt                             AS "COV_ADL_PREM"
,replacement_type_cde                                        AS "REPL_TYP"
,replacement_desc                                            AS "REPL_DESC"
,ezapp_ind                                                   AS "EZAPP_IND"
,electronic_signed_ind                                       AS "SIGN_METH"
,experience_lvl_desc                                         AS "EXP_LVL"
,AGCYDATA.agencyname                                         AS "AgencyName"
,AGCYDATA.region           				        			 AS "Region"
,AGCYDATA.agencydisplayname   					        	 AS "Firm Name"
,CASE
     WHEN AGCYDATA.met_indicator = 0 THEN 'Legacy'
     WHEN AGCYDATA.met_indicator = 1 THEN 'PCG'
END AS "PCG"   
,CASE
   WHEN HIER.prty_terr_rle_cd  = 'DI/LTCI PC EXTERNAL' THEN 'LTC'
   WHEN HIER.prty_terr_rle_cd  = 'ANNUITY EXTERNAL'  THEN  'ANN'
END AS "LOB_JOIN"
,product_id                                                  AS "PROD_ID"   ---may not be used in report, remove later.
,NULL AS                                                     "PlacementScore"
---
FROM 
(select *
,RIGHT(merge_agency_id, 3)                "AGENCY"
,CAST(agreement_nr AS INT)                   "POLICY_NUMBER"
,source_soliciting_agency_id    "SRC_SOLICITING_AGY"
FROM 
(SELECT *, ltrim(agreement_nr,'0') AS agreement_nr_var FROM edw_semantic_vw.sem_nb_pending_inventory_detail_ltc_annuity_vw) t1
)INV
---
LEFT OUTER JOIN  dma.grp_dl_agencies   AGCYDATA
ON INV.AGENCY = AGCYDATA.originalagencycode
---
LEFT OUTER JOIN 
(SELECT 
 CAST(member_id AS INT)                              AS member_id
,member_rle                                          AS member_rle
,concat(concat(whlslr_lst_nm, ', '), whlslr_frst_nm) AS whlslr_full_nm
,upper(prty_terr_rle_cd)                             AS prty_terr_rle_cd
,upper(terr_division)                                AS terr_division
,upper(terr_nm)                                      AS terr_nm
,upper(terr_typ_cd)                                  AS terr_typ_cd
FROM dma_vw.aft_whlslr_hier_vw)   HIER
ON INV.AGENCY = HIER.member_id
-----
LEFT OUTER JOIN -- Determine max role for brokerage agencies
    (SELECT CAST(member_id AS INT) AS member_id_int, MAX(upper(prty_terr_rle_cd)) AS MaxPartyRole
     FROM dma_vw.aft_whlslr_hier_vw
     WHERE member_id_int NOT IN -- brokerage agencies
    (SELECT DISTINCT CAST(member_id AS INT) FROM dma_vw.aft_whlslr_hier_vw
     WHERE member_rle = 'AGCY'
     AND upper(prty_terr_rle_cd) IN ('DI/LTCI PC EXTERNAL','ANNUITY EXTERNAL','LIFE EXTERNAL'))
     GROUP BY member_id_int)  BrokerageRole 
ON INV.AGENCY  = BrokerageRole.member_id_int
------
WHERE (member_rle = 'AGCY' 
       AND prty_terr_rle_cd  IN ('DI/LTCI PC EXTERNAL', 'ANNUITY EXTERNAL','LIFE EXTERNAL') 
       AND upper(line_of_business_cde) = LOB_JOIN) -- CAS agencies with expected wholesaler roles
----  -- Non-CAS agencies with max role found
OR(member_rle = 'AGCY' 
     AND AGENCY IN (BrokerageRole.member_id_int)
     AND prty_terr_rle_cd = BrokerageRole.MaxPartyRole) 
-----  -- Brokerage agencies not even in the hierarchy
OR AGENCY NOT IN    
   (SELECT DISTINCT CAST(member_id AS INT)
    FROM dma_vw.aft_whlslr_hier_vw
    WHERE member_rle = 'AGCY')
-----
OR  AGENCY IS NULL
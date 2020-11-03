SELECT  
		 MAJOR_PROD_NME AS ReviewTypeCode
		, ApplicationID AS OrderEntryID
		, AgencyNumber AS AgencyID
    , AgentID
    , PROD_TYP_NME AS Product
    , T2.IRSubmissionTypeName AS SubmissionType
    , T4.IRFundingTypeName AS FundingType
    , CASE WHEN PROD_TYP_NME LIKE '%RetireEase%' THEN 'Income Annuity'
           WHEN PROD_TYP_NME LIKE '%Index Horizons%' THEN 'Fixed Indexed'
           ELSE MAJOR_PROD_NME 
         END AS "Product Category"
    , CASE 
    		WHEN T3.IRReplacementTypeName IS NULL THEN 'N/A' 
    		ELSE T3.IRReplacementTypeName 
    	END AS ReplacementType
    , StateCode AS ResidencyState 
    , CASE 
    		WHEN SuitabilityIndicator = 0 THEN 'NIGO'
    		WHEN SuitabilityIndicator=1 THEN 'IGO'
    	END AS SuitabilityIGOIndicator
    , CASE 
   			WHEN OwnershipIndicator = 0 THEN 'Personal'
    		WHEN OwnershipIndicator = 1 THEN 'Business'
    	END AS OwnershipIndicator  
    , T10.EmployeeFirstName
    , T10.EmployeeLastName
    , T10.MMID
    , CreatedAtDateTimestamp AS CreatedAt
    ,Cast(CreatedAtDateTimestamp as Date) as "Created Date"
    , CASE 
    		WHEN IGOIndicator = 0 THEN 'NIGO'
    		WHEN IGOIndicator=1 THEN 'IGO'
    	END AS InitialReviewIndicator
    , T5.IRMarketTypeName
    , IRProductID

FROM    PROD_DMA_VW.ANB_IR_FORMS_VW T1
LEFT JOIN PROD_DMA_VW.ANB_IR_SUBMIT_TYPES_VW T2 ON T1.IRSubmissionTypeID = T2.IRSubmissionTypeID
LEFT JOIN PROD_DMA_VW.ANB_IR_REPL_TYPES_VW T3 ON T1.IRReplacementTypeID = T3.IRReplacementTypeID
LEFT JOIN PROD_DMA_VW.ANB_IR_FUND_TYPES_VW T4 ON T1.IRFundingTypeID = T4.IRFundingTypeID
LEFT JOIN PROD_DMA_VW.ANB_IR_MARKET_TYPES_VW T5 ON T1.IRMarketTypeID = T5.IRMarketTypeID
LEFT JOIN PROD_USIG_CMN_VW.PRODUCT_TRANSLATOR_VW T6 ON CAST(T1.IRProductID AS VARCHAR(20)) = T6.PROD_ID
LEFT JOIN PROD_DMA_VW.FIRM_DIM_VW T8 ON T1.AGENCYNUMBER = T8.ORIGINALFIRMCODE
LEFT JOIN PROD_USIG_STND_VW.PDCR_DEMOGRAPHICS_VW T9 ON T1.AGENTID = SUBSTR(TRIM(T9.BUSINESS_PARTNER_ID), CHARACTER_LENGTH(TRIM(T9.BUSINESS_PARTNER_ID)) - 5 FOR 6)  
LEFT JOIN PROD_DMA_VW.EMPLOYEE_PIT_DIM_VW T10 ON T1. CreatedByHRID = T10.HRID AND CAST(T1.CreatedAtDateTimestamp AS DATE) BETWEEN T10.StartDate AND T10.EndDate
ORDER BY T1.TRANSDATE DESC

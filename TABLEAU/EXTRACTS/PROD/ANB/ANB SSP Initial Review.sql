/*
* This routine pulls IR NIGO Review Entries
*  Peer Review & Change Log:
*  Peer Review Date:
*  Source for this routine is
*  Author: Zach Dorvay/Lorraine Christian
*  Created: 11/3/2020
* Revision by Lorraine:  Added IssueDateIsHoliday and BINGO Status (lines 48,50-52, 64 )
* Revision by Vince:  Removed several joins and added initial review id field.
======================================================================


======================================================================*/

SELECT  T1.ProductCategory AS ReviewTypeCode
    , ApplicationID AS OrderEntryID
    , T1.InitialReviewID
    , T1.AgencyNumber AS AgencyID
    , T1.AgentID
    , T1.Product
    , T2.IRSubmissionTypeName AS SubmissionType
    , T4.IRFundingTypeName AS FundingType
    , T12.ProductCategory
    , CASE WHEN T3.IRReplacementTypeName IS NULL THEN 'N/A'
            ELSE T3.IRReplacementTypeName
        END AS ReplacementType
    , StateCode AS ResidencyState
    , CASE WHEN SuitabilityIndicator = 0 THEN 'NIGO'
            WHEN SuitabilityIndicator=1 THEN 'IGO'
        END AS SuitabilityIGOIndicator
    , CASE WHEN OwnershipIndicator = 0 THEN 'Personal'
            WHEN OwnershipIndicator = 1 THEN 'Business'
        END AS OwnershipIndicator
    , T10.EmployeeFirstName
    , T10.EmployeeLastName
    , T10.MMID
    , CreatedAtDateTimestamp AS CreatedAt
    ,CAST(CreatedAtDateTimestamp AS DATE) AS "Created Date"
    , CASE WHEN IGOIndicator = 0 THEN 'NIGO'
            WHEN IGOIndicator=1 THEN 'IGO'
        END AS InitialReviewIndicator
    , T5.IRMarketTypeName
    , IRProductID
    , CAST(T12.IssueDate AS DATE) AS IssueDate
    , (SELECT IsHoliday FROM PROD_DMA_VW.DATE_DIM_VW WHERE T12.IssueDate = ShortDate) AS "IssueDateIsHoliday"
    , BINGOStatus
    , T12.Channel
    , NigoReason
FROM PROD_DMA_VW.ANB_IR_FORMS_VW T1
LEFT JOIN PROD_DMA_VW.ANB_IR_SUBMIT_TYPES_VW T2 ON T1.IRSubmissionTypeID = T2.IRSubmissionTypeID
LEFT JOIN PROD_DMA_VW.ANB_IR_REPL_TYPES_VW T3 ON T1.IRReplacementTypeID = T3.IRReplacementTypeID
LEFT JOIN PROD_DMA_VW.ANB_IR_FUND_TYPES_VW T4 ON T1.IRFundingTypeID = T4.IRFundingTypeID
LEFT JOIN PROD_DMA_VW.ANB_IR_MARKET_TYPES_VW T5 ON T1.IRMarketTypeID = T5.IRMarketTypeID
LEFT JOIN PROD_DMA_VW.EMPLOYEE_PIT_DIM_VW T10 ON T1. CreatedByHRID = T10.HRID AND CAST(T1.CreatedAtDateTimestamp AS DATE) BETWEEN T10.StartDate AND T10.EndDate
LEFT JOIN PROD_DMA_VW.ANB_APPLICATION_RPT_VW T12 ON T12.INITIALREVIEWID = T1.INITIALREVIEWID

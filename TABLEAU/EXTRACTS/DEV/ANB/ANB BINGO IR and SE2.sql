SELECT 
	BINGOType
	, PolicyNumber
	, AgreementID
	, OrderEntryID
	, InitialReviewID
	, Channel
	, Distributor
	, Product
	, ProductCategory
	, RegionName
	, ResidenceState
	, FirmNum
	, FirmName
	, AgentID
	, Advisor
	, DocType
	, MarketTypeCode
	, MarketTypeCategory
	, NIGOID
	, NIGOCategory
	, NIGOReason
	, FinalDisposition
	, NewBusinessSubmitDate
	, ApplicationSubmitDate
	, SuitabilityApprovalDate
	, PAWDate
	, TOADate
	, RejectDate
	, WithdrawnDate
	, IssueDate
	, NIGODate
	, CancelDate
	, ApprovedDate
	, NIGOResolvedDate
	, IRBINGODate
	, IRNIGODate
	, BINGOIndicator
	, NIGOResolution

FROM 
	(
		--SE2
		SELECT DISTINCT
			'SE2' AS BINGOType
			,PolicyNumber
			, T1.AGREEMENTID AS AgreementID
			, T1.OrderEntryID
			, CAST(NULL AS VARCHAR(100)) AS InitialReviewID
			, Channel
			, CASE WHEN Distributor = 'SDP' THEN 'MMSD' ELSE Distributor END AS Distributor
			, Product
			, ProductCategory
			, RegionName
			, CAST(ResidenceState AS VARCHAR(2)) AS ResidenceState
			, FirmNum
			, FirmName
		    , AgentID
			, Advisor
			, DocumentTypeCode AS "DocType"
			, CAST(NULL AS VARCHAR(20)) AS MarketTypeCode
			, CAST(NULL AS VARCHAR(23)) AS MarketTypeCategory
			, COALESCE(T1.AGREEMENTID, T1.POLICYNUMBER, T1.ORDERENTRYID) NIGOID
			, NIGOCategory
			, ReasonDescription AS "NIGOReason"
			, CASE WHEN RejectDate IS NOT NULL THEN 'Rejected'
					WHEN WithdrawnDate IS NOT NULL THEN 'Withdrawn'
					WHEN IssueDate IS NOT NULL THEN 'Issued'
		  		ELSE NULL END AS FinalDisposition
		  	, NewBusinessSubmitDate
			, CAST(NULL AS DATE) AS ApplicationSubmitDate
			, SuitabilityApprovalDate
			, PAWDate
			, TOADate
			, RejectDate
			, WithdrawnDate
			, IssueDate
			, NIGODate
			, CAST(NULL AS TIMESTAMP(6)) AS CancelDate
			, CAST(NULL AS TIMESTAMP(6)) AS ApprovedDate
			, NIGOResolvedDate
			, CAST(NULL AS DATE) AS IRBINGODate
			, CAST(NULL AS DATE) AS IRNIGODate
			, BINGOIndicator
			, (NIGOResolvedDate - NIGODate)  AS NIGOResolution
		
		FROM PROD_DMA_VW.ANB_APPLICATION_RPT_VW T1
		 
		LEFT JOIN (SELECT DISTINCT AGREEMENTID
		                            , ORDERENTRYID
		                            , CAST(MIN(NIGODate) OVER (PARTITION BY AGREEMENTID) AS DATE) AS NIGODate
		                            , MAX(NIGOResolutionDate) OVER (PARTITION  BY AGREEMENTID) AS NIGOResolvedDate
		                            , T2.NIGOCategory
		                            , ReasonDescription
		                            , DocumentTypeCode
		                        FROM PROD_DMA_VW.ANB_NIGO_FCT_VW T1
		                        INNER JOIN PROD_DMA_VW.ANN_NIGO_REASON_LOV_VW T2 ON T2.NIGOUUID = T1.NIGOUUID
		                        WHERE T1.SYSTEMID = 34
		                        AND GROUPTYPE LIKE 'NEW B%'
		                        AND NIGODATE >= '2019-01-01') T2 ON COALESCE(T1.AGREEMENTID, T1.ORDERENTRYID) = COALESCE(T2.AGREEMENTID, T2.ORDERENTRYID)
		                        
		UNION
		
		--IR
		SELECT DISTINCT
			'IR' AS BINGOType
			,PolicyNumber
			, AgreementID
			, T1.OrderEntryID
			, T1.InitialReviewID
			, Channel
			, CASE WHEN Distributor = 'SDP' THEN 'MMSD' ELSE Distributor END AS Distributor
			, Product
			, T1.ProductCategory
			, RegionName
			, T3.StateCode AS ResidenceState
			, FirmNum
			, FirmName
			, CAST(T3.AgentID AS VARCHAR(10)) AS AgentID
			, Advisor
			,CAST(NULL AS VARCHAR(255)) AS DocType
			, MarketTypeCode
			, MarketTypeCategory
			, CAST(NULL AS VARCHAR(255)) AS NIGOID
			, NIGOCategory
			, NIGOReason
			, CASE WHEN T2.REJECTDATE IS NOT NULL THEN 'Rejected'
					WHEN CANCELDATE IS NOT NULL THEN 'Canceled'
					WHEN APPROVEDDATE IS NOT NULL THEN 'Approved'
		  		ELSE NULL END AS FinalDisposition
		  	, NewBusinessSubmitDate
			, ApplicationSubmitDate
			, SuitabilityApprovalDate
			, PAWDate
			, TOADate
			, T2.RejectDate
			, CAST (NULL AS DATE) AS WithdrawnDate
			, CAST (NULL AS DATE) AS IssueDate
			, CAST(CreatedAtDateTimeStamp AS DATE) AS NIGODate
			, CancelDate
			, ApprovedDate
			, CAST(NULL AS DATE) AS NIGOResolvedDate
			, CASE WHEN NIGOREASON IS NULL THEN SUITABILITYAPPROVALDATE
					WHEN T1.PRODUCTCATEGORY = 'Variable Annuity' THEN CAST(COALESCE( PAWDATE, TOADATE) AS DATE)
		  		ELSE CAST(COALESCE(T2.REJECTDATE, CANCELDATE, APPROVEDDATE, PAWDATE, TOADATE, ISSUEDATE) AS DATE) END AS IRBINGODate
		  	, CAST(CreatedAtDateTimeStamp AS DATE) AS IRNIGODate
			, BINGOIndicator
			, (IRBINGODate - IRNIGODate) AS NIGOResolution

		FROM PROD_DMA_VW.ANB_APPLICATION_RPT_VW T1
		
		LEFT JOIN PROD_DMA_VW.IPIPELINE_ORDER_FCT_VW T2 ON T2.ORDERENTRYID = T1.ORDERENTRYID
		LEFT JOIN PROD_DMA_VW.ANB_IR_NIGO_REASON_TOKEN_VW T3 ON T3.INITIALREVIEWID = T1.INITIALREVIEWID
		WHERE T1.INITIALREVIEWID IS NOT NULL
		
		QUALIFY ROW_NUMBER() OVER(PARTITION BY T1.INITIALREVIEWID, NIGOREASON ORDER BY CREATEDATDATETIMESTAMP) = 1 
	) C1
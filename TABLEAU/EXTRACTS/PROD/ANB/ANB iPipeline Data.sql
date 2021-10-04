/*
FILENAME: ANB iPipeline Data
CREATED BY: Bill Trombley
LAST UPDATED:
CHANGES MADE:
*/

SELECT	OrderEntryID,
				OwnerFullName,
				OwnerFirstName,
				OwnerMiddleName,
				OwnerLastName,
				OwnerGovernmentID,
				AnnuitantFullName,
				AnnuitantFirstName,
				AnnuitantMiddleName,
				AnnuitantLastName,
				ProductType,
				ProductName,
				AgencyNumber,
				AgentID, 
				CarrierCode,
				CAST(ElectronicSubmitDate AS DATE) AS ElectronicSubmitDate,
				T3.IsHoliday AS IsHolidayElec,
				T3.IsWeekday AS IsWeekdayElec,
				CAST(SuitCompleteDateApproved AS DATE) AS SuitCompleteDateApproved,
				CAST(SuitCompleteDateTransmitted AS DATE) AS SuitCompleteDateTransmitted,
				T2.IsHoliday AS IsHolidaySuit,
				T2.IsWeekday AS IsWeekdaySuit,
				CAST(ApplicationStatusChangeDate AS DATE) AS ApplicationStatusChangeDate,
				TotalInitialPremium,
				ApplicationStatus,
				CopiedFromTransIdentifier,
				AutoApprovedIndicator,
				SRC_SYS_ID,
				T1.RUN_ID,
				UPDT_RUN_ID,
				TRANS_DT
FROM	PROD_DMA_VW.IPIPELINE_ORDERS_HIST_VW T1
LEFT JOIN 
	PROD_DMA_VW.Date_DIM_VW T2 ON T2.SHORTDATE = T1.SuitCompleteDateTransmitted
LEFT JOIN 
	PROD_DMA_VW.Date_DIM_VW T3 ON T3.SHORTDATE = T1.ElectronicSubmitDate

WHERE ElectronicSubmitDate IS NOT NULL   --Count for Katie's Team Work Received
 AND (CarrierCode = '65935' OR CarrierCode = '93432')
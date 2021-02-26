

Select T1.*
,Right(T1.HOLDINGKEY,10) as HoldingKeyCor
,t2.face_amount
--FunctionName,FunctionID, SegmentName,SegmentID
FROM PROD_DMA_VW.ACT_LAC_PIT_INTEGRATED_VW T1
Left Join PROD_USIG_STND_VW.AGMT_CMN_VW T2 on  T1.HOLDINGKEY = T2.Hldg_Key and T1.AgreementID = T2.Agreement_ID
WHERE  (WorkEventDepartmentID IN (8)
OR DepartmentID IN (8))
AND TransactionTypeID = 2
and ReportDate = Current_date
and FunctionID In (193,257)

--AND SequenceNumber = 1

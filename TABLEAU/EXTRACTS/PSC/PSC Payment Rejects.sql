SELECT	DISTINCT
TeamName	as "Team"
,SourceTransactionID	as "Work Identifier"
,LoggedDate as "Logged Date"
,ReceivedDate	as "Received Date"
,CompletedDate as "Completed Date"
,HoldingKey	as "Policy Number"
,WorkEventName	as "Work Event Name"
,WorkEventDepartmentID	 as "Department ID"
,coalesce(ManagerlastName || ',' || ManagerFirstName, 'Unknown') as "Manager"
,coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') as "Employee"
,GroupID
,GroupTypeID
,GroupName	as "Type"
,GroupTypeName as "Group Type"
,CASE WHEN "Group Type" = 'Payment Pool' THEN 1 ELSE 0 END	as "Payment Indicator"
,CASE WHEN "Group Type" = 'Reject Pool' THEN 1 ELSE 0 END	as "Reject Indicator"
,CASE WHEN SequenceNumber = '1' THEN 1 ELSE 0 END	as "Received Indicator"
,PendingIndicator
,CompletedIndicator
,CASE 
	WHEN "Payment Indicator" = 1 THEN ("Completed Date") 
	ELSE LoggedDateDIM.PreviousBusinessDay 
END as "Date"
FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW
LEFT JOIN PROD_DMA_VW.DATE_DIM_VW as LoggedDateDim
ON CAST(LoggedDate as DATE) = LoggedDateDIM.ShortDate
WHERE (("Reject Indicator" = 1 AND CompletedIndicator = 0 AND SequenceNumber = 1)
OR ("Payment Indicator" = 1 AND CompletedIndicator = 1))
AND "Team" IS NOT NULL
AND ("Department ID" = 4
OR DepartmentID =4)
AND GroupID IS NOT NULL
AND "Received Date" >= CURRENT_DATE - INTERVAL '5' YEAR
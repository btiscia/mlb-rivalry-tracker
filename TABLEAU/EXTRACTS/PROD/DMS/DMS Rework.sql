SELECT	
  T1.ID
, T1.ClientID AS "Client ID"
, T1.DocumentID AS "Document ID"
, T1.DocumentDate AS "Document Date"
, T1.ReworkQueueID AS "Rework Queue ID"
, T1.ReworkServiceChannelID AS "Rework Service Channel ID"
, T1.ReworkErrorSourceID AS "Rework Error Source ID"
, T1.ExcludeRequestIND AS "Exclude Request Ind"
, T1.DeleteImageIND AS "Delete Image Ind"
, T1.ResearchOnlyIND AS "Research Only Ind"
, T1.SEC_IND AS "SEC ind"
, T1.RequestDescription as "Request Description"
, T1.CreatedByID as "Created by ID"
, T1.CreatedDateTime AS "T1 Created Date Time"
, T8.PartyTypeName AS "Creator Party Type Name"
, T8.OrganizationName AS "Creator Organization Name"
, T8.DepartmentName AS "Creator Department Name"
, T8.TeamName AS "Creator Team Name"
, T8.RoleName AS "Creator Role Name"
, coalesce(T8.EmployeeLastName || ', ' || T8.EmployeeFirstName, 'Unknown') AS "Creator Employee Name"
, coalesce(T8.ManagerFirstName || ','  || T8.ManagerLastName, 'Unknown') AS "Creator Manager Name"
,  coalesce(T8.TeamLeadFirstName || ', ' ||  T8.TeamLeadLastName, 'Unknown') AS "CreatorTeamLead Name"
, T8.ParentTeamName AS "Creator Parent Team Name"
, T8.SiteName AS "Creator Site Name"
, T7.HRID
, T2.QueName AS "Que Name"
, T2.QueDescription AS "Que Description"
, T2.InternalIndicator AS "T2 Internal Indicator"
, T3.ChannelName AS "Channel Name"
, T3.ChannelDescription AS "Channel Description"
, T4.SourceName AS "Source Name"
, T4.SourceDescription AS "Souce Description"
, T4.CreatedDateTime AS "T4 Created Date Time"
, T4.UpdatedDateTime AS "Updated Date Time"
, T5.ReworkRequestID AS "Rework Request ID"
, T5.ReworkErrorReasonID AS "Rework Error Reason ID"
, T6.ReasonName AS "Reason Name"
, T6.ReasonDescription AS "Reason Description"
, T6.InternalIndicator AS "T6 Internal Indicator"
, T11.PartyTypeName AS "Error Party Type Name"
, T11.OrganizationName AS "Error Organization Name"
, T11.DepartmentName AS "Error Department Name"
, T11.TeamName AS "Error Team Name"
, T11.RoleName AS "Error Role Name"
, coalesce(T11.EmployeeLastName || ', ' ||  T11.EmployeeFirstName, 'Unknown') AS "Error Employee Name"
, coalesce(T11.ManagerFirstName || ', ' ||  T11.ManagerLastName, 'Unknown') AS "Error Manager Name"
, coalesce(T11.TeamLeadFirstName || ', ' || T11.TeamLeadLastName, 'Unknown')  AS "Error Team Lead Name"
, T11.ParentTeamName AS "Error Parent Team Name"
, T11.SiteName AS ErrorSiteName

FROM	DEV_DMA_VW.ReworkRequests_VW T1
JOIN DEV_DMA_VW.ReworkQueues_VW T2 ON T1.ReworkQueueID = T2.ID
LEFT JOIN DEV_DMA_VW.ReworkServiceChannels_VW T3 ON T1.ReworkServiceChannelID = T3.ID
LEFT JOIN DEV_DMA_VW.ReworkErrorSources_VW T4 ON T1.ReworkErrorSourceID = T4.ID
LEFT JOIN DEV_DMA_VW.ReworkRequestErrors_VW T5 ON T1.ID = T5.ReworkRequestID
LEFT JOIN DEV_DMA_VW.ReworkErrorReasons_VW T6 ON T6.ID = T5.ReworkErrorReasonID
LEFT JOIN DEV_DMA_VW.PARTY_EMPLOYEE_VW T7 ON T7.HRID = T1.CreatedByID
LEFT JOIN DEV_DMA_VW.EMPLOYEE_PIT_DIM_VW T8 ON T7.PartyEmployeeID = T8.PartyEmployeeID AND T8.StartDate <= T1.CreatedDateTime AND T8.EndDate >= T1.CreatedDateTime
LEFT JOIN DEV_DMA_VW.ReworkReqErrorUsers_VW T9 ON T9.ReworkRequestErrorID = T5.ID
LEFT JOIN DEV_DMA_VW.PARTY_EMPLOYEE_VW T10 ON T10.HRID = T9.UserHIID
LEFT JOIN DEV_DMA_VW.EMPLOYEE_PIT_DIM_VW T11 ON T10.PartyEmployeeID = T11.PartyEmployeeID AND T11.StartDate <= T9.CreatedDateTime AND T11.EndDate >= T9.CreatedDateTime
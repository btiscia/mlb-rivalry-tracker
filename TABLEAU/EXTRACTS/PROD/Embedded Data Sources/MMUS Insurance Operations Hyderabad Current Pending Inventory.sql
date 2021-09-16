SELECT *
FROM PROD_DMA_VW.CURR_PEND_VW
WHERE (EmployeeDepartmentID = 51
OR WorkEventDepartmentID = 51)
AND TeamName not in ('Data Management and CRM', 'Learning & Performance', 'Business Content Management & Communications')
SELECT *
FROM(
SELECT GracePeriod.[Policy Number]
      ,[Logged Date]
      ,[Issued Date]
      ,[Line of Business]
      ,[Contract State]
      ,[Resident State]
      ,[Product Type]
      ,[Face Amount]
      ,[Due Date]
      ,[Original Grace Date]
      ,[Original Prompt Reinstatement Date]
      ,[Ext Grace Period]
      ,[Ext Prompt Reinstatment]
      ,[Premium Amount]
      ,[Risk Class]
      ,[Issue Age]
      ,[Customer Age]
      ,[Gender]
      ,[Frequency]
      ,[DepartmentName]
      ,[Service Channel]
      ,[Advisor Notified]
      ,CPLT_IND.[CPLT_IND]
      ,HLDG_STUS.[Holding Status]
      ,ROW_NUMBER() OVER(PARTITION BY [Policy Number] Order BY [Policy Number]) As row_number
  FROM [RptgAndAnalytics].[Adhoc].[RT20_00002970_Grace_Period_Tracking] AS GracePeriod
  Left Join [RptgAndAnalytics].[Adhoc].[RT20_00002970_Work_Event_CPLT_IND] as CPLT_IND on GracePeriod.[WRK_IDENT] = CPLT_IND.[WRK_IDENT]
  Left Join [RptgAndAnalytics].[Adhoc].[RT20_00002970_HLDG_Stus] as HLDG_STUS on GracePeriod.[WRK_IDENT] = HLDG_STUS.[WRK_IDENT]
  ) AS rows
  Where row_number = 1
  --Where (GracePeriod.[Policy Number]  in (SELECT DISTINCT [Policy Number]  FROM [RptgAndAnalytics].[Adhoc].[RT20_00002970_Grace_Period_Tracking]))
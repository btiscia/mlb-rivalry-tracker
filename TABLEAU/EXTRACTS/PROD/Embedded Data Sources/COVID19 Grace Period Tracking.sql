SELECT[Logged Date]
      ,[Issued Date]
      ,[Line of Business]
      ,[Contract State]
      ,[Resident State]
      ,[Product Type]
      ,[Face Amount]
      ,[Policy Number]
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
      ,b.[CPLT_IND]
      ,Case when (((Select count([Policy Number]) From [RptgAndAnalytics].[Adhoc].[RT20_00002970_Grace_Period_Tracking] Where this.[Policy Number] = [Policy Number]) >= 2) and ([Resident State] in ('AK', 'DC', 'LA', 'MS', 'NJ', 'NC', 'OH', 'OR')) and ([Service Channel] = 'Internal' or [Service Channel] = 'System')) then 'Phone'
            when [Resident State] in ('AK', 'DC', 'LA', 'MS', 'NJ', 'NC', 'OH', 'OR') and ([Service Channel] = 'Internal' or [Service Channel] = 'System' or [Service Channel]='Comm Manager') then 'MM'
            when [Resident State] in ('AK', 'DC', 'LA', 'MS', 'NJ', 'NC', 'OH', 'OR') and ([Service Channel] = 'Phone' or [Service Channel] = 'Mail' or [Service Channel] = 'Internet' or [Service Channel] = 'E-Mail') then 'Phone'
            ELSE 'Not Mandated'
            END as 'Mandated?'
  FROM [RptgAndAnalytics].[Adhoc].[RT20_00002970_Grace_Period_Tracking] AS this
  Left Join [RptgAndAnalytics].[Adhoc].[RT20_00002970_Work_Event_CPLT_IND] as b on this.[WRK_IDENT] = b.[WRK_IDENT]
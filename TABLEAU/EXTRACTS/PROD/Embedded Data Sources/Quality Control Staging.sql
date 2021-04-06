SELECT  
       [QA Associate]
      ,[Policy]
      ,[Associate Name ]
      ,[Business Customer]
      ,[Transaction Name]
      ,[Source of Error]
      ,[Error Type]
      ,[Amount]
      ,[Dollars Protected]
      ,[Line of Business]
      ,[Date]
  FROM [LifeNewBizReporting].[dbo].[RPT_stgQCDashboard]
  WHERE [DATE] > CONVERT(DATE,  '2016-12-31')
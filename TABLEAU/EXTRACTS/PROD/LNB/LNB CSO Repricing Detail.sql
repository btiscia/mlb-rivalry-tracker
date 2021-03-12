SELECT [SYSTEM]
      ,[Policy #]
      ,FF.[Agency] AS Firm
	  ,CASE 
		  WHEN AgencyDisplayName IS NOT NULL THEN AgencyDisplayName
		  ELSE 'UNKNOWN' 
	   END AS FirmName
      ,[WORK Team]
	  ,CASE
	     WHEN [Prod Driv Team] IN ('CA Brokerage','CAB') THEN 'CAB'
	     WHEN [Prod Driv Team] IN ('Brokrge','DBS') THEN 'Direct Brokerage'
	     ELSE 'Career'
	  END AS Channel
	  ,CASE
		  WHEN Region IS NOT NULL THEN Region
		  ELSE 'UNKNOWN' 
       END AS Region 
      ,CASE 
	    WHEN [Repl TYPE] IS NOT NULL THEN [Repl TYPE]
		WHEN [Repl TYPE] IS NULL AND Replacement = 'Y' THEN 'Repl - Unknown Type'
		WHEN Replacement = 'N' THEN 'Not a Replacement'
	 END AS ReplacementType
      ,[Weighted Premium]
      ,[Amt AT Risk]
      ,[Face Amount]
      ,[Plan Code]
      ,CASE
	     WHEN [Product TYPE] = 'UL/VL' AND [Plan Code] LIKE '%VUL%' THEN 'VL'
		 WHEN [Product TYPE] = 'UL/VL' AND [Plan Code] NOT LIKE '%VUL%' THEN 'UL'
		 WHEN [Plan Code] LIKE 'CC%' THEN 'CareChoice One'
		 ELSE [Product TYPE]
       END AS ProductGroup
	  ,[Product TYPE] AS ProductMajorGroup
      ,FF.[CURRENT Status]
	  ,[Placement Status]
	  ,[Inventory Status]
	  --,CASE 
	  --   WHEN [Issue Dt] IS NOT NULL AND [Issue Dt] <= '2019-12-31' THEN 'Yes'
		 --WHEN [Issue Dt] IS NULL OR [Issue Dt] > '2019-12-31' THEN 'No'
		 --ELSE 'Not Issued'
	  -- END AS IssuedByDeadline
	   ,CASE
          WHEN [Placement Status]<>'Still Pending' AND (CAST([Cur Status Dt] AS DATE)<='2019-12-31'--closed prior to deadline
				OR CAST([Cur Status Dt] AS DATE)>'2019-12-31' AND CAST([Issue Dt] AS DATE)<='2019-12-31') THEN 'Yes'--closed after deadline, but issued before deadline
          WHEN [Placement Status]<>'Still Pending' AND CAST([Cur Status Dt] AS DATE)>'2019-12-31' AND (CAST([Issue Dt] AS DATE)>'2019-12-31' OR [Issue Dt] IS NULL) THEN 'No' --closed/issued after deadline (or issue date null)
          WHEN [Placement Status]='Still Pending' AND CAST([Issue Dt] AS DATE)<='2019-12-31' THEN 'Yes' --still pending issued before deadline
          WHEN [Placement Status]='Still Pending' AND ([issue dt] IS NULL OR CAST([Issue Dt]AS DATE)>'2019-12-31') THEN 'No'  --still pending, issue date null or after deadline=5181
        END AS IssuedByDeadline

	  ,CASE
          WHEN [Placement Status]<>'Still Pending' AND CAST([Cur Status Dt] AS DATE)<='2020-01-31' THEN 'Yes'
          WHEN [Placement Status]<>'Still Pending' AND CAST([Cur Status Dt] AS DATE)>='2020-02-01' THEN 'No'
          WHEN [Placement Status]='Still Pending' AND CAST(GETDATE() AS DATE)>='2020-02-01' THEN 'No'
          ELSE NULL
        END AS ReportedByDeadline

      ,[Cur Status Dt]
      ,[App SIGN DATE]
      ,[Submit DATE]
      ,[App Recvd DATE]
      ,[Apvd Dt]
      ,[Incp Dt]
      ,[Decl Dt]
      ,[Wdrn Dt]
      ,[Issue Dt]
      ,[Rptd Dt]
      ,[ADE-Issue]
      ,[App Recv - Issue]
      ,[Cal ADE-Issue]
      ,[Cal App Recv - Issue]
      ,[App TYPE]
      ,[CM ID]
      ,[CM Name]
      ,[CM Team]
      ,[UW ID]
      ,[UW Name]
      ,[UW Team]
      ,[LTC Rider]
      ,[ANY Rider?]
      ,[$ ON CASE] AS Prepaid
      ,[Risk CLASS]
      ,[Tobacco CLASS]
      ,[Rated]
      ,[Contract State]
      ,[INS LAST Name]
      ,[Insured Age]
      ,[EZ App]
      ,[EZ App e-SIGN]
      ,[LARGE CASE Ind]
      ,[Agent ID] AS AdvisorID
      ,[Prod LAST Name] + ', ' + [Prod FIRST Name] AS AdvisorName

  FROM [LifeNewBizLegacy].[dbo].[tblWRTPPCycleTimeProductivityHistory] FF

  LEFT OUTER JOIN LifeNewBizDataStaging.dbo.AgencyTeamAlignment AgyTeam ON FF.[Agency] = AgyTeam.Agency

  LEFT OUTER JOIN [RptgAndAnalytics].[Reference].[LifeStatusDescriptions] Sts ON FF.[CURRENT Status] = Sts.[CURRENT Status]

  LEFT OUTER JOIN [RptgAndAnalytics].[Reference].[Agencies] Agy ON FF.Agency = Agy.[OriginalAgencyCodeW_Prefix]

  WHERE
  
  ( /* Recently Active Cases */

      [Cur Status Dt] >= '2019-08-01' 
	  AND [Policy #] NOT LIKE '13%'
	  AND [Policy #] <> '22858837'
	  AND (
	     ([Product TYPE] = 'WL' AND [Submit DATE] <= '2019-11-22')
		    OR
		 ([Product TYPE] = 'UL/VL' AND [Plan Code] LIKE '%VUL%' AND [Submit DATE] <= '2019-12-06')
		    OR
		 ([Product TYPE] = 'UL/VL' AND [Plan Code] NOT LIKE '%VUL%' AND [Submit DATE] <= '2019-11-22')
		  )

   )

   OR 

   /* All Pending Cases */
   ( 
      [Submit DATE] >= '2018-09-01' 
	  AND [Policy #] NOT LIKE '13%'
	  AND [Policy #] <> '22858837'
	  AND Sts.[Placement Status] = 'Still Pending'
	  AND (
	     ([Product TYPE] = 'WL' AND [Submit DATE] <= '2019-11-22')
		    OR
		 ([Product TYPE] = 'UL/VL' AND [Plan Code] LIKE '%VUL%' AND [Submit DATE] <= '2019-12-06')
		    OR
		 ([Product TYPE] = 'UL/VL' AND [Plan Code] NOT LIKE '%VUL%' AND [Submit DATE] <= '2019-11-22')
		  )
  )
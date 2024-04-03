/*
FILENAME: DNB Daily Reporting
UPDATED BY: Bill Trombley
LAST UPDATED: 4/3/2024
CHANGES MADE: 6/7/2023 - Vertica Migration, OSDT3-4818 - Update Daily Submit Logic
4/3/2024 - Limited time frame of pull to 3 years
*/

SELECT 
	[Submit Date]
	,[App Capture Date]
	,[IR Start Date]
	,[IR Complete Dt]
	,[Issue Date]
	,[First FA Date]
	,[First FA]
	,[Policy #]
	,[Base Benefit]
	,[Base Benefit Band]
	,[Premium]
	,[Risk Class]
	,[Team]
	,[Current Status]
	,[Current Status Date]
	,[Case Status]
	,[Case Status Date]
	,[UW Type]
	,[UW Name]
	,[UW ID]
	,[CM Name]
	,[CM ID]
	,[Market]
	,[App Type]
	,[Contract State]
	,[Firm]
	,[Firm Name]
	,[Soliciting Advisor]
	,[Soliciting Advisor Name]
	,[Soliciting Advisor Type]
	,[Society 1851]
	,[Bingo Ind]
	,[Insured Last Name]
	,[Issue Age]
	,[Express DI]
	,[Product]
	,[Case Type]
	,[Occupation]
	,[Occupation Class]
	,[Concurrent Indicator]
	,[PendingBusDays]
	,[PendingCalDays]
	,[BusDaystoIRComplete]
	,[CalDaystoIRComplete]
	,[BusDaystoIssue]
	,[CalDaystoIssue]
	,[BusDaystoFirstFA]
	,[CalDaystoFirstFA]
	,CASE 
		WHEN PendingBusDays <= 7 THEN '0-7'
		WHEN PendingBusDays > 7 AND PendingBusDays <= 14 THEN '8-14'
		WHEN PendingBusDays > 14 AND PendingBusDays <= 21 THEN '15-21'
		WHEN PendingBusDays > 21 AND PendingBusDays <= 30 THEN '22-30'
		WHEN PendingBusDays > 30 AND PendingBusDays <= 60 THEN '31-60'
		WHEN PendingBusDays > 60 AND PendingBusDays <= 90 THEN '61-90'
		WHEN PendingBusDays > 90  THEN '91+'
		ELSE 'N/A' 
	END AS [BusDaysSinceADEBand]
	,CASE 
		WHEN PendingCalDays <= 7 THEN '0-7'
		WHEN PendingCalDays > 7 AND PendingCalDays <= 14 THEN '8-14'
		WHEN PendingCalDays > 14 AND PendingCalDays <= 21 THEN '15-21'
		WHEN PendingCalDays > 21 AND PendingCalDays <= 30 THEN '22-30'
		WHEN PendingCalDays > 30 AND PendingCalDays <= 60 THEN '31-60'
		WHEN PendingCalDays > 60 AND PendingCalDays <= 90 THEN '61-90'
		WHEN PendingCalDays > 90  THEN '91+'
		ELSE 'N/A' 
	END AS [CalDaysSinceADEBand]
	,[PlacementStatus]
	,[DaystoFinalStatus]
	,[InventoryIndicator]
	,[CC Policy Ind]
	,[NB Policy Ind]
	,[App Sign Date]
	,[Approved Date]
	,[Reported Date]
	,CAST([SignedReceived] AS INTEGER) AS [SignedReceived]
	,CAST([ReceivedApproved] AS INTEGER) AS [ReceivedApproved]
	,CAST([SignedIssued] AS INTEGER) AS [SignedIssued]
	,CAST([ApprovedIssued] AS INTEGER) AS [ApprovedIssued]
	,CAST([IssuedReported] AS INTEGER) AS [IssuedReported]
	,CAST([SignedReported] AS INTEGER) AS [SignedReported]
	,ReceivedApprovedFiveDayBand = (SELECT FiveDayBand FROM LifeNewBizReporting.dbo.[LNB_CycleTimeBandsLOV] WHERE ReceivedApproved = CycleTimeDay)
	,[Pyramid Indicator]
FROM
	(
		SELECT DISTINCT a.[Submit Date]
		,a.[App Capture Date]
		,a.[IR Start Date]
		,a.[IR Complete Dt]
		,a.[Issue Date]
		,a.[First FA Date]
		,a.[First FA]
		,a.[Policy #]
		,a.[Base Benefit]
		,CASE 
			WHEN a.[Base Benefit] <= 5000 THEN '$0 - $5,000'
			WHEN a.[Base Benefit] BETWEEN 5001 AND 7500 THEN '$5,001 - $7,500'
			WHEN a.[Base Benefit] BETWEEN 7501 AND 10000 THEN '$7,501 - $10,000'
			WHEN a.[Base Benefit] BETWEEN 10001 AND 15000 THEN '$10,001 - $15,000'
			ELSE '$15,001+'
		END AS 'Base Benefit Band'
		,a.Premium
		,a.[Risk Class]
		,CASE 
			WHEN b.Team IS NULL THEN 'Other'
			WHEN b.Team = '' THEN 'Other'
			ELSE b.Team
		END AS 'Team'
		,a.[Cur Status] AS 'Current Status'
		,a.[Cur Status Date] AS 'Current Status Date'
		,a.[Case Status]
		,a.[Case Status Date]
		,a.[UW Type]
		,a.[UW Name]
		,a.[UW ID]
		,a.[Specialist Name] AS 'CM Name'
		,a.[Specialist ID] AS 'CM ID'
		,a.Market
		,a.[App Type]
		,a.[Contract State]
		,a.Agency AS 'Firm'
		,d.AgencyDisplayName AS 'Firm Name'
		,a.[Soliciting Agt #] AS 'Soliciting Advisor'
		,a.[Soliciting Agt Name] AS 'Soliciting Advisor Name'
		,a.[Soliciting Agt Type] AS 'Soliciting Advisor Type'
		,a.Masters AS 'Society 1851'
		,a.[Bingo Ind]
		,a.[Ins Last Name] AS 'Insured Last Name'
		,a.[Issue Age]
		,CASE 
			WHEN a.EZIssue = 1 THEN 'Yes'
			WHEN a.EZISSUE = 0 THEN 'No'
			ELSE 'Null'
		END AS 'Express DI'
		,a.Product
		,'New Business' AS [Case Type]
		,a.[Occ Class] AS 'Occupation Class'
		,a.Occupation
		,CASE 
			WHEN c.[Concur Date] IS NOT NULL THEN 'Yes'
			ELSE 'No'
		END AS 'Concurrent Indicator'
		,CASE 
			WHEN a.[App Capture Date] IS NOT NULL THEN (
				SELECT COUNT(*) 
				FROM LifeNewBizData.dbo.HolidayCalendar 
				WHERE isHoliday = 0 
				AND isWeekday = 1 
				AND dt >= a.[App Capture Date] 
				AND dt < GETDATE())
			ELSE (
				SELECT COUNT(*) 
				FROM LifeNewBizData.dbo.HolidayCalendar 
				WHERE isHoliday = 0
				AND isWeekday = 1 
				AND dt >= a.[Submit Date] 
				AND dt < GETDATE())
		END AS PendingBusDays
		,CASE 
			WHEN (a.[Submit Date] IS NOT NULL) OR (a.[Submit Date] <> '1900-01-01') THEN DATEDIFF(Day,a.[Submit Date],GETDATE()) +1
			ELSE DATEDIFF(Day,a.[App Capture Date],GETDATE()) +1
		END AS PendingCalDays
		,CASE 
			WHEN (a.[Submit Date] IS NOT NULL) OR (a.[Submit Date] <> '1900-01-01') THEN (
				SELECT COUNT(*) 
				FROM LifeNewBizData.dbo.HolidayCalendar 
				WHERE isHoliday = 0 
				AND isWeekday = 1 
				AND dt >= a.[App Capture Date] 
				AND dt < a.[IR Complete Dt])
			ELSE (
				SELECT COUNT(*) 
				FROM LifeNewBizData.dbo.HolidayCalendar 
				WHERE isHoliday = 0 
				AND isWeekday = 1 
				AND dt >= a.[Submit Date] 
				AND dt < a.[IR Complete Dt])
		END AS BusDaystoIRComplete
		,CASE 
			WHEN (a.[Submit Date] IS NOT NULL) OR (a.[Submit Date] <> '1900-01-01') THEN DATEDIFF(Day,a.[App Capture Date],a.[IR Complete Dt])
			ELSE DATEDIFF(Day,a.[Submit Date],a.[IR Complete Dt])
		END AS CalDaystoIRComplete
		,CASE 
			WHEN (a.[Issue Date] IS NOT NULL) OR (a.[App Capture Date] IS NOT NULL) THEN (
				SELECT COUNT(*) 
				FROM LifeNewBizData.dbo.HolidayCalendar 
				WHERE isHoliday = 0 
				AND isWeekday = 1 
				AND dt >= a.[App Capture Date] 
				AND dt < a.[Issue Date])
			ELSE (
				SELECT COUNT(*) 
				FROM LifeNewBizData.dbo.HolidayCalendar 
				WHERE isHoliday = 0 
				AND isWeekday = 1 
				AND dt >= a.[Submit Date] 
				AND dt < a.[Issue Date])
		END AS BusDaystoIssue
		,CASE 
			WHEN (a.[Issue Date] IS NOT NULL) OR (a.[App Capture Date] IS NOT NULL) THEN DATEDIFF(Day,a.[App Capture Date],a.[Issue Date])
			ELSE DATEDIFF(Day,a.[Submit Date],a.[Issue Date])
		END AS CalDaystoIssue
		,CASE 
			WHEN a.[App Capture Date] IS NOT NULL THEN (
				SELECT COUNT(*) 
				FROM LifeNewBizData.dbo.HolidayCalendar 
				WHERE isHoliday = 0 
				AND isWeekday = 1 
				AND dt >= a.[App Capture Date] 
				AND dt < a.[First FA Date])
			ELSE (
				SELECT COUNT(*) 
				FROM LifeNewBizData.dbo.HolidayCalendar 
				WHERE isHoliday = 0 
				AND isWeekday = 1 
				AND dt >= a.[Submit Date] 
				AND dt < a.[First FA Date])
		END AS BusDaystoFirstFA
		,CASE 
			WHEN a.[App Capture Date] IS NOT NULL THEN DATEDIFF(Day,a.[App Capture Date],a.[First FA Date])
			ELSE DATEDIFF(Day,a.[Submit Date],a.[First FA Date])
		END AS CalDaystoFirstFA
		,CASE 
			WHEN a.[Cur Status] LIKE 'APPR%' THEN 'Placed'
			WHEN a.[Cur Status] LIKE 'DECL%' THEN 'Declined'
			WHEN a.[Cur Status] LIKE 'NOT TAKEN%' THEN 'Not Taken'
			WHEN a.[Cur Status] LIKE 'POSTP%' THEN 'Postpone'
			WHEN a.[Cur Status] LIKE 'WITH%' THEN 'Withdrawn'
			ELSE 'Still Pending' 
		END AS [PlacementStatus]
		,DATEDIFF(Day,a.[Submit Date],a.[Cur Status Date]) AS DaystoFinalStatus
		,CASE 
			WHEN a.[Case Status] IN ('AWAIT MIB','Await Transmit','SUBMIT','SUBMIT/E-ISSUE','SUBMIT/U-ISSUE','SUBMIT/U-UNDER') THEN 1
			ELSE 0
		END AS [InventoryIndicator]
		,0 AS 'CC Policy Ind'
		,1 AS 'NB Policy Ind'
		,a.[App Sign Date]
		,a.[Apvd Date] AS 'Approved Date'
		,a.[Reported Date]
		,CASE 
			WHEN a.[App Capture Date] IS NOT NULL 
			AND a.[App Capture Date] <= a.[First FA Date] 
			AND a.[App Sign Date] IS NOT NULL
			AND a.[App Sign Date] <= a.[First FA Date] 
			AND a.[App Sign Date] <= a.[App Capture Date]
			THEN DateDiff(dd,a.[App Sign Date],a.[App Capture Date]) 
		END AS 'SignedReceived'
		,CASE
			 WHEN a.[App Capture Date] IS NOT NULL 
			AND a.[App Capture Date] <= a.[First FA Date] 
			AND a.[App Capture Date]<=a.[Apvd Date]
			AND a.[Apvd Date] IS NOT NULL
			THEN DateDiff(dd,a.[App Capture Date],a.[Apvd Date]) 
		END AS 'ReceivedApproved'
		,CASE 
			WHEN a.[App Sign Date] IS NOT NULL 
			AND a.[App Sign Date] <= a.[First FA Date] 
			AND a.[App Sign Date]<=a.[Apvd Date]
			AND a.[Issue Date] IS NOT NULL
			THEN DateDiff(dd,a.[App Sign Date],a.[Issue Date]) 
		END AS 'SignedIssued'
		,CASE 
			WHEN a.[Apvd Date] IS NOT NULL 
			AND a.[Apvd Date] <= a.[Issue Date] 
			AND a.[Issue Date] IS NOT NULL
			THEN DateDiff(dd,a.[Apvd Date],a.[Issue Date]) 
		END AS 'ApprovedIssued'
		,DateDiff(dd,a.[Issue Date],a.[Reported Date]) AS 'IssuedReported'
		,DateDiff(dd,a.[App Sign Date],a.[Reported Date]) AS 'SignedReported'
		,CASE 
			WHEN e.BusPrcsCode = '0171' THEN 'Y' 
			ELSE 'N' 
		END AS 'Pyramid Indicator'
		FROM [LifeNewBizDataStaging].[dbo].[DINewBusinesReportingFile] a
		LEFT JOIN LifeNewBizDataStaging.dbo.DITeamName b ON a.[UW ID] = b.MMID
		LEFT JOIN LifeNewBizDataStaging.dbo.DIAndLifeConcur c ON a.[Policy #] = c.[Policy #] AND c.LOB = 'DI'
		LEFT JOIN [RptgAndAnalytics].[Reference].[Agencies] d ON a.Agency = d.AgencyCode
		LEFT JOIN [LifeNewBizDataStaging].[dbo].[DIPyramidIndicator] e ON a.[Policy #] = e.PolicyNum
		WHERE a.[Submit Date] >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE())-2, 0)
		
		UNION
	
		SELECT DISTINCT
			[STRT_DATE] AS [Submit Date]
			,NULL AS [App Capture Date]
			,NULL AS [IR Start Date]
			,NULL AS [IR Complete Dt]
			,NULL AS [Issue Date]
			,NULL AS [First FA Date]
			,NULL AS [First FA]
			,[Policy Num] AS [Policy #]
			,NULL AS [Base Benefit]
			,NULL AS [Base Benefit Band]
			,[Adv Prem Paymmnt] AS Premium
			,NULL AS [Risk Class]
			,Team AS Team
			,[Case Type] AS [Current Status]
			,[STRT_DATE] AS [Current Status Date]
			,[Case Type] AS [Case Status]
			,[STRT_DATE] AS [Case Status Date]
			,'Fully U/W' AS [UW Type]
			,Underwriter AS [UW Name]
			,[MMID] AS [UW ID]
			,NULL AS [CM Name]
			,NULL AS [CM ID]
			,NULL AS Market
			,[Case Type] AS [App Type]
			,NULL AS [Contract State]
			,RIGHT('000'+ CAST(CAST(DIInv.Agency AS INTEGER) - 700 AS VARCHAR(3)), 3) AS [Firm]
			,Agy.AgencyDisplayName AS [Firm Name]
			,[Servicing Agent] AS [Soliciting Advisor]
			,AdvisorName AS [Soliciting Advisor Name]
			,AdvisorType AS [Soliciting Advisor Type]
			,CASE WHEN Team = 'Soc 1851' THEN 'Yes' ELSE 'No' END AS [Society 1851]
			,NULL AS [Bingo Ind]
			,[Last Name] AS [Insured Last Name]
			,[Issue Age] AS [Issue Age]
			,NULL AS [Express DI]
			,NULL AS Product
			,[Case Type] AS [Case Type]
			,NULL AS Occupation
			,NULL AS [Occupation Class]
			,NULL AS [Concurrent Indicator]
			,[Bus Days Pend] AS PendingBusDays
			,DATEDIFF(Day,[STRT_DATE],GETDATE()) +1 AS PendingCalDays
			,NULL AS BusDaystoIRComplete
			,NULL AS CalDaystoIRComplete
			,NULL AS BusDaystoIssue
			,NULL AS CalDaystoIssue
			,NULL AS BusDaystoFirstFA
			,NULL AS CalDaystoFirstFA
			,NULL AS PlacementStatus
			,NULL AS DaystoFinalStatus
			,1 AS InventoryIndicator
			,CASE WHEN [Case Type] = 'New Business' THEN 0 ELSE 1 END AS [CC Policy Ind]
			,CASE WHEN [Case Type] = 'New Business' THEN 1 ELSE 0 END AS [NB Policy Ind]
			,[App Sign Date]
			,NULL AS [Reported Date]
			,NULL AS [SignedReceived]
			,NULL AS [ReceivedApproved]
			,NULL AS [SignedIssued]
			,NULL AS [ApprovedIssued]
			,NULL AS [IssuedReported]
			,NULL AS [SignedReported]
			,[App Sign Date]
			,NULL AS [Pyramid Indicator]
		FROM LifeNewBizDataStaging.dbo.DIPendingInventory DIInv
		LEFT OUTER JOIN [LifeNewBizDataStaging].[dbo].[DINewBusinesReportingFile] DIFF 
			ON [Policy Num] = [Policy #]
			AND [Submit Date] >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE())-2, 0)
		LEFT JOIN [RptgAndAnalytics].[Reference].[Agencies] Agy 
			ON RIGHT('000'+ CAST(CAST(DIInv.Agency AS INTEGER) - 700 AS VARCHAR(3)), 3) = Agy.AgencyCode
		LEFT JOIN LifeNewBizDataStaging.dbo.DITeamName DITeam ON DIInv.Underwriter = DITeam.Full_Name
		LEFT JOIN (
			SELECT DISTINCT
				[Soliciting Agt #]
				,MAX([Soliciting Agt Name]) AS AdvisorName
				,MAX([Soliciting Agt Type]) AS AdvisorType
			FROM [LifeNewBizDataStaging].[dbo].[DINewBusinesReportingFile]
			GROUP BY [Soliciting Agt #]) Advisors 
				ON DIInv.[Servicing Agent] = Advisors.[Soliciting Agt #]
		WHERE [Case Type] = 'Contract Change'
			AND [Final Action Type] IS NULL	
			AND [STRT_DATE] >= DATEADD(yy, DATEDIFF(yy, 0, GETDATE())-2, 0)
	) AS PolicyDetails
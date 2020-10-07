/*
* This routine pulls daily time 
*  Peer Review & Change Log:
*  Peer Review Date: 
*  Source for this routine is PROD_DMA_VW.ACT_ADO_PIT_INTEGRATED_VW
*  Author: Lorraine Christian 2/19/2020
* Revised:  4/1/2020 – Completed Flag removed and replaced with Completed Indicator.  Follow up date added - LC
*Revised: 7/9/2020 - Removed holiday field and left join to date dim to improve query efficiency -KC
*/

SELECT TransactionTypeName AS "Transaction Type"
,SourceActivityID AS "ActivityID"
,T1.SourceTransactionID AS "Source Transaction ID"
,HoldingKey AS "Policy Number"
,ItemCount AS "Transaction Count"
,CASE 
     WHEN TRANSACTIONTYPEID = 1 THEN  Cast(ReceivedDate AS TIMESTAMP(6))
     WHEN TRANSACTIONTYPEID = 2 THEN Cast(LoadDate AS TIMESTAMP(6))
     WHEN TRANSACTIONTYPEID = 3 THEN LongCompletedDate
END AS "Date"    
,LoggedDate AS "Logged Date"
,Coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') AS "Employee"    
,Coalesce(ManagerlastName || ', ' || ManagerFirstName, 'Unknown') AS "Manager"
,EmployeeRoleName AS "Employee Role Name"
,TeamName    AS "Team Name"
,FunctionName    AS "Function Name"
,SegmentName    AS "Segment Name"
,WorkEventName    AS "Work Event Name"
,PriorityId AS "Priority"    -- all other marts call this field "priority"
,AdminSystemID AS "Admin System"     -- all other marts call this field "adminsystem
,SystemName AS "System Name"
,ServiceChannelName    AS "Service Channel Code"
,PartyTypeName    AS "Party Type Name"
,SiteName AS "Site Name"
,WorkEventNumber    AS "Work Event Number"
,T1.ExpectedCompletedDate AS "Expected Completed Date"
--, Count(IsHoliday) as Holidays   --removed to improve query efficiency, using DaysPastTAT field instead 
,TAT
,DaysPastTAT AS "Days Past TAT"
,MetExpectedIndicator AS "Met Expected Indicator"
,MetExpected AS "Met Expected"
--,CurrentProdCredit AS "Productivity Credits"  removed 4/29/2020 replaced with case statement below
, CASE
            WHEN SrcSysID = 24 THEN ProdCredit
            ELSE CurrentProdCredit
            END AS "Productivity Credits"
,NIGODescription
,NIGOCode AS "NIGO Code"
,IGOIndicator AS "IGO Indicator"
,FlexIndicator AS "Flex Indicator"
,ActionableIndicator AS "Actionable Indicator"
/*Completed flag not used on the dash.  Removed and replaced by Completed Indicator
,CASE WHEN SourceTransactionID IS NULL THEN 0
    ELSE 1
END AS "Completed Flag"*/
,CompletedIndicator AS "Completed Indicator"
,ShortComment AS "Comments"
,T1.TransDate AS "Trans Date"
,T1.AdminSystemCode AS "Admin System Code"
,CASE 
		WHEN MajorProductName IS NULL AND PrimaryLogID IN (6, 10) THEN 'Unknown'
        WHEN MajorProductName IS NULL AND PrimaryLogID NOT IN (6, 10) THEN NULL
        ELSE MajorProductName
        END AS "Contract Type"
,CATSExpectedCompletedDate AS "Follow Up Date"
FROM PROD_DMA_VW.ACT_ANO_PIT_INTEGRATED_VW T1 
--LEFT JOIN PROD_DMA_VW.DATE_DIM_VW T2 ON T2.ShortDate BETWEEN "Date" AND T1.ExpectedCompletedDate AND IsHoliday = 1    	-- Removed to improve query efficiency. Only needed for holidays field, now removed
WHERE (WORKEVENTDEPARTMENTID IN (9, 11) OR DEPARTMENTID IN (9,11))
AND "Date" >= Add_Months(Current_Date, -3)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22, 23, 24,25,26,27,28,29,30,31,32,33,34,35,36,37,38
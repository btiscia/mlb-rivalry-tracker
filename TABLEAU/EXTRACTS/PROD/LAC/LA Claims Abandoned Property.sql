/*
FILENAME: LAC Abandoned Property
CREATED BY: John Avgoutakis
LAST UPDATED: 12/20/2021
CHANGES MADE: Repointed to Vertica.
*/

SELECT DISTINCT
cpv.source_transaction_id AS SourceTransactionID
,cpv.employee_nm AS EmployeeName
,cpv.manager_nm AS ManagerName 
,cpv.team_nm AS TeamName 
,cpv.work_event_nm AS WorkEventName
,cpv.work_event_id AS WorkEventID
,cpv.insured_nm AS InsuredName
,cpv.pol_nr AS PolicyNumber
,cpv.days_past_tat AS DaysPastTAT 
,cpv.sht_cmnt_des AS ShortComments
,cat.fk_rqstr_typ_cde as ReqTypeCode
,req.rqstr_des as ReqDesc
,LC.LongComments
,PC.NoCalls
,case when  (cpv.work_event_id in ('4052', '23225', '4056', '25541') and cpv.days_past_tat >= 0) THEN 1 else 0 
	end as HoldFinal
,case when (cpv.work_event_id in ('4052', '23225', '4056', '25541') and cpv.sht_cmnt_des like '%single%' and cpv.days_past_tat >= 0) THEN 1 else 0
	end as HoldFinalSingleBene	
,case when (cpv.work_event_id in ('23228', '4055', '4051', '23221', '5639', '5641', '6455', '25539', '25542','25540') and cpv.days_past_tat >= 0 and (cpv.sht_cmnt_des like '%agent%' or cpv.sht_cmnt_des like '%third%' or cat.fk_rqstr_typ_cde in ('A', 'S', 'P', 'G', 'K', 'F', 'J', 'Z', 'E', 'D', 'O'))) THEN 1 else 0
	end as ThirdPartyContact
,case when (cpv.work_event_id in ('23228', '4055', '4051', '23221', '5639', '5641', '6455', '25539', '25542', '25540', '4052', '23225', '4056', '25541') and cpv.days_past_tat >= 0) THEN 1 else 0 
	end as PhoneCalls 
,case when  (cpv.work_event_id = '4102'  and cpv.days_past_tat >= -5) THEN 1 else 0 
	end as SSA
,case when (work_event_id in ('4052','23225','4056','25541','23228','4055','4051','23221','5639','5641','6455','25539','25542','25540') AND cpv.days_past_tat >= 0) OR (work_event_id = '4102' AND cpv.days_past_tat >= -5) THEN 1 else 0
    end as PastDue
,cpv.row_process_dtm AS TransactionDate

FROM dma_vw.rpt_cats_curr_pend_vw AS cpv
LEFT JOIN cats_vw.cats_wrk_vw AS cat ON cat.wrk_ident = cpv.source_transaction_id

LEFT JOIN cats_vw.cats_rqstr_typ_vw AS req ON req.typ_cde = cat.fk_rqstr_typ_cde

LEFT JOIN
	(SELECT DISTINCT
	cpv.source_transaction_id 
	,cpv.pol_nr
	,cast(comm.txt_des as varchar(1000)) as LongComments


	FROM dma_vw.rpt_cats_curr_pend_vw AS cpv
	LEFT JOIN cats_vw.cats_wrk_vw AS cat ON cat.wrk_ident = cpv.source_transaction_id
	JOIN cats_vw.cats_wrk_txt_cmnt_vw as comm on cat.wrk_ident = comm.fk_wrk_ident

	WHERE cpv.work_event_id = '25716' AND comm.cmnt_typ_cde = 'L' 
	)LC
ON cpv.pol_nr = LC.pol_nr

LEFT JOIN
	(SELECT DISTINCT
	pol_nr
	,COUNT(wrk_ident) as NoCalls

	FROM cats_vw.cats_wrk_vw
	where fk_wrk_evntevnt_nr = '7508'

	Group by pol_nr
	)PC
	ON cpv.pol_nr = PC.pol_nr


WHERE work_event_id IN (
'4052',
'23225',
'4056',
'25541',
'23228',
'4055',
'4051',
'23221',
'5639',
'5641',
'6455',
'25539',
'25542',
'25540',
'4102')
SELECT DISTINCT
cpv.SourceTransactionID
,cpv.EmployeeName
,cpv.ManagerName
,cpv.TeamName
,cpv.WorkEventName
,cpv.WorkEventID
,cpv.InsuredName
,cpv.PolicyNumber
,cpv.DaysPastTAT
,cpv.ShortComments
,cat.FK_RQSTR_TYP_CDE as ReqTypeCode
,req.RQSTR_DES as ReqDesc
,LC.LongComments
,PC.NoCalls
,case when (cpv.WorkEventID in ('4052', '23225', '4056', '25541') and cpv.DaysPastTAT >= 0) THEN 1 else 0
end as HoldFinal
,case when (cpv.WorkEventID in ('4052', '23225', '4056', '25541') and cpv.ShortComments like '%single%' and cpv.DaysPastTAT >= 0) THEN 1 else 0
end as HoldFinalSingleBene
,case when (cpv.WorkEventID in ('23228', '4055', '4051', '23221', '5639', '5641', '6455', '25539', '25542','25540') and cpv.DaysPastTAT >= 0 and (cpv.ShortComments like '%agent%' or cpv.ShortComments like '%third%' or cat.FK_RQSTR_TYP_CDE in ('A', 'S', 'P', 'G', 'K', 'F', 'J', 'Z', 'E', 'D', 'O'))) THEN 1 else 0
end as ThirdPartyContact
,case when (cpv.WorkEventID in ('23228', '4055', '4051', '23221', '5639', '5641', '6455', '25539', '25542', '25540', '4052', '23225', '4056', '25541') and cpv.DaysPastTAT >= 0) THEN 1 else 0
end as PhoneCalls
,case when (cpv.WorkEventID = '4102' and cpv.DaysPastTAT >= -5) THEN 1 else 0
end as SSA
,case when (WorkEventID in ('4052','23225','4056','25541','23228','4055','4051','23221','5639','5641','6455','25539','25542','25540') AND cpv.DaysPastTAT >= 0) OR (WorkEventID = '4102' AND cpv.DaysPastTAT >= -5) THEN 1 else 0
end as PastDue
,cpv.TransactionDate

FROM PROD_DMA_VW.CURR_PEND_VW AS cpv
LEFT JOIN PROD_CATS_VW.CATS_WRK_VW as cat on cat.WRK_IDENT = cpv.SourceTransactionID

LEFT JOIN PROD_CATS_VW.CATS_RQSTR_TYP_VW as req on req.TYP_CDE = cat.FK_RQSTR_TYP_CDE

LEFT JOIN
(SELECT DISTINCT
cpv.SourceTransactionID
,cpv.PolicyNumber
,cast(comm.TXT_DES as varchar(1000)) as LongComments

FROM PROD_DMA_VW.CURR_PEND_VW AS cpv
LEFT JOIN PROD_CATS_VW.CATS_WRK_VW as cat on cat.WRK_IDENT = cpv.SourceTransactionID
JOIN PROD_CATS_VW.CATS_WRK_TXT_CMNT_VW as comm on cat.WRK_IDENT = comm.FK_WRK_IDENT

 WHERE WorkEventID = '25716' AND CMNT_TYP_CDE = 'L'
)LC
ON cpv.PolicyNumber = LC.PolicyNumber

LEFT JOIN
(SELECT DISTINCT
POL_NR
,COUNT(WRK_IDENT) as NoCalls

 FROM PROD_CATS_VW.CATS_WRK_VW
where FK_WRK_EVNTEVNT_NR = '7508'

 Group by POL_NR
)PC
ON cpv.PolicyNumber = PC.POL_NR

WHERE WorkEventID in (
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
SELECT 
'Received' as "Transaction Type"
,'Policy Count' as "Group 1"
,'Face Amount' as "Group 2"
,SourceTransactionID as "Source Transaction ID"
,HoldingKey as "Holding Key"
,AGMT.PolicyNumber as "Policy Number"
,AGMT.PolicyNumberwSufix as "Policy Number w Suffix"
,ReceivedDate as "Received Date"
,LoggedDate as "Logged Date"
,coalesce(EmployeeRoleName, 'Unknown') as "Employee Role Name"
,coalesce(EmployeeLastName || ', ' || EmployeeFirstName, 'Unknown') as "Employee Name"    
,coalesce(MMID, 'Unkonwn') as "Employee MMID"
,coalesce(EmployeeOrganizationName, 'Unknown') as "Employee Organization Name"
,coalesce(EmployeeDepartmentName, 'Unknown') as "Employee Department Name"
,FunctionName    as "Function Name"
,SegmentName    as "Segment Name"
,WorkEventName    as "Work Event Name"
,WorkEventNumber    as "Work Event Number"
,WorkEventOranizationName    as "Work Event Organization Name"
,WorkEventDepartmentName    as "Work Event Department Name"
,DepartmentCode     as "Department Code"
,DivisionCode    as "Division Code"
,AdminSystem as "Admin System"    
,ServiceChannelName    as "Service Channel Code"
,ShortComment as "Short Comment"
 ,cwv.insd_frst_nm||' '||cwv.insd_lst_nm AS "Insured Name"
,coalesce(AGMT.FACE_AMOUNT, 'Unknown') as "Face Amount"
,AGMT.lob_nme AS "Line of Business"
,AGMT."Product Type"
,AGMT."Minor Product Name"
,AGMT."Product Type Name"
,AGMT."Status"
,COUNT(distinct ActivityID) as "Transaction Count"

 

FROM PROD_DMA_VW.TRANS_CURR_INTEGRATED_VW a

 

LEFT 
     JOIN prod_cats_vw.cats_wrk_vw AS cwv
         ON a.SourceTransactionID = cwv.wrk_ident

 

 LEFT JOIN 
            (
            SELECT DISTINCT 
            trim(leading '0' from hldg_key) as PolicyNumber
            ,trim(leading '0' from hldg_key)||hldg_key_sfx as PolicyNumberwSufix
            ,agreement_source_cd
            ,agreement_id
            ,face_amount
           , lob_nme
            ,lob_cde
            ,CASE WHEN major_prod_nme IN ('Non-Traditional Life', 'Traditional Permanent', 'Traditional Term', 'Group Non-Traditional Life', 'Worksite Products' ) 
                                THEN major_prod_nme 
                                ELSE 'Unknown' END AS "Product Type"
            ,CASE WHEN major_prod_nme  IN ('Non-Traditional Life', 'Traditional Permanent', 'Traditional Term', 'Group Non-Traditional Life', 'Worksite Products') 
                               THEN minor_prod_nme 
                               ELSE 'Unknown' END AS "Minor Product Name"
            ,prod_typ_nme as "Product Type Name"
            ,hldg_stus
            ,stus_ctgy_desc as "Status"
            ,admn_sys_cde
                       
            FROM prod_usig_stnd_vw.agmt_cmn_vw 
            
            --WHERE lob_cde in ('Life', 'LCM')
            ) AGMT
            
            ON     AGMT.PolicyNumber =trim(leading '0' from a.HoldingKey)
            and   AGMT.agreement_source_cd = a.AdminSystem
            and AGMT.AGREEMENT_ID  = a.AgreementID

 

WHERE  
WorkEventDepartmentID in (7,8)
--OR DepartmentID in (7,8))
and
WorkEventNumber in ('4356', '10597', '10768', '10543', '10541')
AND SequenceNumber = 1
AND "Received Date" BETWEEN '2017-01-01' and CURRENT_DATE
and AGMT.lob_cde in ('Life', 'LCM')

 
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
/*
* This routine pulls transactions for the past due report
*  Peer Review & Change Log:
*  Peer Review Date: 
*  Source for this routine is: dma_vw.tvl_past_due_rpt_new_vw
*  Author: Srinivas Pasumarthy
*  Report Developer:  Lorraine Christian
*  Created: 4/20/2023
*  Revisions:               
======================================================================*/

SELECT * FROM
dma_vw.tvl_past_due_rpt_new_vw
where status <> 'FA'
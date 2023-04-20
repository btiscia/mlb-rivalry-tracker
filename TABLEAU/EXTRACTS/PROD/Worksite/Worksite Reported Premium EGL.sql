/*  
FILENAME: Worksite Reported Premium EGL
CREATED BY: Bill Trombley
LAST UPDATED: 4/20/2023
CHANGES MADE:
*/

SELECT 'Reported Premium' AS metric_type
		, agreement_nr
		, group_nr
		, reported_premium
		, reported_dt AS 'Date'
		, group_nm
		, policy_month
		, planned
		, NULL AS admin_fee
FROM worksite_vw.andesa_egl_premium_vw
UNION ALL
SELECT 'EGL Excess' AS metric_type
		, NULL AS agreement_nr
		, NULL AS group_nr
		, NULL AS reported_premium
		, reported_dt AS 'Date'
		, NULL AS group_nm
		, NULL AS policy_month
		, NULL AS planned
		, reported_premium AS 'admin_fee'
FROM worksite_vw.andesa_egl_excess_premium_vw
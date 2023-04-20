/*  
FILENAME: Worksite Sales Combined
CREATED BY: Bill Trombley
LAST UPDATED: 4/20/2023
CHANGES MADE:
*/

SELECT 'Actual' AS metric_type
		, market_segment_nm
		, market_segment_cde
		, agreement_nr
		, group_nr
		, group_nm
		, contract_nr
		, status
		, enrollment_type
		, product_cde
		, product_type
		, reported_dt AS "date"
		, NULL AS plan_end_dt
		, enrollment_effective_dt
		, ci_enrollment_eligible_lives
		, wl_enrollment_eligible_lives
		, ul_enrollment_eligible_lives
		, acc_enrollment_eligible_lives
		, total_number_of_eligible_lives
		, eligible_lives_segment
		, advisor_id
		, advisor_commission_split
		, channel
		, reported_premium
		, reported_premium_sales_type
		, NULL AS reported_premium_goal_amt
        , concentrix_last_updated_dt
		, salesforce_contract_last_updated_dt
		, salesforce_opportunity_last_updated_dt
		, salesforce_opportunity_advisor_last_updated_dt
		, salesforce_enrollment_last_updated_dt
		, NULL AS is_holiday
		, NULL AS is_weekday
FROM worksite_vw.sales_reported_prem_vw
UNION ALL
SELECT 'Plan' AS metric_type
		, market_segment_nm
		, NULL AS market_segment_cde
		, NULL AS agreement_nr
		, NULL AS group_nr
		, NULL AS group_nm
		, NULL AS contract_nr
		, NULL AS status
		, enrollment_type
		, NULL AS product_cde
		, product_type
		, plan_start_dt AS "date"
		, plan_end_dt
		, NULL AS enrollment_effective_dt
		, NULL AS ci_enrollment_eligible_lives
		, NULL AS wl_enrollment_eligible_lives
		, NULL AS ul_enrollment_eligible_lives
		, NULL AS acc_enrollment_eligible_lives
		, NULL AS total_number_of_eligible_lives
		, NULL AS eligible_lives_segment
		, NULL AS advisor_id
		, NULL AS advisor_commission_split
		, channel
		, NULL AS reported_premium
		, reported_premium_sales_type
		, reported_premium_goal_amt
        , NULL AS concentrix_last_updated_dt
		, NULL AS salesforce_contract_last_updated_dt
		, NULL AS salesforce_opportunity_last_updated_dt
		, NULL AS salesforce_opportunity_advisor_last_updated_dt
		, NULL AS salesforce_enrollment_last_updated_dt
		, CAST(is_holiday AS INTEGER) AS "is_holiday"
		, CAST(is_weekday AS INTEGER) AS "is_weekday"
FROM worksite_vw.reported_premium_pln_vw T1
LEFT JOIN dma_vw.dma_dim_date_vw T2 ON T1.plan_start_dt = T2.short_dt
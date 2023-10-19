/*
 FILENAME:  Hyderabad Redo Items
 CREATED BY:  Kyle Williamson
 CREATED DATE:  09.24.2023
 MODIFIED DATE:  09.24.2023
 LOG:
     09.24.23 - Mirrored query that was joining across AWS and Vertica but limited Redo items to within last 5 years.
                Not all fields are used from the joins but those in the event of additional enhancements so work would not
                have to be done from scratch.  
                Limited the fields only to those the current dashboard implements, except for:
                    1 - redo_data.row_num
                    2 - redo_data.work_iot_work_id
                    It is easier to SELECT redo_data.* then to type out all the fields implemented
 */

SELECT  redo_data.*,
        error_by_employee.team_nm as "Errored By Team Nm",
        error_by_employee.manager_first_nm as "Error Employee Manager First Nm",
        error_by_employee.manager_last_nm as "Error Employee Manager Last Nm",
        error_by_employee.employee_first_nm as "Error Employee First Name",
        error_by_employee.employee_last_nm as "Error Employee Last Name"
FROM (
       SELECT   *
       FROM (
       SELECT   rr.id AS "Redo Request ID",
                rr.client_id AS "Client ID",
                rr.redo_queue_id AS "Queue ID",
                rr.redo_error_source_id AS "Identified By ID",
                CASE WHEN rr.is_awareness_only = 1 THEN 'Awareness' ELSE 'Non-awareness' END AS "Awareness Only Indicator",
                CASE WHEN rr.has_sec_impact = 1 THEN 'SEC' ELSE 'Non-SEC' END AS "SEC Indicator",
                rr.description AS "Request Description",
                rr.created_by AS "Request Created By",
                rr.updated_by AS "Request Updated By",
                rr.created_at AS "Request Created Date Time",
                cast(rr.created_at AS DATE) AS "Request Created Date",
                rr.updated_at AS "Request Updated Date Time",
                rrs.created_at AS "Status Creation Date Time",
                rrer.name AS "Error Name",
                rrer.description AS "Error Description",
                rrq.name AS "Queue Name",
                rres.name AS "Identified By",
                s.name AS Status,
                rrec.employee_hr_id AS "Corrective Action User ID",
                rrec.redo_error_id AS "Workable ID",
                rreu.created_by AS "User Created",
                rreu.employee_hr_id AS "Error User ID",
                rre.id AS "Error Count ID",
                rreu.id AS "Error Employee Count ID",
                cast(rreu.created_at AS DATE) AS "Error User Created At",
                rrec.work_iot_work_id,
                rrec.id AS "Corrective Action Count ID",
                ROW_NUMBER() OVER (PARTITION BY rr.id, rre.id, rrer.id, rres.id, rrq.id, rreu.id, rrec.id ORDER BY rrs.created_at DESC) AS row_num
       FROM
        dma_vw.bibt_redos_vw AS rr
        LEFT JOIN dma_vw.bibt_redo_errors_vw AS rre ON
            rr.id = rre.redo_id
            AND rre.deleted_at IS NULL
        LEFT JOIN dma_vw.bibt_redo_error_reasons_vw AS rrer ON
            rre.redo_error_reason_id = rrer.id
            AND rrer.deleted_at IS NULL
        JOIN dma_vw.bibt_redo_statuses_vw AS rrs ON
            rr.id = rrs.redo_id
        JOIN dma_vw.bibt_statuses_vw AS s ON
            rrs.status_id = s.id
            AND s.statusable_id = 13
            AND s.deleted_at IS NULL
        LEFT JOIN dma_vw.bibt_redo_error_sources_vw AS rres ON
            rr.redo_error_source_id = rres.id
            AND rres.deleted_at IS NULL
        JOIN dma_vw.bibt_redo_queues_vw AS rrq ON
            rr.redo_queue_id = rrq.id
            AND rrq.deleted_at IS NULL
        LEFT JOIN dma_vw.bibt_redo_error_users_vw AS rreu ON
            rre.id = rreu.redo_error_id
            AND rreu.deleted_at IS NULL
        LEFT JOIN dma_vw.bibt_redo_error_corrections_vw AS rrec ON
            rre.id = rrec.redo_error_id
            AND rrec.deleted_at IS NULL
        WHERE cast(rr.created_at AS DATE)>= '2022-07-25' AND TIMESTAMPDIFF(YEAR,rr.created_at, NOW())  < 5
        AND rr.deleted_at IS NULL) AS t1
       WHERE row_num = 1) redo_data LEFT JOIN
(SELECT *
FROM dma_vw.dma_dim_employee_pit_vw) corrective_action_employee ON redo_data."Corrective Action User ID" = corrective_action_employee.hr_id LEFT JOIN
(SELECT *
FROM dma_vw.dma_dim_employee_pit_vw) createdby_employee_data ON redo_data."Request Created By" = createdby_employee_data.hr_id AND redo_data."Request Created Date" >= createdby_employee_data.begin_dt AND redo_data."Request Created Date" <= createdby_employee_data.end_dt LEFT JOIN
(SELECT *
FROM dma_vw.dma_dim_employee_pit_vw) error_by_employee ON redo_data."Error User ID" = error_by_employee.hr_id AND redo_data."Error User Created At" >= error_by_employee.begin_dt AND redo_data."Error User Created At" <= error_by_employee.end_dt LEFT JOIN
(SELECT *
FROM dma_vw.dma_dim_work_pit_vw) work_event ON redo_data.work_iot_work_id = work_event.work_id
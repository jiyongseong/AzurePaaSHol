SELECT r.session_id, r.blocking_session_id, s.text, p.query_plan, r.wait_type, r.wait_time, r.last_wait_type, r.wait_resource
FROM sys.dm_exec_requests AS r CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS s
														CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS p
WHERE r.blocking_session_id > 0

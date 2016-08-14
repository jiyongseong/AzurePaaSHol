SELECT r.session_id, s.login_name, 
			DB_NAME(s.database_id) AS DBName, r.command, 
			SUBSTRING(t.TEXT, (r.statement_start_offset/2)+1,
							((CASE r.statement_end_offset
									WHEN -1 THEN DATALENGTH(t.TEXT)
									ELSE r.statement_end_offset
							END - r.statement_start_offset)/2)+1) AS sqlText,
			p.query_plan,
			r.cpu_time, r.reads, r.writes, r.logical_reads, r.total_elapsed_time,
			r.blocking_session_id
FROM sys.dm_exec_requests AS r INNER JOIN sys.dm_exec_sessions AS s ON r.session_id = s.session_id
										CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
										CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) AS p
WHERE r.session_id <> @@spid
ORDER BY r.cpu_time DESC;
GO

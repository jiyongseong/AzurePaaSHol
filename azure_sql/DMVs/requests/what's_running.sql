SELECT r.session_id, r.command, 
SUBSTRING(t.TEXT, (r.statement_start_offset/2)+1,
				((CASE r.statement_end_offset
						WHEN -1 THEN DATALENGTH(t.TEXT)
						ELSE r.statement_end_offset
				END - r.statement_start_offset)/2)+1) AS sqlText
FROM sys.dm_exec_requests AS r INNER JOIN sys.dm_exec_sessions AS s ON r.session_id = s.session_id
										CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE r.session_id <> @@spid;
GO
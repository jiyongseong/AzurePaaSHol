SELECT sess.session_id, sess.host_name, sess.program_name, 
		sess.last_request_start_time, sess.last_request_end_time,
		sqltext.text
FROM sys.dm_exec_sessions AS sess INNER JOIN sys.dm_exec_connections AS conn ON sess.session_id = conn.session_id
									CROSS APPLY sys.dm_exec_sql_text(conn.most_recent_sql_handle) as sqltext
WHERE sess.session_id <> @@spid;
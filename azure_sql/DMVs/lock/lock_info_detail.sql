select l.request_session_id,
			l.resource_type,
			db_name(resource_database_id) as DBName,
			CASE WHEN l.resource_type IN ('Database', 'File', 'Metadata') THEN l.resource_type
						WHEN l.resource_type = 'Object' THEN OBJECT_NAME(l.resource_associated_entity_id, l.resource_database_id)
						WHEN l.resource_type IN ('Key', 'Page', 'RID') THEN (SELECT OBJECT_NAME(p.object_id) FROM sys.partitions AS p WHERE p.hobt_id = l.resource_associated_entity_id)
						ELSE 'NA'
			END AS obj_name,
			l.request_mode,
			l.request_status,
			r.blocking_session_id,
			s.login_name,
			CASE l.request_lifetime
				WHEN 0 THEN rt.text
				ELSE t.text
			END as sqlText
FROM sys.dm_tran_locks AS l LEFT JOIN sys.dm_exec_requests AS r ON l.request_session_id = r.session_id
						INNER JOIN sys.dm_exec_sessions AS s ON l.request_session_id = s.session_id
						INNER JOIN sys.dm_exec_connections AS c on l.request_session_id = c.most_recent_session_id
						OUTER APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) AS rt
						OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
--WHERE l.resource_type <> 'Database';
ORDER BY l.request_session_id
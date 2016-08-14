/*
sys.dm_exec_connections DMV는 사용자 데이터베이스 컨텍스트에서만 실행이 가능함
Msg 262, Level 14, State 1, Line 2
VIEW DATABASE STATE permission denied in database 'master'.
Msg 297, Level 16, State 1, Line 2
The user does not have permission to perform this action.
*/

SELECT sess.host_name, sess.program_name, --sess.client_interface_name,
		COUNT(conn.session_id) AS [# of connections]
FROM sys.dm_exec_sessions AS sess INNER JOIN sys.dm_exec_connections AS conn ON sess.session_id = conn.session_id
GROUP BY sess.host_name, sess.program_name--, sess.client_interface_name
ORDER BY COUNT(conn.session_id) DESC;


SELECT sess.login_name,
		COUNT(sess.session_id) AS [# of connections]
FROM sys.dm_exec_sessions AS sess 
WHERE sess.session_id <> @@spid AND sess.is_user_process = 1
GROUP BY sess.login_name
ORDER BY COUNT(sess.session_id) DESC;

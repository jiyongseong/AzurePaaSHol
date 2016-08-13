# 누가 접속 중인거야?

**Database context : user database**

Azure SQL Database에 접속한 호스트와 프로그램의 숫자를 결과로 반환합니다.
아래 쿼리는 사용자 데이터베이스 컨텍스트에서만 실행이 가능합니다. 
sys.dm_exec_connections DMV를 master 데이터베이스에서는 볼 수 있는 권한이 Azure SQL Databases에서는 제한되어 있기 때문입니다.

다음 두 개의 DMV들이 사용되었습니다.

- [sys.dm_exec_sessions](https://msdn.microsoft.com/en-us/library/ms176013.aspx)
- [sys.dm_exec_connections](https://msdn.microsoft.com/en-us/library/ms181509.aspx)

```SQL
SELECT sess.host_name, sess.program_name, --sess.client_interface_name,
		COUNT(conn.session_id) AS [# of connections]
FROM sys.dm_exec_sessions AS sess INNER JOIN sys.dm_exec_connections AS conn ON sess.session_id = conn.session_id
GROUP BY sess.host_name, sess.program_name--, sess.client_interface_name
ORDER BY COUNT(conn.session_id) DESC
```

다음과 같이, 로그인 이름으로도 결과를 반환해 볼 수도 있습니다.

```SQL
SELECT sess.login_name,
		COUNT(conn.session_id) AS [# of connections]
FROM sys.dm_exec_sessions AS sess INNER JOIN sys.dm_exec_connections AS conn ON sess.session_id = conn.session_id
GROUP BY sess.login_name
ORDER BY COUNT(conn.session_id) DESC;
```
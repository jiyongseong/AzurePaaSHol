# 누가 접속 중인거야?

**Database context : user database**

Azure SQL Database에 접속한 호스트와 프로그램의 숫자를 결과로 반환합니다.
아래 쿼리는 사용자 데이터베이스 컨텍스트에서만 실행이 가능합니다. 
sys.dm_exec_connections DMV를 master 데이터베이스에서는 볼 수 있는 권한이 Azure SQL Databases에서는 제한되어 있기 때문입니다.

다음 두 개의 DMV들이 사용되었습니다.

- [sys.dm_exec_sessions](https://msdn.microsoft.com/en-us/library/ms176013.aspx)
- [sys.dm_exec_connections](https://msdn.microsoft.com/en-us/library/ms181509.aspx)

#### 접속 호스트 이름, 접속 프로그램 이름별로 접속한 세션 갯수 
```SQL
SELECT sess.host_name, sess.program_name, --sess.client_interface_name,
		COUNT(conn.session_id) AS [# of connections]
FROM sys.dm_exec_sessions AS sess INNER JOIN sys.dm_exec_connections AS conn ON sess.session_id = conn.session_id
GROUP BY sess.host_name, sess.program_name--, sess.client_interface_name
ORDER BY COUNT(conn.session_id) DESC
```

다음과 같이, 로그인 이름으로도 결과를 반환해 볼 수도 있습니다.

#### 로그인 사용자별 세션 갯수
```SQL
SELECT sess.login_name,
		COUNT(conn.session_id) AS [# of connections]
FROM sys.dm_exec_sessions AS sess INNER JOIN sys.dm_exec_connections AS conn ON sess.session_id = conn.session_id
GROUP BY sess.login_name
ORDER BY COUNT(conn.session_id) DESC;
```

또한 다음과 같이, 세션에 대한 정보들과 마지막으로 수행한 SQL 구문도 확인할 수 있습니다.
아래 구문을 실행하는 세션은 반환되는 결과에서 제외됩니다(```WHERE sess.session_id <> @@spid```)

위의 DMV들에 추가로, 다음의 DMF(Dynamic Management Functions)가 사용되었습니다.
- [sys.dm_exec_sql_text](https://msdn.microsoft.com/en-us/library/ms181929.aspx)

#### 세션별 연결 정보와 마지막으로 수행한 SQL 구문 반환
```SQL
SELECT sess.session_id, sess.host_name, sess.program_name, 
		sess.last_request_start_time, sess.last_request_end_time,
		sqltext.text
FROM sys.dm_exec_sessions AS sess INNER JOIN sys.dm_exec_connections AS conn ON sess.session_id = conn.session_id
								CROSS APPLY sys.dm_exec_sql_text(conn.most_recent_sql_handle) as sqltext
WHERE sess.session_id <> @@spid;
```
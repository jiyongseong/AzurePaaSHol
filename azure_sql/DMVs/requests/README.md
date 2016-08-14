# 실시간 모니터링

**Database context : user database**

sys.dm_exec_requests DMV는 실시간 정보를 반환하는 몇 안되는 DMV 중에 하나입니다.
따라서, 실시간으로 Azure SQL Databases의 상태를 확인하는데 자주 사용이 되며, 매우 유용한 정보들을 반환하게 됩니다.

다음 DMV/DMF들이 사용되었습니다.

- [sys.dm_exec_requests](https://msdn.microsoft.com/en-us/library/ms177648.aspx)
- [sys.dm_exec_sql_text](https://msdn.microsoft.com/en-us/library/ms181929.aspx)
- [sys.dm_exec_query_plan](https://msdn.microsoft.com/en-us/library/ms189747.aspx)

#### Blocking 모니터링

종종 어떤 작업을 하는 경우(대표적인 예가 스키마 변경이나 인덱스 생성, 변경, 관리 등), Blocking 발생 여부를 실시간으로 파악하려는 경우가 있습니다.
이런 경우, 저는 아래와 같은 쿼리를 사용합니다.
OLTP의 Blocking 원인 분석을 위한 용도보다는, 앞에서 언급한 것처럼, 특정 작업으로 인한 부작용 발생 여부를 파악하기 위한 용도입니다. 

```SQL
SELECT r.session_id, r.blocking_session_id, s.text, p.query_plan, r.wait_type, r.wait_time, r.last_wait_type, r.wait_resource
FROM sys.dm_exec_requests AS r CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS s
							CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS p
WHERE r.blocking_session_id > 0
```

#### 모니터링

현재 실행되는 쿼리들을 보려면 다음과 같은 쿼리를 사용합니다.

```SQL
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
```

#### 쿼리 및 리소스 사용량 모니터링

갑자기 Azure SQL Databases의 응답이 느려지거나 현재 상황에서 실행되는 쿼리들의 상태들을 확인하는 경우에는 다음과 같은 쿼리를 사용할 수 있습니다.
결과는 CPU를 많이 사용한 순서에 따라서 반환이 되는데, 읽기(reads), 쓰기(writes) 등을 기준으로 변경하여 사용할 수도 있습니다.

```SQL
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
```

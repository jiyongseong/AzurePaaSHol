# 쿼리 상태 정보

**Database context : user database**

on-premises의 SQL Server도 마찬가지지만, Azure SQL Databases 역시도 쿼리의 성능이 무엇보다도 중요합니다.
잘못 작성된 쿼리가 전체 데이터베이스의 성능에 영향을 미칠 수도 있기 때문입니다. 

다음 DMV/DMF들이 사용되었습니다.

- [sys.dm_exec_query_stats](https://msdn.microsoft.com/en-us/library/ms189741.aspx)
- [sys.dm_exec_sql_text](https://msdn.microsoft.com/en-us/library/ms181929.aspx)
- [sys.dm_exec_query_plan](https://msdn.microsoft.com/en-us/library/ms189747.aspx)

#### 쿼리에 관한 모든 것

Azure SQL Databases에서 실행된 쿼리들의 상태를 파악하기 위해서 사용하는 쿼리입니다.
아래 DMV의 결과를 엑셀에 붙여 넣기 하면, 정렬이나 flitering 및 보고용으로 사용하기 좋습니다.

```SQL
SELECT TOP 100 REPLACE(REPLACE(REPLACE(SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1,((CASE qs.statement_end_offset WHEN -1 THEN DATALENGTH(qt.TEXT) ELSE qs.statement_end_offset END - qs.statement_start_offset)/2)+1), CHAR(9), ' '), CHAR(10), ' '), CHAR(13), ' ')  AS sqlText,
			qs.execution_count,
			---Average
			qs.total_logical_reads/qs.execution_count AS avg_reads,
			qs.total_logical_writes/qs.execution_count AS avg_writes, 
			qs.total_worker_time/qs.execution_count AS avg_worker_time,

			--Total
			qs.total_logical_reads, 
			qs.total_logical_writes, 
			qs.total_worker_time,
			qs.total_elapsed_time/1000000 AS total_elapsed_time_in_S,

			--last
			qs.last_logical_reads,
			qs.last_logical_writes,
			qs.last_worker_time,
			qs.last_elapsed_time/1000000 AS last_elapsed_time_in_S,
			qs.last_execution_time--,qp.query_plan
FROM sys.dm_exec_query_stats qs
				CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
--				CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.total_worker_time/qs.execution_count DESC;
GO 
```

#### 재사용되지 않는 쿼리들

Azure SQL Databases에서 실행된 쿼리는 재사용을 위해서, 실행에 사용된 계획을 캐시에 저장하게 됩니다.
이후에 동일한 쿼리가 인입되면 실행 계획을 다시 컴파일 하지 않고 저장된 실행 계획을 사용하여 서버의 자원을 절약하고 쿼리의 실행 성능도 빠르게 제공할 수 있습니다.
이렇게 컴파일 되고 재사용되지 않는 경우가 발생합니다. 
컴파일은 서버 자원 중에서 CPU 자원을 가장 많이 사용하게 됩니다. 따라서, CPU의 부하가 많은 경우에는 아래의 쿼리를 이용하여 재사용되지 않는 쿼리들이 있는지 확인해보아야 합니다(물론, CPU 부하를 발생시키는 원인은 그 외에도 더 많겠죠).

```SQL
SELECT t.text AS sqlText, p.refcounts, p.usecounts, p.size_in_bytes
FROM sys.dm_exec_cached_plans AS p CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS t
WHERE p.usecounts = 1 AND p.cacheobjtype = 'Compiled Plan' AND p.objtype = 'Adhoc';
GO
```

실행 계획과 재컴파일에 대해서는 아래 문서들을 참고하세요..

- [Execution Plan Caching and Reuse](https://technet.microsoft.com/en-us/library/ms181055(v=sql.105).aspx)
- [How to troubleshoot the performance of Ad-Hoc queries in SQL Server](https://support.microsoft.com/en-us/kb/243588)
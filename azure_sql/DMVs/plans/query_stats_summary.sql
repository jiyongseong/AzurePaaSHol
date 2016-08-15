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
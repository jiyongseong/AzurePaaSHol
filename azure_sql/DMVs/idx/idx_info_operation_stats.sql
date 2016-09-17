SELECT OBJECT_SCHEMA_NAME(object_id) AS [schema_name], OBJECT_NAME(object_id) AS [table_name], index_id, 
			SUM(user_seeks + user_scans + user_lookups) AS ReadsOps,
			SUM(user_updates) AS WritesOps,
			CAST(SUM(user_seeks + user_scans + user_lookups) AS decimal) /NULLIF(SUM(user_updates + user_seeks + user_scans + user_lookups), 0) * 100 AS ReadsRatio,
			CAST(SUM(user_updates) AS decimal) /NULLIF(SUM(user_updates + user_seeks + user_scans + user_lookups), 0) * 100 AS WritesRatio
FROM sys.dm_db_index_usage_stats
GROUP BY object_id, index_id
ORDER BY object_id, index_id;
GO

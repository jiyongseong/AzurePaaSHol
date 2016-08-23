SELECT o.name AS table_name, o.object_id, OBJECT_SCHEMA_NAME(o.object_id) AS [schema_name],
			i.name AS index_name, i.index_id,  i.type_desc AS index_type_desc, i.is_primary_key, i.is_unique_constraint, 
			u.user_seeks, u.user_scans, u.user_lookups, u.user_updates,
			SUM(p.rows) AS [# of rows]
FROM sys.objects AS o INNER JOIN sys.indexes AS i on o.object_id = i.object_id
										INNER  JOIN sys.dm_db_index_usage_stats AS u ON i.object_id = u.object_id AND i.index_id = u.index_id
										INNER JOIN sys.partitions AS p ON u.object_id = p.object_id AND u.index_id = p.index_id
WHERE o.is_ms_shipped = 0
GROUP BY o.name, o.object_id, o.schema_id, i.name, i.index_id, i.type_desc, i.is_primary_key, i.is_unique_constraint, u.user_seeks, u.user_scans, u.user_lookups, u.user_updates
ORDER BY o.object_id,i.index_id;
GO
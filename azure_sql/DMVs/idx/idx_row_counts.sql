SELECT OBJECT_SCHEMA_NAME(o.object_id)  AS [schema_name], OBJECT_NAME(o.object_id) AS table_name, i.index_id, i.type_desc, SUM(s.row_count) AS row_count
FROM sys.objects AS o INNER JOIN sys.indexes AS i on o.object_id = i.object_id
					INNER JOIN sys.dm_db_partition_stats AS s on i.object_id = s.object_id AND i.index_id = s.index_id
WHERE o.is_ms_shipped = 0
GROUP BY o.object_id, i.index_id, i.type_desc
ORDER BY o.object_id, i.index_id;
GO
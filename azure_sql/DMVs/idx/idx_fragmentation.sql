SELECT  OBJECT_SCHEMA_NAME(o.object_id) AS [schema_name],  o.name AS [object_name], 
 				i.name AS index_name, o.object_id, i.index_id, i.type_desc AS index_type_desc, 
				s.partition_number, s.alloc_unit_type_desc, s.index_depth, s.index_level,
				s.avg_fragmentation_in_percent, s.fragment_count,
				s.avg_fragment_size_in_pages, s.page_count				
FROM sys.objects AS o INNER JOIN sys.indexes AS i ON o.object_id = i.object_id
						INNER JOIN sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS s ON i.object_id = s.object_id AND i.index_id = s.index_id
WHERE o.is_ms_shipped = 0
ORDER BY s.avg_fragmentation_in_percent DESC , s.page_count DESC;
GO
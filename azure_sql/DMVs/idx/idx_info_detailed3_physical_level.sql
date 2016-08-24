 SELECT o.name AS table_name, o.object_id, OBJECT_SCHEMA_NAME(o.object_id) AS [schema_name],
				i.name AS index_name, i.index_id,  i.type_desc AS index_type_desc, 

				--leaf level
				s.leaf_insert_count,
				s.leaf_delete_count,
				s.leaf_update_count,
				s.leaf_ghost_count,

				--non leaf
				s.nonleaf_insert_count,
				s.nonleaf_delete_count,
				s.nonleaf_update_count,

				--allocation
				s.leaf_allocation_count,
				s.nonleaf_allocation_count

FROM sys.objects AS o INNER JOIN sys.indexes AS i ON o.object_id = i.object_id
										INNER JOIN sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id
										INNER JOIN sys.dm_db_index_operational_stats(db_id(), NULL, NULL, NULL) AS s ON p.object_id = s.object_id AND p.index_id = s.index_id AND p.partition_number = s.partition_number
WHERE o.is_ms_shipped = 0
ORDER BY o.object_id, i.index_id;
GO
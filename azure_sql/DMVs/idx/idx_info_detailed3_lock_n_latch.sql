
SELECT SCHEMA_NAME(o.schema_id) AS [schema_name],  o.name AS [object_name], 
 	i.name AS index_name, o.object_id, i.index_id, i.type_desc AS index_type_desc,

	--row & page lock
	s.partition_number, s.row_lock_count, s.row_lock_wait_count, s.row_lock_wait_in_ms, 
	s.page_lock_count, s.page_lock_wait_count, s.page_lock_wait_in_ms,

	--latch
	s.page_latch_wait_count, s.page_latch_wait_in_ms, s.page_io_latch_wait_count, s.page_io_latch_wait_in_ms,
	s.tree_page_latch_wait_count, s.tree_page_latch_wait_in_ms, s.tree_page_io_latch_wait_count, s.tree_page_io_latch_wait_in_ms

FROM sys.objects AS o INNER JOIN sys.indexes AS i ON o.object_id = i.object_id
										INNER JOIN sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) AS s ON i.object_id = s.object_id AND i.index_id = s.index_id
WHERE o.is_ms_shipped = 0
ORDER BY OBJECT_NAME(o.object_id), i.index_id;
GO

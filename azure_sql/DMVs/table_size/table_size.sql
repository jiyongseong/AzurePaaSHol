SELECT ps.row_count, OBJECT_SCHEMA_NAME(ps.object_id) AS SchemaName, OBJECT_NAME(ps.object_id) AS ObjectName, sum(au.total_pages) AS TotalPages, sum(au.total_pages * 8) AS TotalBytes
 FROM sys.dm_db_partition_stats ps
  JOIN sys.allocation_units au ON ps.partition_id = au.container_id
WHERE OBJECTPROPERTY(ps.object_id, 'IsSystemTable') = 0
 GROUP BY ps.row_count, OBJECT_SCHEMA_NAME(ps.object_id) , OBJECT_NAME(ps.object_id) 
 ORDER BY OBJECT_NAME(ps.object_id), OBJECT_SCHEMA_NAME(ps.object_id);
GO

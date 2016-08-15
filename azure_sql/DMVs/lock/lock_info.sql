select l.resource_type,
			db_name(resource_database_id) as DBName,
			CASE WHEN l.resource_type IN ('Database', 'File', 'Metadata') THEN l.resource_type
						WHEN l.resource_type = 'Object' THEN OBJECT_NAME(l.resource_associated_entity_id, l.resource_database_id)
						WHEN l.resource_type IN ('Key', 'Page', 'RID') THEN (SELECT OBJECT_NAME(p.object_id) FROM sys.partitions AS p WHERE p.hobt_id = l.resource_associated_entity_id)
						ELSE 'NA'
			END AS obj_name,
			request_mode,
			l.resource_associated_entity_id  
			resource_description
FROM sys.dm_tran_locks AS l
WHERE l.resource_type <> 'Database';
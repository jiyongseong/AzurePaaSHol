SELECT OBJECT_SCHEMA_NAME(u.object_id) AS [schema_name], OBJECT_NAME(u.object_id) AS Table_Name,  
				u.index_id, i.name AS Index_name, i.type_desc AS index_type,
				u.user_seeks, u.user_scans, u.user_lookups, u.user_updates
FROM sys.dm_db_index_usage_stats AS u INNER JOIN sys.indexes AS i ON u.object_id = i.object_id AND u.index_id = i.index_id
ORDER BY OBJECT_NAME(u.object_id), u.index_id;
GO
SELECT SCHEMA_NAME(o.schema_id) AS Schema_Name, OBJECT_NAME(i.object_id) AS Table_Name, i.name AS Index_Name, i.index_id, 
			i.type_desc AS Index_type_desc, ic.is_included_column,
			ic.index_column_id, c.name AS Column_Name, t.name AS Column_data_type, c.max_length, c.precision, c.scale, c.collation_name, c.is_nullable, CASE t.is_user_defined WHEN 1 THEN 'TRUE' ELSE 'FALSE' END AS user_defined_data_type
FROM sys.indexes AS i INNER JOIN sys.objects AS o ON i.object_id = o.object_id
										INNER JOIN sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
										INNER JOIN sys.columns AS c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
										INNER JOIN sys.types AS t on c.user_type_id = t.user_type_id
WHERE o.is_ms_shipped = 0
ORDER BY i.object_id, i.index_id, ic.index_column_id;
GO

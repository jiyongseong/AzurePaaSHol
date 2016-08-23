 # 인덱스(index) 정보

**Database context : user database**

다음 DMV들과 DMF가 사용되었습니다.

- [sys.indexes](https://msdn.microsoft.com/en-us/library/ms173760.aspx)
- [sys.dm_db_index_usage_stats](https://msdn.microsoft.com/en-us/library/ms188755.aspx)
- [sys.objects](https://msdn.microsoft.com/en-us/library/ms190324.aspx)
- [sys.index_columns](https://msdn.microsoft.com/en-us/library/ms175105.aspx)
- [sys.columns](https://msdn.microsoft.com/en-us/library/ms176106.aspx)
- [sys.types](https://msdn.microsoft.com/en-us/library/ms188021.aspx)

기본적인 인덱스 정보(스키마 이름, 테이블 이름, 인덱스 아이디, 인덱스 이름, 인덱스 유형)와 간략한 사용 패턴(seek, scan, lookup, update)에 대한 정보는 다음의 쿼리를 이용하여 확인이 가능합니다.

```SQL
SELECT OBJECT_SCHEMA_NAME(u.object_id) AS [schema_name], OBJECT_NAME(u.object_id) AS Table_Name,  
				u.index_id, i.name AS Index_name, i.type_desc AS index_type,
				u.user_seeks, u.user_scans, u.user_lookups, u.user_updates
FROM sys.dm_db_index_usage_stats AS u INNER JOIN sys.indexes AS i ON u.object_id = i.object_id AND u.index_id = i.index_id
ORDER BY OBJECT_NAME(u.object_id), u.index_id;
GO
```

다음의 쿼리는 인덱스 정보는 물론이고, 인덱스를 구성하고 있는 컬럼, 해당 컬럼의 데이터 형식 등의 정보들을 반환합니다.

```SQL
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
```

다음의 쿼리는 인덱스의 기본 정보와 함께, 사용 패턴 및 데이터의 행수를 반환하게 됩니다.

```SQL
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
```
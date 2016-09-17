# 인덱스(index) 정보

**Database context : user database**

다음 DMV들과 DMF가 사용되었습니다.

- [sys.indexes](https://msdn.microsoft.com/en-us/library/ms173760.aspx)
- [sys.dm_db_index_usage_stats](https://msdn.microsoft.com/en-us/library/ms188755.aspx)
- [sys.objects](https://msdn.microsoft.com/en-us/library/ms190324.aspx)
- [sys.index_columns](https://msdn.microsoft.com/en-us/library/ms175105.aspx)
- [sys.columns](https://msdn.microsoft.com/en-us/library/ms176106.aspx)
- [sys.types](https://msdn.microsoft.com/en-us/library/ms188021.aspx)
- [sys.dm_db_index_operational_stats](https://msdn.microsoft.com/en-us/library/ms174281.aspx)
- [sys.dm_db_index_physical_stats](https://msdn.microsoft.com/en-us/library/ms188917.aspx)
- [sys.dm_db_partition_stats](https://msdn.microsoft.com/en-us/library/ms187737.aspx)

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

인덱스가 얼마나, 어떻게 사용되었는지는 다음과 같이 확인이 가능합니다. 인덱스가 유용성 여부는 물론이고, 인덱스가 어떤 유형의 연산자 형태로 사용되었는지 확인이 가능합니다.

```sql
SELECT OBJECT_SCHEMA_NAME(object_id) AS [schema_name], OBJECT_NAME(object_id) AS [table_name], index_id, 
	SUM(user_seeks + user_scans + user_lookups) AS ReadsOps,
	SUM(user_updates) AS WritesOps,
	CAST(SUM(user_seeks + user_scans + user_lookups) AS decimal) /NULLIF(SUM(user_updates + user_seeks + user_scans + user_lookups), 0) * 100 AS ReadsRatio,
	CAST(SUM(user_updates) AS decimal) /NULLIF(SUM(user_updates + user_seeks + user_scans + user_lookups), 0) * 100 AS WritesRatio
FROM sys.dm_db_index_usage_stats
GROUP BY object_id, index_id
ORDER BY object_id, index_id;
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

다음은 인덱스별 페이지에 대한 작업 유형 횟수들을 확인하는 쿼리입니다.
크게 leaf level과 non-leaf level에 따른 insert, update, delete 횟수와 할당량을 보여주고 있습니다.
SQL Server의 데이터 구조에 대해서는 다음의 문서를 참고하시기 바랍니다.

* [Tables and Index Data Structures Architecture](https://technet.microsoft.com/en-us/library/ms180978(v=sql.105).aspx)
* [Indexes in SQL Server 2005/2008 – Part 2 – Internals](http://www.sqlskills.com/blogs/kimberly/indexes-in-sql-server-20052008-part-2-internals/)

```SQL
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
```

다음의 DMV 쿼리는 row, page 단위의 잠금과 latch 정보들을 반환합니다.

```SQL
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
```

다음은 인덱스 관리 시에 가장 많이 이슈가 되는 인덱스 조각화 정보를 확인하는 DMV 쿼리입니다.

```SQL
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
```

Azure SQL Database에서는 SQL Server 2000에서 지원되던 시스템 개체들도 사용이 가능합니다.

단, 아래의 두 쿼리 모두 동일한 결과를 반환하며, 사용자 데이터베이스는 물론이고 master 데이터베이스에서도 실행이 가능합니다.

```SQL
SELECT * FROM sysindexes;
SELECT * FROM sys.sysindexes;
```

다음의 쿼리는 테이블의 인덱스별로 데이터의 행수를 반환합니다.

```SQL
SELECT OBJECT_SCHEMA_NAME(o.object_id)  AS [schema_name], OBJECT_NAME(o.object_id) AS table_name, i.index_id, i.type_desc, SUM(s.row_count) AS row_count
FROM sys.objects AS o INNER JOIN sys.indexes AS i on o.object_id = i.object_id
			INNER JOIN sys.dm_db_partition_stats AS s on i.object_id = s.object_id AND i.index_id = s.index_id
WHERE o.is_ms_shipped = 0
GROUP BY o.object_id, i.index_id, i.type_desc
ORDER BY o.object_id, i.index_id;
GO
```

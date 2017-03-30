# Azure SQL Database 테이블 크기

**Database context : user database**

다음 DMVF가 사용되었습니다.

- [sys.dm_db_partition_stats](https://docs.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-db-partition-stats-transact-sql)
- [sys.allocation_units](https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-allocation-units-transact-sql)

사용자 데이터베이스의 테이블 크기는 다음의 쿼리를 통하여 확인이 가능합니다.

```SQL
SELECT ps.row_count, OBJECT_SCHEMA_NAME(ps.object_id) AS SchemaName, OBJECT_NAME(ps.object_id) AS ObjectName, sum(au.total_pages) AS TotalPages, sum(au.total_pages * 8) AS TotalBytes
 FROM sys.dm_db_partition_stats ps
  JOIN sys.allocation_units au ON ps.partition_id = au.container_id
WHERE OBJECTPROPERTY(ps.object_id, 'IsSystemTable') = 0
 GROUP BY ps.row_count, OBJECT_SCHEMA_NAME(ps.object_id) , OBJECT_NAME(ps.object_id) 
 ORDER BY OBJECT_NAME(ps.object_id), OBJECT_SCHEMA_NAME(ps.object_id);
GO
```
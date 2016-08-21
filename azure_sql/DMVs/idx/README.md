 # 인덱스(index) 정보

**Database context : user database**

다음 DMV들과 DMF가 사용되었습니다.

- [sys.indexes](https://msdn.microsoft.com/en-us/library/ms173760.aspx)
- [sys.dm_db_index_usage_stats](https://msdn.microsoft.com/en-us/library/ms188755.aspx)

기본적인 인덱스 정보(스키마 이름, 테이블 이름, 인덱스 아이디, 인덱스 이름, 인덱스 유형)와 간략한 사용 패턴(seek, scan, lookup, update)에 대한 정보는 다음의 쿼리를 이용하여 확인이 가능합니다.

```SQL
SELECT OBJECT_SCHEMA_NAME(u.object_id) AS [schema_name], OBJECT_NAME(u.object_id) AS Table_Name,  
				u.index_id, i.name AS Index_name, i.type_desc AS index_type,
				u.user_seeks, u.user_scans, u.user_lookups, u.user_updates
FROM sys.dm_db_index_usage_stats AS u INNER JOIN sys.indexes AS i ON u.object_id = i.object_id AND u.index_id = i.index_id
ORDER BY OBJECT_NAME(u.object_id), u.index_id;
GO
```
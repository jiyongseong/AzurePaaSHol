# Compatibility level 130 for Azure SQL Database V12

**Database context : user database**

Azure SQL Databases v12에서는 호환성 레빌을 130(SQL Server 2016)로 설정할 수 있는 옵션을 제공합니다.

Azure SQL Databases 서버에 데이터베이스를 생성하면 기본적으로 호환성 수준은 120으로 설정이 됩니다.

다음의 쿼리를 이용하면, 해당 데이터베이스의 호환성 수준을 130으로 변경할 수 있습니다.

```SQL
SELECT name, cmptlevel
FROM sys.sysdatabases
WHERE dbid = db_id();
GO

ALTER DATABASE <<database name>>
SET COMPATIBILITY_LEVEL = 130;
GO

SELECT name, cmptlevel
FROM sys.sysdatabases
WHERE dbid = db_id();
GO
```

관련된 설명은 다음의 문서를 참고하세요.

[Compatibility level 130 for Azure SQL Database V12](https://azure.microsoft.com/en-us/updates/compatibility-level-130-for-azure-sql-database-v12/)
[Improved query performance with compatibility Level 130 in Azure SQL Database](https://azure.microsoft.com/en-us/documentation/articles/sql-database-compatibility-level-query-performance-130/)

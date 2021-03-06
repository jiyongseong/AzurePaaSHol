# Azure SQL Database 이벤트 로그 보기

**Database context : master database**

Azure SQL Database에서는 SQL Server와는 달리, [sys.event_log](https://msdn.microsoft.com/en-us/library/dn270018.aspx)라는 DMV를 이용하여 이벤트 로그를 확인할 수 있습니다.

```SQL
SELECT * FROM sys.event_log ORDER BY start_time DESC;  
```

Azure SQL Database에 대한 연결, 연결 실패 및 deadlock 등과 같은 정보들이 기록됩니다.

sys.event_log DMV 외에도 다음과 같은 쿼리를 이용하면, 좀 더 상세한 정보를 얻을 수도 있습니다.

```sql
SELECT  object_name 
  ,CAST(f.event_data as XML).value('(/event/data[@name="database_name"]/value)[1]', 'sysname') AS [database_name]
  ,CAST(f.event_data as XML).value ('(/event/@timestamp)[1]', 'datetime2') AS [timestamp]
  ,CAST(f.event_data as XML).value('(/event/data[@name="error"]/value)[1]', 'int') AS [error]
  ,CAST(f.event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'int') AS [state]
  ,CAST(f.event_data as XML).value('(/event/data[@name="is_success"]/value)[1]', 'bit')  AS [is_success]
FROM sys.fn_xe_telemetry_blob_target_read_file('el', null, null, null) AS f
ORDER BY [timestamp] DESC;
```

글을 더 합니다. sys.event_log 이외에도 sys.event_log_ex라는 DMV도 있군요.
아직 두 DMV의 차이점을 찾지 못했습니다.

```SQL
SELECT * FROM sys.event_log_ex;
```

다음 두 개의 DMV도 있군요..

```SQL
select * from sys.database_connection_stats;
select * from sys.database_connection_stats_ex;
```

다음의 쿼리를 이용하면 해당 서버에서 발생된 오류만 반환을 하게 됩니다. 또한 해당 오류에 대한 오류 메시지도 같이 확인할 수 있습니다.

```sql
SELECT e.* ,m.severity ,m.[description]
FROM
(SELECT  object_name 
  ,CAST(f.event_data as XML).value('(/event/data[@name="database_name"]/value)[1]', 'sysname') AS [database_name]
  ,CAST(f.event_data as XML).value ('(/event/@timestamp)[1]', 'datetime2') AS [timestamp]
  ,CAST(f.event_data as XML).value('(/event/data[@name="error"]/value)[1]', 'int') AS [error]
  ,CAST(f.event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'int') AS [state]
  ,CAST(f.event_data as XML).value('(/event/data[@name="is_success"]/value)[1]', 'bit')  AS [is_success]
FROM sys.fn_xe_telemetry_blob_target_read_file('el', null, null, null) AS f ) AS e INNER JOIN sys.sysmessages AS m ON e.error = m.error
ORDER BY [timestamp] DESC;
```
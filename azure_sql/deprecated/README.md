# 앞으로 제거될 T-SQL 기능의 사용여부 확인

**Database context : user database**

SQL Server 뿐만 아니라, Azure SQL Databases는 이전 버전에 대한 호환성을 제공하고 있습니다.

하지만, 이전 버전에서 제공되고 있던 모든 기능들이 최신 버전에서 제공되는 것은 아닙니다.

다음 버전에서 제공되지 않거나 제한적으로 제공될 기능들에 대해서는 이전 버전에서 미리 알려 주게 됩니다.

SQL Server 2016의 경우에는 다음의 문서에서 향후 사용되지 않는 기능들의 목록을 제공하고 있습니다.

[SQL Server 2016에서 사용되지 않는 데이터베이스 엔진 기능] (https://msdn.microsoft.com/ko-kr/library/ms143729.aspx)

데이터베이스 관리자 입장에서는 모든 쿼리와 저장 프로시저들을 모니터링하고 있을 수 없기 때문에, 향후 제거될 기능을 어느 쿼리 또는 저장 프로시저에서 사용하는지 알 수 없습니다.

Azure SQL Databases에서는 성능 카운터와 확장 이벤트를 통하여 향후 제거될 기능들의 사용여부를 확인할 수 있도록 해주고 있습니다.

먼저, Azure SQL Databases에서 향후 제거될 기능을 사용하고 있는지를 확인할 수 있는 방법은 성능 카운터를 이용하는 것입니다.

Azure SQL Database v12에서 다음의 쿼리를 실행하면, 252가지의 deprecated 기능들의 목록들이 보여지게 됩니다.

```SQL
SELECT object_name, counter_name, instance_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name like '%:Deprecated Features%';
GO
```

만약, 향후 제거될 기능들을 사용한다면, 해당 성능 카운터 중에서 관련된 카운터의 값이 증가하게 될 것입니다.

해당 성능 카운터를 통하여, 제거될 기능의 사용 여부가 확인되면 실제 어떤 쿼리가 사용되는지를 확인해야 합니다.

이는 확장 이벤트를 이용하여 확인이 가능합니다.

먼저 다음과 같이, 확장 이벤트를 정의합니다. 이벤트는 deprecated 기능을 사용하는 시점입니다.

```SQL
CREATE EVENT SESSION [deprecated_tsql] ON DATABASE 
ADD EVENT sqlserver.deprecation_announcement(
    ACTION(
				sqlserver.client_app_name,
				sqlserver.client_connection_id,
				sqlserver.client_hostname,
				sqlserver.database_id,
				sqlserver.database_name,
				sqlserver.sql_text,
				sqlserver.tsql_stack,
				sqlserver.username)
				)
ADD TARGET package0.ring_buffer(SET max_memory=(51200))
WITH (STARTUP_STATE=OFF);
GO
```

정상적으로 이벤트가 생성이 되면, 이벤트를 시작합니다.

```SQL
ALTER EVENT SESSION deprecated_tsql ON DATABASE
STATE = START;
GO
```

이벤트를 시작하고, 어느 정도 사용이 이루어지고 나면, 다음의 쿼리를 이용하여 deprecated 기능의 사용 여부와 사용된 쿼리 등을 확인할 수 있습니다.

```SQL
SELECT 
XEVTData.R.value ('@name', 'nvarchar(50)') AS EventName,
XEVTData.R.value ('@timestamp', 'nvarchar(50)') AS [TimeStamp],
XEVTData.R.value ('data(data/value)[1]', 'int') AS FeatureId,
XEVTData.R.value ('data(data/value)[2]', 'nvarchar(500)') AS Feature,
XEVTData.R.value ('data(data/value)[3]', 'nvarchar(500)') AS [Message],


XEVTData.R.value ('(action/.)[4]', 'nvarchar(128)') AS [Database_name],
XEVTData.R.value ('(action/.)[5]', 'int') AS [Database_id],
XEVTData.R.value ('(action/.)[1]', 'nvarchar(128)') AS userid,
XEVTData.R.value ('(action/.)[3]', 'nvarchar(50)') AS SQLText,
XEVTData.R.value ('(action/.)[6]', 'nvarchar(50)') AS client_host,
XEVTData.R.value ('(action/.)[8]', 'nvarchar(50)') AS client_app_name

FROM
(  
	SELECT CONVERT(XML, t.target_data) AS xmldata 
	FROM sys.dm_xe_database_sessions AS s INNER JOIN sys.dm_xe_database_session_targets AS t ON CAST(s.address AS BINARY(8)) = CAST(t.event_session_address AS BINARY(8))
	WHERE s.name = 'deprecated_tsql'
) AS targetdata
CROSS APPLY xmldata.nodes ('//event') AS XEVTData (R)
ORDER BY [TimeStamp];
GO
```

모든 모니터링이 완료되어, 이벤트를 중지하고 삭제하려면 다음과 같은 쿼리를 사용하면 됩니다.

```SQL
ALTER EVENT SESSION deprecated_tsql ON DATABASE
STATE = STOP;
GO

DROP EVENT SESSION deprecated_tsql ON DATABASE;
GO
```

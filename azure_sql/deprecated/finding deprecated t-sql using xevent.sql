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

ALTER EVENT SESSION deprecated_tsql ON DATABASE
STATE = START;
GO

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

ALTER EVENT SESSION deprecated_tsql ON DATABASE
STATE = STOP;
GO

DROP EVENT SESSION deprecated_tsql ON DATABASE;
GO
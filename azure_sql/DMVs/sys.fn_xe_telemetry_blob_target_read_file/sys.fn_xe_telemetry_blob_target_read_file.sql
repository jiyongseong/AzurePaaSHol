SELECT * FROM sys.event_log ORDER BY start_time desc;  
GO

SELECT  object_name 
  ,CAST(f.event_data as XML).value('(/event/data[@name="database_name"]/value)[1]', 'sysname') AS [database_name]
  ,CAST(f.event_data as XML).value ('(/event/@timestamp)[1]', 'datetime2') AS [timestamp]
  ,CAST(f.event_data as XML).value('(/event/data[@name="error"]/value)[1]', 'int') AS [error]
  ,CAST(f.event_data as XML).value('(/event/data[@name="state"]/value)[1]', 'int') AS [state]
  ,CAST(f.event_data as XML).value('(/event/data[@name="is_success"]/value)[1]', 'bit')  AS [is_success]
FROM sys.fn_xe_telemetry_blob_target_read_file('el', null, null, null) AS f
ORDER BY [timestamp] DESC;
GO
SELECT 
        CAST(event_data AS XML).value('(/event/@timestamp)[1]', 'datetime2') AS TIMESTAMP
        ,CAST(event_data AS XML).value('(/event/data[@name="server_name"]/value)[1]', 'sysname') AS server_name
		,CAST(event_data AS XML).value('(/event/data[@name="database_name"]/value)[1]', 'sysname') AS database_name
		,CAST(event_data AS XML).value('(/event/data[@name="deadlock_cycle_id"]/value)[1]', 'int') AS deadlock_cycle_id
		,CAST(event_data AS XML).value('(/event/data[@name="xml_report"]/value/deadlock/victim-list/victimProcess/@id)[1]', 'varchar(20)') AS victimProcess_id
		,CAST(event_data AS XML).query('(event/data/value/deadlock)[1]') AS deadlock_graph	
FROM sys.fn_xe_file_target_read_file('https://<your storage account>.blob.core.windows.net/eventfile/deadlockevt', NULL, NULL, NULL)
WHERE object_name = 'database_xml_deadlock_report' 
ORDER BY 1

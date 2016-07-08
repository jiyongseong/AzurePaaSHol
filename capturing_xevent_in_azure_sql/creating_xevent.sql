DECLARE @pwd uniqueidentifier = newid();
SELECT @pwd

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ACA4FA59-E602-402C-9CA0-F8B7F5FB3396'
END
GO

IF EXISTS (SELECT * FROM sys.database_scoped_credentials WHERE name = 'https://<your storage account>.blob.core.windows.net/eventfile')
BEGIN
    DROP DATABASE SCOPED CREDENTIAL [https://<your storage account>.blob.core.windows.net/eventfile] ;
END
GO

CREATE DATABASE SCOPED CREDENTIAL[https://<your storage account>.blob.core.windows.net/eventfile]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',  SECRET = 'sv=2015-04-05&sr=c&si=policysastoken&sig=2TuNzGh8AdbtK6RO4CoKoh8uUrc6QsV7BSgFh5fPMHY%3D';
GO

IF EXISTS (SELECT * from sys.database_event_sessions WHERE name = 'DeadlockReport')
BEGIN
    DROP EVENT SESSION DeadlockReport ON DATABASE;
END
GO

CREATE EVENT SESSION DeadlockReport ON DATABASE
ADD EVENT sqlserver.database_xml_deadlock_report
ADD TARGET package0.event_file(SET filename = 'https://<your storage account>.blob.core.windows.net/eventfile/deadlockevt.xel')
WITH (STARTUP_STATE = ON,  EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS);
GO

ALTER EVENT SESSION DeadlockReport ON DATABASE
STATE = START;
GO

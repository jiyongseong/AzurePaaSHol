exec sp_who2;
GO

SELECT * FROM sysprocesses;
GO

SELECT * FROM sys.sysprocesses;
GO

SELECT spid, blocked, waittype, waittime, waitresource, cpu, physical_io, memusage, status, sql_handle, hostname, program_name
FROM sys.sysprocesses;
GO
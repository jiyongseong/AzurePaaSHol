# Azure SQL Database 데이터/로그 파일 사용 패턴

**Database context : user database**

다음 DMVF가 사용되었습니다.

- [sys.dm_io_virtual_file_stats](https://msdn.microsoft.com/en-us/library/ms190326.aspx)

PaaS라는 특성로 인해서, Azure SQL Databases의 물리적인 부분은 대부분이 감추어져 있습니다.

Azure SQL Databases의 데이터베이스 파일들(데이터, 로그)에 대한 크기 및 사용 패턴은 다음의 쿼리를 이용하여 확인이 가능합니다.

```SQL
SELECT v.file_id, f.name AS logical_filename, f.filename AS physical_filename,
			(f.size * 8) /1024 AS size_in_mb,
			(f.maxsize * 8) /1024/1024 AS maxsize_in_gb,
			
			--bytes
			(v.num_of_bytes_read  / CAST((v.num_of_bytes_written + v.num_of_bytes_read) AS decimal)) * 100 AS ReadBytesRatio,
			(v.num_of_bytes_written  / CAST((v.num_of_bytes_written + v.num_of_bytes_read) AS decimal)) * 100 AS WriteBytesRatio,
			
			--operation
			(v.num_of_reads  / CAST((v.num_of_writes + v.num_of_reads) AS decimal)) * 100 AS ReadsNumRatio,
			(v.num_of_writes  / CAST((v.num_of_writes + v.num_of_reads) AS decimal)) * 100 AS WritesNumRatio
FROM sys.dm_io_virtual_file_stats(db_id(), null) AS v INNER JOIN sys.sysfiles AS f ON v.file_id = f.fileid;
GO
```
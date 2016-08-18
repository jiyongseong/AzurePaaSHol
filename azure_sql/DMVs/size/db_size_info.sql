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
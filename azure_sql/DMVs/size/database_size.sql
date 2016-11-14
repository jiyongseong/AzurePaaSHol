select * from sys.dm_db_file_space_usage


SELECT DB_NAME(dfsu.DATABASE_ID) DBNAME, mf.filename,
                                    dfsu.ALLOCATED_EXTENT_PAGE_COUNT*8/1024 ALLOCATED_EXTENT_SIZE_MB,
                                    dfsu.TOTAL_PAGE_COUNT*8/1024 TOTAL_SIZE_MB,
                                    dfsu.UNALLOCATED_EXTENT_PAGE_COUNT*8/1024 UNALLOCATED_EXTENT_SIZE_MB
FROM sys.dm_db_file_space_usage AS dfsu INNER JOIN sys.sysfiles AS mf ON mf.fileid = dfsu.file_id

/*

sys.dm_db_file_space_usage
https://msdn.microsoft.com/library/ms174412(SQL.130).aspx

on-prem에서는 다음을 쓸 수 있으나, azure sql db에서는 sys.master_files DMV가 제공되지 않으므로 위에 것으로 대체해야 함.

SELECT DB_NAME(dfsu.DATABASE_ID) DBNAME, mf.PHYSICAL_NAME,
                                    dfsu.ALLOCATED_EXTENT_PAGE_COUNT*8/1024 ALLOCATED_EXTENT_SIZE_MB,
                                    dfsu.TOTAL_PAGE_COUNT*8/1024 TOTAL_SIZE_MB,
                                    dfsu.UNALLOCATED_EXTENT_PAGE_COUNT*8/1024 UNALLOCATED_EXTENT_SIZE_MB
FROM sys.dm_db_file_space_usage AS dfsu JOIN sys.master_files AS mf ON mf.database_id = dfsu.database_id AND mf.file_id = dfsu.file_id

또는

                declare @filestats_temp_table table(
                file_id int
                ,       file_group_id int
                ,       total_extents int
                ,       used_extents int
                ,       logical_file_name nvarchar(500) collate database_default
                ,       physical_file_name nvarchar(500) collate database_default
                );

                insert into @filestats_temp_table
                exec ('DBCC SHOWFILESTATS');

                select  (row_number() over (order by t2.name))%2 as l1
                ,		t2.name as [file_group_name]
                ,       t1.logical_file_name
                ,       t1.physical_file_name
                ,       cast(case when (total_extents * 64) < 1024 then (total_extents * 64)
                when (total_extents * 64 / 1024.0) < 1024 then  (total_extents * 64 / 1024.0)
                else (total_extents * 64 / 1048576.0)
                end as decimal(10,2)) as space_reserved
                ,       case when (total_extents * 64) < 1024 then 'KB'
                when (total_extents * 64 / 1024.0) < 1024 then  'MB'
                else 'GB'
                end as space_reserved_unit
                ,		cast(case when (used_extents * 64) < 1024 then (used_extents * 64)
                when (used_extents * 64 / 1024.0) < 1024 then  (used_extents * 64 / 1024.0)
                else (used_extents * 64 / 1048576.0)
                end as decimal(10,2)) as space_used
                ,		case when (used_extents * 64) < 1024 then 'KB'
                when (used_extents * 64 / 1024.0) < 1024 then  'MB'
                else 'GB'
                end as space_used_unit
                from    @filestats_temp_table t1
                inner join sys.data_spaces t2 on ( t1.file_group_id = t2.data_space_id );


*/
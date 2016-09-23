# Azure SQL Databases useful resources

Micorosoft Azure SQL Databases와 관련된 유용한 정보와 쿼리/코드들을 제공합니다.

### [Azure SQL Databases useful PowerShells, DMVs and quries](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs)

  - Micorosoft Azure SQL Databases에서 제공되는 유용한 DMV 쿼리들을 제공합니다.
    * [Azure SQL Database 이벤트 로그 보기 (T-SQL)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs/sys.fn_xe_telemetry_blob_target_read_file)
    * [전통적인 시스템 개체들 (T-SQL)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs/sysprocesses)
    * [누가 접속 중인거야? (T-SQL, sys.dm_exec_*)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs/connection_summary)
    * [실시간 모니터링 (T-SQL, sys.dm_exec_*)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs/requests)
    * [도대체 누가 느린겨? (T-SQL, sys.dm_exec_*)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs/plans)
    * [잠금 관련 - Lock (T-SQL, sys.dm_tran_locks)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs/lock)
    * [Azure SQL Database 데이터/로그 파일 사용 패턴 (T-SQL, sys.dm_io_virtual_file_stats)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs/size)
    * [활성 트랜잭션 정보 (T-SQL, sys.dm_tran_*_transactions)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs/tx)
    * [인덱스 정보 (T-SQL, sys.dm_db_index_*)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs/idx)
    
  - 기타 유용한 T-SQL 코드들을 공유합니다. 
    * [Compatibility level 130 for Azure SQL Database V12 (T-SQL)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs/cmptlevel)
    * [앞으로 제거될 T-SQL 기능의 사용여부 확인](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/deprecated)
    * [Extended Event를 이용하여 Azure SQL Database에서 발생된 Deadlock 정보 확인하기 (PowerShell/T-SQL)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/capturing_xevent_in_azure_sql)
    
  - 유용한 PowerShell 코드들
    * [전체 Azure SQL Databases 목록 반환 (PowerShell)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/powershell/list_all_sql_db)
    * [Azure SQL Database DTU Calculator 사용법 (PowerShell)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/powershell/howto-dtucalculator)
    * [Azure SQL Database 복사하기 (PowerShell)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/powershell/copy-azure-sql-db-to-another-rg)
    * [PowerShell을 이용하여 원격으로 Azure SQL Databases에 쿼리하기](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/powershell/invoking_sql_using_ps)
    * [PortQry를 이용한 Azure SQL Databases 연결 모니터링하기](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/powershell/check_availability)

**성지용([jiyongseong](https://github.com/jiyongseong))**

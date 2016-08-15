# Azure SQL Databases useful DMVs codes

설명 따위는 필요없고, 그냥 쿼리만 알고 싶다는 귀차니스트들을 위한, Micorosoft Azure SQL Databases에서 제공되는 유용한 DMV 쿼리들을 제공합니다.

### [Azure SQL Database 이벤트 로그 보기 (T-SQL)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs/sys.fn_xe_telemetry_blob_target_read_file)

  - sys.event_log 
  - sys.fn_xe_telemetry_blob_target_read_file

### [전통적인 시스템 개체들 (T-SQL)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs/sysprocesses)

  - sp_who2 
  - sysprocesses
  
### [누가 접속 중인거야? (T-SQL)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs/connection_summary)

  - sys.dm_exec_sessions 
  - sys.dm_exec_connections

### [실시간 모니터링 (T-SQL)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs/requests)

  - sys.dm_exec_requests
  - sys.dm_exec_sql_text
  - sys.dm_exec_query_plan  

### [쿼리 실행 계획 (T-SQL)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/DMVs/plans)

  - sys.dm_exec_query_stats
  - sys.dm_exec_sql_text
  - sys.dm_exec_query_plan

**성지용([jiyongseong](https://github.com/jiyongseong))**

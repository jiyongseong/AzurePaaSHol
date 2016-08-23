# Azure PaaS Hands on Lab & useful codes

Micorosoft Azure에서 제공되는 PaaS(Platform as a Service) 서비스들에 대한 Hands on Lab과 유용한 코드들을 제공합니다.

### [Azure SQL Databases useful PowerShells, DMVs and quries (T-SQL, PowerShell)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/)
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

  - 유용한 PowerShell 코드들
    * [전체 Azure SQL Databases 목록 반환](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/powershell/list_all_sql_db)
    * [Azure SQL Database DTU Calculator 사용법 (PowerShell)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/powershell/howto-dtucalculator)
  
### [Azure Function Apps (C#)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_function)
  - Micorosoft Azure Function Apps을 이용하는 다양한 코드들을 공유합니다.
    * [Azure Function App을 이용하여 AWS S3 파일을 Storage account로 복사하기 (C#)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_function/copy-awss3-to-azure-storageaccount-using-functionapp)
      * Azure의 App service 중에 하나인, Function app을 이용하여 AWS S3에 있는 파일들을 Azure의 Storage account로 복사하는 방법을 설명하고 있습니다.

### [Extended Event를 이용하여 Azure SQL Database에서 발생된 Deadlock 정보 확인하기 (PowerShell/T-SQL)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/capturing_xevent_in_azure_sql)

- Azure SQL Database에서 확장 이벤트를 이용하여, deadlock 정보를 Storage account에 저장하는 방법과 저장된 데이터를 확인하는 과정에 대해서 설명합니다.
- 예제를 실행하기 위해서는, Azure PowerShell SDK와 SQL Server Management Studio가 필요합니다.

### [Azure Resource Group 간에 Resource 옮기기 (PowerShell)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/moving-resources-between-azure-resource-groups)

- Azure PowerShell을 이용하여, 특정 Resource Group에 있는 모든 리소스들을 다른 Resource Group으로 이동시키는 방법을 설명하고 있습니다.

### [Azure SQL Database 복사하기 (PowerShell)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/copy-azure-sql-db-to-another-rg)

- Azure SQL Database의 데이터베이스를 같은 리소스 그룹 또는 다른 리소스 그룹으로 복사하는 방법에 대해서 설명합니다.
- 구현은 PowerShell을 이용하여 설명하고 있습니다.

### [Azure 파일 업로드 예제 (C#)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/AzureFileUploadWeb) 
by taeyo

  - ASP.NET MVC에서 그리드는 Grid.MVC를 활용
- 추가 예제는 jQuery.Form을 활용한 HTML/Javascript 파일 업로드 방식으로 작성
  - 그리드는 Knockout을 활용하여 MVVM 으로 구현(Json 바인딩)
  - 서버 측은 Java나 Php 등으로 구현해도 무방함(예에서는 서버로 ASP.NET을 활용함)
- 웹 페이지 혹은 스크립트를 통해서 업로드 되는 파일은 스트림 그대로 Azure Storage로 전송되도록 구현
- 예제 소스는 이해하기 쉽도록 동기(Sync) 메서드를 사용하여 구현하였음

### [저장소 계정 이용하기 - VB.NET 버전](https://github.com/jiyongseong/AzurePaaSHol/tree/master/vbnet-storage)

  - [https://azure.microsoft.com/ko-kr/documentation/services/storage/](https://azure.microsoft.com/ko-kr/documentation/services/storage/)에서 C# 또는 다른 언어들을 이용하여 설명하고 있는 저장소 계정 사용 방법을 VB.NET 코드로 전환
  - [.NET을 사용하여 Azure Blob 저장소 시작](https://azure.microsoft.com/ko-kr/documentation/articles/storage-dotnet-how-to-use-blobs/)의 [VB.NET 버전](https://github.com/jiyongseong/AzurePaaSHol/tree/master/vbnet-storage/vbnet-storage-dotnet-how-to-use-blobs)
  - [Blob 스냅숏 만들기](https://azure.microsoft.com/ko-kr/documentation/articles/storage-blob-snapshots/)의 [VB.NET 버전](https://github.com/jiyongseong/AzurePaaSHol/tree/master/vbnet-storage/vbnet-storage-blob-snapshots)
  - [.NET을 사용하여 Azure 테이블 저장소 시작](https://azure.microsoft.com/ko-kr/documentation/articles/storage-dotnet-how-to-use-tables/)의 [VB.NET 버전](https://github.com/jiyongseong/AzurePaaSHol/tree/master/vbnet-storage/vbnet-storage-dotnet-how-to-use-tables)

**김태영([taeyo](https://github.com/taeyo)), 성지용([jiyongseong](https://github.com/jiyongseong))**

# Extended Event를 이용하여 Azure SQL Database에서 발생된 Deadlock 정보 확인하기

아래의 예제를 실행하기 위해서는 Azure PowerShell과 SQL Server Management Studio가 필요합니다.

최신의 Azure PowerShell은 [여기](https://msdn.microsoft.com/en-us/library/mt238290.aspx)에서 다운로드가 가능하며,

SQL Server Mangement Studio 2016 버전은 [여기](https://msdn.microsoft.com/en-us/library/mt238290.aspx)에서 다운로드 하실 수 있습니다. > 한글 페이지로 열리는 경우, 영문 페이지로 전환하셔서 확인하시기 바랍니다.

Azure SQL Database에서는 ```sys.event_log```라는 System DMV를 통하여 데이터베이스 연결과 연결 실패, 교착 상태 및 조정 이벤트 정보들을 확인할 수 있습니다.

예를 들어, Deadlock에 대한 정보는 다음과 같은 쿼리를 이용하여 확인이 가능합니다.

```SQL
SELECT * FROM sys.event_log WHERE event_type = 'deadlock'
```

쿼리를 실행한 결과는 다음과 같습니다.  

아래에서 볼 수 있는 것처럼, Deadlock의 발생 정보 정도 외에는 Deadlock의 원인을 찾아서 해결할 수 있는 정보는 제공되지 않습니다.

![](https://jyseongfileshare.blob.core.windows.net/images/capturing_xevent_in_azure_sql_01.jpg)

Azure SQL Database에서도 SQL Server와 마찬가지로, 확장 이벤트(Extended Event) 기능을 제공합니다. 이를 이용하면, 기존 SQL Server에서와 마찬가지로, deadlock에 대한 기본적인 정보는 물론이고, deadlock graph까지도 확인이 가능합니다.

Azure SQL Database에서 확장 이벤트를 구성하는 방법은 다음과 같은 순서에 따라서 이루어집니다.

1) 이벤트 정보를 저장할 Storage Account 생성  
  - Storage Account 생성  
  - 이벤트 파일을 저장할 container 생성  
  - SAS 정책 생성  
 
2) Azure SQL Database에 확장 이벤트 정의  
  - CREDENTIAL 생성  
  - 확장 이벤트 정의  
  - 확장 이벤트 시작  

### Storage Account 생성

PowerShell 명령 창(powershell.exe) 또는 PowerShell ISE(powershell_ise.exe)를 열고, Azure로 로그인 합니다.

소스 코드 : [creating_storage_account_and_container.ps1](https://github.com/jiyongseong/AzurePaaSHol/blob/master/azure_sql/capturing_xevent_in_azure_sql/creating_storage_account_and_container.ps1)


```PowerShell
Login-AzureRmAccount
```

Storage Account를 생성하려는 구독(subscription)을 선택합니다.

```PowerShell
$subscriptionName = "your subscription name"
Select-AzureRmSubscription -SubscriptionName $subscriptionName
```

다음에는 Storage Account를 생성합니다.

```$rgName``` 은 리소스 그룹을,  
```$storageAccountName``` 은 생성하려는 Storage account의 이름을,  
```$location``` 은 Storage account를 생성할 지역을 입력합니다.

```PowerShell
$rgName = "your resource group name"
$storageAccountName = "storage account name"
$location = "location"

$storage = New-AzureRmStorageAccount -ResourceGroupName $rgName -Name $storageAccountName -SkuName Standard_LRS -Location $location -Kind Storage
```

다음에는 확장 이벤트 파일을 저장할 container를 생성합니다.

아래의 예제에서는 "eventfile"이라는 container를 생성하도록 설정하였습니다.

```PowerShell
$containerName = "eventfile"
$container = New-AzureStorageContainer -Context $storage.Context -Name $containerName -Permission Off
```

다음에는 해당 container에 대한 [SAS(Shared Access Signatures)](https://azure.microsoft.com/en-us/documentation/articles/storage-dotnet-shared-access-signature-part-1/) 정책을 생성합니다.  
정책이 적용되는 날짜는 현재 시점(```$policySasStartTime```)부터 1년 동안(```$policySasExpiryTime```) 유효하도록 설정하고,  
권한(```$policySasPermission```)은 읽기(r), 쓰기(w), 리스트 보기(l)가 가능하도록 설정합니다.

```PowerShell
$policySasStartTime = [datetime](((Get-Date).ToUniversalTime()).ToString("yyyy-MM-ddTHH:mm:ssZ"))
$policySasExpiryTime  = [datetime]((Get-Date).ToUniversalTime().AddYears(1).ToString("yyyy-MM-ddTHH:mm:ssZ"))
$policySasToken = 'policysastoken'
$policySasPermission = 'rwl'

New-AzureStorageContainerStoredAccessPolicy -Context $storage.Context -Container $containerName `
                                            -Policy $policySasToken -Permission $policySasPermission `
                                            -StartTime $policySasStartTime -ExpiryTime $policySasExpiryTime
```

앞서 생성한 정책을 container에 적용합니다.

```PowerShell
Try
{
    $sasTokenWithPolicy = New-AzureStorageContainerSASToken `
        -Name    $containerName `
        -Context $storage.Context `
        -Policy  $policySasToken
}
Catch 
{
    $Error[0].Exception.ToString()
}

```

마지막으로, T-SQL에서 사용할 정보를 출력하려 복사해 둡니다.

먼저, SAS Token을 출력합니다.

```PowerShell
Write-Host $sasTokenWithPolicy
```

명령을 실행하면, 다음과 같은 결과가 출력됩니다.

![](https://jyseongfileshare.blob.core.windows.net/images/capturing_xevent_in_azure_sql_02.jpg)

다음에는 확장 이벤트 파일을 저장할 전체 경로를 출력합니다.

```PowerShell
Write-Host $sasTokenWithPolicy
```
명령을 실행하면, 다음과 같은 결과가 출력됩니다.

![](https://jyseongfileshare.blob.core.windows.net/images/capturing_xevent_in_azure_sql_03.jpg)

상기 두 가지 정보를 적당한 곳에 복사하여 보관합니다.

### Azure SQL Database에 확장 이벤트 정의

이제 다음에는 Azure SQL Database에서 작업이 이루어지게 됩니다.

SQL Server Management Studio(SSMS)를 열고, 확장 이벤트를 이용하여 deadlock을 모니터링하려는 데이터베이스로 접속합니다.

먼저 MASTER KEY ENCRYPTION을 생성할 때 사용할 비밀번호를 생성합니다.


소스 코드 : [creating_xevent.sql](https://github.com/jiyongseong/AzurePaaSHol/blob/master/azure_sql/capturing_xevent_in_azure_sql/creating_xevent.sql)


```SQL
DECLARE @pwd uniqueidentifier = newid();
SELECT @pwd
```

출력된 결과를 복사하여, 다음의 쿼리에서 PASSWORD 다음의 값에 붙여 넣기 합니다.

```SQL
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101)
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '43BEB31E-6A32-4ED4-929D-A89E9B50B2F8'
END
GO
```

다음과 같이 보여지게 됩니다.

![](https://jyseongfileshare.blob.core.windows.net/images/capturing_xevent_in_azure_sql_04.jpg)

다음에는 데이터베이스 범위의 CREDENTIAL을 생성합니다.

이때, 앞서 PowerShell에서 출력해 두었던, SAS Token 값을 ```SECRET```의 값으로 사용합니다.

___출력된 값은 물음표로 시작이 되는데, 물음표를 제외한 나머지 값을 붙여 넣기 합니다.___

```SQL
IF EXISTS (SELECT * FROM sys.database_scoped_credentials WHERE name = 'https://<your storage account>.blob.core.windows.net/eventfile')
BEGIN
    DROP DATABASE SCOPED CREDENTIAL [https://<your storage account>.blob.core.windows.net/eventfile] ;
END
GO

CREATE DATABASE SCOPED CREDENTIAL[https://<your storage account>.blob.core.windows.net/eventfile]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',  SECRET = 'sv=2015-04-05&sr=c&si=policysastoken&sig=jTKHig%2FGerWqU4yPKaujLz0FDfBLfOeaqAhTXoRRpLY%3D';
GO
```

다음과 같이 사용될 수 있습니다.

![](https://jyseongfileshare.blob.core.windows.net/images/capturing_xevent_in_azure_sql_05.jpg)

이제 Deadlock 보고서를 저장하는 확장 이벤트를 만들도록 합니다.

앞서 생성한 Storage account의 eventfile container 아래에, deadlockevt.xel라는 이름으로 이벤트 파일을 저장하게 됩니다.

```SQL

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
```

SQL Server 2016에서 제공되는 SSMS를 사용하고 계신다면, [해당 데이터베이스] > [Extended Events] > [Sessions]를 열어보면, 앞서 생성한 확장 이벤트의 세션이 보여지게 됩니다.

![](https://jyseongfileshare.blob.core.windows.net/images/capturing_xevent_in_azure_sql_06.jpg)

하지만, 확장 이벤트 세션이 실행된 것은 아닙니다. 다음의 명령을 이용하여 확장 이벤트 세션을 시작하도록 합니다.

```SQL
ALTER EVENT SESSION DeadlockReport ON DATABASE
STATE = START;
GO
```

자, 이제 deadlock의 정보를 수집할 수 있게 되었습니다.

### 테스트

실제로 deadlock을 발생시켜서, 확장 이벤트가 deadlock을 감지하고 해당 데이터들을 저장하는지 살펴보도록 합니다.

SSMS에서 다음의 쿼리를 이용하여 간단한 테스트 테이블을 생성합니다.

소스 코드 : [creating_table_for_deadlock.sql](https://github.com/jiyongseong/AzurePaaSHol/blob/master/azure_sql/capturing_xevent_in_azure_sql/creating_table_for_deadlock.sql)

```SQL
CREATE TABLE DeadlockTest (id INT)
INSERT INTO DeadlockTest
SELECT 1 UNION ALL
SELECT 2
GO
```

새로운 두 개의 쿼리 창을 열고, 아래의 쿼리들을 복사하여 붙여넣기 합니다.

첫 번째 쿼리 창에는 다음의 쿼리를,

소스 코드 : [deadlock_query1.sql](https://github.com/jiyongseong/AzurePaaSHol/blob/master/azure_sql/capturing_xevent_in_azure_sql/deadlock_query1.sql)


```SQL
--session 1
BEGIN TRAN

	UPDATE DeadlockTest 
	SET id = 12
	WHERE id = 2
	   
	WAITFOR DELAY '00:00:05'

	UPDATE DeadlockTest 
	SET id = 11
	WHERE id = 1

ROLLBACK
```

두 번째 쿼리 창에는 다음의 쿼리를 붙여 넣기 합니다.

소스 코드 : [deadlock_query2.sql](https://github.com/jiyongseong/AzurePaaSHol/blob/master/azure_sql/capturing_xevent_in_azure_sql/deadlock_query2.sql)


```SQL
--session 2
BEGIN TRAN

	UPDATE DeadlockTest 
	SET id = 11
	WHERE id = 1

	WAITFOR DELAY '00:00:05'

	UPDATE DeadlockTest 
	SET id = 12
	WHERE id = 2
ROLLBACK
GO
```

이제, 첫 번째 쿼리와 쿼리와 두 번째 쿼리를 동시에 실행하여, deadlock을 유발합니다.

5~6초 정도의 시간이 지나고 나면, 다음과 같이 첫 번째 세션은 성공적으로 쿼리의 실행이 완료되고,

![](https://jyseongfileshare.blob.core.windows.net/images/capturing_xevent_in_azure_sql_07.jpg)

두 번째 세션은 deadlock의 피해자로, 쿼리의 실행이 실패하게 됩니다.

![](https://jyseongfileshare.blob.core.windows.net/images/capturing_xevent_in_azure_sql_08.jpg)

이제 확장 이벤트에서 정상적으로 daedlock 정보가 수집되었는지 확인해보겠습니다.

다음의 쿼리를 실행합니다.

소스 코드 : [quering_daeadlock_info.sql](https://github.com/jiyongseong/AzurePaaSHol/blob/master/azure_sql/capturing_xevent_in_azure_sql/quering_daeadlock_info.sql)

```SQL
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
```

쿼리를 실행하면, 방금전에 발생되었던 deadlock 정보가 보여지게 됩니다.

![](https://jyseongfileshare.blob.core.windows.net/images/capturing_xevent_in_azure_sql_09.jpg)

출력된 결과의 마지막 컬럼인 [deadlock_graph]를 클릭하면, 다음과 같이 XML 파일이 보여지게 됩니다.

해당 파일을 다른 이름으로 저장을 합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/capturing_xevent_in_azure_sql_10.jpg)

파일 저장 창이 나타나면, 적절한 파일 이름과 확장자를 __.xdl__ 로 저장합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/capturing_xevent_in_azure_sql_11.jpg)

저장이 완료되면, 저장된 파일을 SSMS에서 다시 읽어 들입니다.

![](https://jyseongfileshare.blob.core.windows.net/images/capturing_xevent_in_azure_sql_12.jpg)

이제 다음과 같이, 그래프 형식으로 deadlock 정보를 확인할 수 있습니다.

![](https://jyseongfileshare.blob.core.windows.net/images/capturing_xevent_in_azure_sql_14.jpg)

다음과 같은 자료를 기반으로 작성을 하였습니다. 참고하시기 바랍니다.

[SQL 데이터베이스의 확장 이벤트](https://azure.microsoft.com/ko-kr/documentation/articles/sql-database-xevent-db-diff-from-svr/)  
[SQL 데이터베이스의 확장 이벤트에 대한 이벤트 파일 대상 코드](https://azure.microsoft.com/ko-kr/documentation/articles/sql-database-xevent-code-event-file/)
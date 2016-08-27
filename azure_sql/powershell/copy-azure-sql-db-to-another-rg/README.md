# Azure SQL Database 복사하기

테스트 및 개발 목적 또는 기타 다른 이유들로 인해서 Azure SQL Database를 복사해야 하는 경우가 종종 발생됩니다.

다음의 PowerShell 스크립트는 같은 리소스 그룹 또는 별개의 리소스 그룹으로 데이터베이스를 복사하는 작업을 수행합니다.

먼저 Azure로 로그인을 진행합니다.

```PowerShell
Login-AzureRmAccount
```

사용하려는 구독을 선택합니다.

```PowerShell
$subscriptionName = "your subscription name"
Select-AzureRmSubscription -SubscriptionName $subscriptionName
```

다음의 스크립트에서는 복사하려는 원본 데이터베이스의 정보를 입력합니다.

```PowerShell
$rgName = "source resource group"
$svrName = "source Azure SQL Database Server name"
$dbName = "source Azure SQL Database name"
$svcObjName = "tier"
```

 ```$rgName```은 원본 데이터베이스가 위치하고 있는 리소스 그룹을,  
 ```$svrName```은 원본 데이터베이스의 Azure SQL Database 서버 이름을,  
 ```$dbName```은 원본 데이터베이스의 이름을,  
 ```$svcObjName```는 데이터베이스의 가격 계층을 입력하면 됩니다

 가격 계층(```$svcObjName ```)은 다음과 같이 기술할 수 있습니다.

 - 'basic'
 - 'S0' 
 - 'S1'
 - 'S2' 
 - 'S3'
 - 'P1'
 - 'P2'
 - 'P3'
 - 'P4'
 - 'P6'
 - 'P11' 

서비스 계층에 대한 자세한 정보는 다음의 링크를 확인하시기 바랍니다.

[SQL 데이터베이스 옵션 및 성능: 각 서비스 계층에서 사용할 수 있는 것 이해](https://azure.microsoft.com/ko-kr/documentation/articles/sql-database-service-tiers/)

예를 들면, 다음과 같이 작성이 될 수 있습니다.

 ```PowerShell
$rgName = "dataplatform-production-eastasia"
$svrName = "azuresql-production-eastasia"
$dbName = "DB1"
$svcObjName = "Basic"
 ```

 다음에는 복사하려는 대상의 정보를 기술합니다.
 
 ```PowerShell
$destRgName = "destination resource group"
$destSvrName = "destination Azure SQL Database Server name"
$destDBName = "destination Azure SQL Database name"
 ```

 ```$destRgName```은 복사의 대상이 되는 리소스 그룹을,  
 ```$destSvrName```은 복사의 대상이 되는 Azure SQL Database 서버 이름을,  
```$destDBName```은 데이터베이스의 이름을 작성하시면 됩니다.

예를 들면, 다음과 같이 작성이 가능합니다.

```PowerShell
$destRgName = "dataplatform-staging-eastus"
$destSvrName = "azuresql-staging-eastus"
$destDBName = "DB2"
```

마지막으로, 다음의 스크립트를 실행하면 실행 시점을 기준으로 데이터베이스의 복사가 이루어집니다.

```PowerShell
New-AzureRmSqlDatabaseCopy -ServerName $svrName -DatabaseName $dbName -ServiceObjectiveName $svcObjName -ResourceGroupName $rgName `
                            -CopyResourceGroupName $destRgName -CopyServerName $destSvrName -CopyDatabaseName $destDBName 
```

이외에도 다음과 같이, 다양한 방법으로도 데이터베이스를 __복사__ 할 수 있습니다.

- [Azure 포털을 이용하여 복사하는 방법](https://azure.microsoft.com/ko-kr/documentation/articles/sql-database-copy-portal/)
- [PowerShell을 이용하여 복사하는 방법](https://azure.microsoft.com/ko-kr/documentation/articles/sql-database-copy-powershell/)
- [Transact-SQL을 이용하여 복사하는 방법](https://azure.microsoft.com/ko-kr/documentation/articles/sql-database-copy-transact-sql/)
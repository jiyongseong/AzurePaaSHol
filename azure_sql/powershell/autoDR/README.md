# Transparent geographic failover of database groups (AutoDR)

현재 기준(2017년 5월 11일)으로 Azure SQL Databases에 DR과 관련된 새로운 기능이 Public Preview로 추가되었습니다.

[Azure SQL Database now supports transparent geographic failover of database groups](https://azure.microsoft.com/en-us/blog/azure-sql-database-now-supports-transparent-geographic-failover-of-multiple-databases-featuring-automatic-activation/)

앞으로 상세한 기능 설명이 이어지겠지만, 아직은 관련된 정보가 없어서 따로 정리를 해보겠습니다.

Azure SQL Databases의 Failover Group은 다음의 순서에 따라서 진행할 수 있습니다.

0. (사전 조건) 서로 다른 지역에 2개의 Azure SQL Database Server가 생성되어 있어야 하며, Primary Server에 적어도 하나의 데이터베이스가 생성되어 있어야 합니다.
1. Failover Group을 생성합니다. Database Server 전체가 다른 지역의 Server로 Failover가 되므로, Primary Server와 Secondary Server를 지정하게 됩니다.
2. Failover하려는 데이터베이스(들)을 Failover Group에 추가합니다.

## 환경

테스트하려는 전체적인 환경은 다음과 같습니다.

![](https://jyseongfileshare.blob.core.windows.net/images/azure_sql_auto_dr_00.png)

## Azure SQL Database Server 생성하기 (Primary Server)

이미 서로 다른 지역에 두 개의 Azure SQL Database Server가 있다면, 다음 단계로 넘어갑니다.

먼저, East US와 West US에 Resource Group을 생성합니다.

```powershell
Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "<<your subscription name>>"

$resourceGroup1 = "azuresqldb-fg-eastus"
$resourceGroup2 = "azuresqldb-fg-westus"
$location1 = "eastus"
$location2 = "westus"

New-AzureRmResourceGroup -Name $resourceGroup1 -Location $location1 
New-AzureRmResourceGroup -Name $resourceGroup2 -Location $location2
```

다음에는 East US 지역에 Primary Database Server를 생성합니다.

```powershell

$cred = Get-Credential
$primaryServer = "jyseongeastus"

New-AzureRmSqlServer -ResourceGroupName $resourceGroup1 -ServerName $primaryServer -Location $location1 -ServerVersion "12.0" -SqlAdministratorCredentials $cred
```

## 데이터베이스 생성하기(Primary Server)

Database Server가 생성되면, MyDB1과 MyDB2라는 이름의 데이터베이스를 생성합니다.

```powershell
$dbName = "MyDB1"
$primaryDB = New-AzureRmSqlDatabase -ResourceGroupName $resourceGroup1 -ServerName $primaryServer -DatabaseName $dbName -Edition Standard -RequestedServiceObjectiveName "S1" 

$dbName = "MyDB2"
$primaryDB = New-AzureRmSqlDatabase -ResourceGroupName $resourceGroup1 -ServerName $primaryServer -DatabaseName $dbName -Edition Standard -RequestedServiceObjectiveName "S0" 

```

지금까지 작성된 리소스들은 포털에서 다음과 같이 보여지게 됩니다.

![](https://jyseongfileshare.blob.core.windows.net/images/azure_sql_auto_dr_01.png)

## Azure SQL Database Server 생성하기 (Secondary Server)

다음에는 West US 지역에 Secondary Server를 생성합니다.

```powershell
$secondaryServer = "jyseongwestus"

New-AzureRmSqlServer -ResourceGroupName $resourceGroup2 -ServerName $secondaryServer -Location $location2 -ServerVersion "12.0" -SqlAdministratorCredentials $cred
```

Secondary Server에는 데이터베이스를 생성하지 않습니다. Priamry와 Secondary Server를 Failover Group으로 묶고, Primary Server의 데이터베이스를 Failover Group에 추가하면 자동으로 Secondary Server에도 복제가 이루어지게 됩니다.

West US에 생성한 Resource Group은 다음과 같이 보여지게 됩니다.

![](https://jyseongfileshare.blob.core.windows.net/images/azure_sql_auto_dr_02.png)

## Failover Group 생성하기

이제 다음의 cmdlet을 이용하여 failover group을 생성합니다.

```powershell
$failoverGroupName = "jyseongsqlfg"
New-AzureRMSqlDatabaseFailoverGroup -ResourceGroupName $resourceGroup1 -ServerName $primaryServer -PartnerResourceGroupName $resourceGroup2 -PartnerServerName $secondaryServer -FailoverGroupName $failoverGroupName -FailoverPolicy Manual
```

## Failover Group에 데이터베이스 추가하기
생성된 Failover Group에 Primary Server에 있는 데이터베이스들(MyDB1, MyDB2)을 추가합니다.

```powershell
$primarySQLServer = Get-AzureRmSqlServer -ResourceGroupName $resourceGroup1 -ServerName $primaryServer
$failoverGroup = $primarySQLServer | Add-AzureRmSqlDatabaseToFailoverGroup -FailoverGroupName $failoverGroupName -Database ($primarySQLServer | Get-AzureRmSqlDatabase)
```

![](https://jyseongfileshare.blob.core.windows.net/images/azure_sql_auto_dr_03.png)

Failover Group에 데이터베이스들이 추가되면, Secondary Server(West US)에 다음과 같이 데이터베이스가 자동으로 생성됩니다.

![](https://jyseongfileshare.blob.core.windows.net/images/azure_sql_auto_dr_04.png)

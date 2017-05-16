Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "<<your subscription name>>"

$resourceGroup1 = "azuresqldb-fg-eastus"
$resourceGroup2 = "azuresqldb-fg-westus"
$location1 = "eastus"
$location2 = "westus"

##Reseource Group 생성
New-AzureRmResourceGroup -Name $resourceGroup1 -Location $location1 
New-AzureRmResourceGroup -Name $resourceGroup2 -Location $location2

##East US에 Primary Server 생성

$cred = Get-Credential
$primaryServer = "jyseongeastus"

New-AzureRmSqlServer -ResourceGroupName $resourceGroup1 -ServerName $primaryServer -Location $location1 -ServerVersion "12.0" -SqlAdministratorCredentials $cred

##Primary Server에 데이터베이스 생성

$dbName = "MyDB1"
$primaryDB = New-AzureRmSqlDatabase -ResourceGroupName $resourceGroup1 -ServerName $primaryServer -DatabaseName $dbName -Edition Standard -RequestedServiceObjectiveName "S1" 

$dbName = "MyDB2"
$primaryDB = New-AzureRmSqlDatabase -ResourceGroupName $resourceGroup1 -ServerName $primaryServer -DatabaseName $dbName -Edition Standard -RequestedServiceObjectiveName "S0" 

##West US에 Secondary Server 생성
$secondaryServer = "jyseongwestus"

New-AzureRmSqlServer -ResourceGroupName $resourceGroup2 -ServerName $secondaryServer -Location $location2 -ServerVersion "12.0" -SqlAdministratorCredentials $cred

##Failover Group 생성
$failoverGroupName = "jyseongsqlfg"
New-AzureRMSqlDatabaseFailoverGroup -ResourceGroupName $resourceGroup1 -ServerName $primaryServer -PartnerResourceGroupName $resourceGroup2 -PartnerServerName $secondaryServer -FailoverGroupName $failoverGroupName -FailoverPolicy Manual

##Failover Group에 데이터베이스 추가하기
$primarySQLServer = Get-AzureRmSqlServer -ResourceGroupName $resourceGroup1 -ServerName $primaryServer
$failoverGroup = $primarySQLServer | Add-AzureRmSqlDatabaseToFailoverGroup -FailoverGroupName $failoverGroupName -Database ($primarySQLServer | Get-AzureRmSqlDatabase)

$failoverGroup.DatabaseNames
$failoverGroup

##Primary Server 확인하기
nslookup "jyseongsqlfg.database.windows.net"

## failover하기
Switch-AzureRmSqlDatabaseFailoverGroup -ResourceGroupName $resourceGroup2 -ServerName $secondaryServer -FailoverGroupName $failoverGroupName -AllowDataLoss

##Failover 이후 Primary Server 확인하기
ipconfig /flushdns
nslookup "jyseongsqlfg.database.windows.net"
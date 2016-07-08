Login-AzureRmAccount

$subscriptionName = "your subscription name"
Select-AzureRmSubscription -SubscriptionName $subscriptionName

$rgName = "source resource group"
$svrName = "source Azure SQL Database Server name"
$dbName = "source Azure SQL Database name"
$svcObjName = "tier"

$destRgName = "destination resource group"
$destSvrName = "destination Azure SQL Database Server name"
$destDBName = "destination Azure SQL Database name"

New-AzureRmSqlDatabaseCopy -ServerName $svrName -DatabaseName $dbName -ServiceObjectiveName $svcObjName -ResourceGroupName $rgName `
                            -CopyResourceGroupName $destRgName -CopyServerName $destSvrName -CopyDatabaseName $destDBName 
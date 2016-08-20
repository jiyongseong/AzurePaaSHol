# 전체 Azure SQL Databases 목록 반환

로그인한 Azure 계정의 모든 Azure SQL Database들의 목록을 반한하는 PowerShell.

## Classic (ASM, Azure Service Management)

```PowerShell
Add-AzureAccount

$subscriptions = Get-AzureSubscription | select SubscriptionName, SubscriptionId
$outputFilePath = "C:\temp\SQLAzureASM.csv" 

ForEach($subscription in $subscriptions)
{
    Select-AzureSubscription $subscription.SubscriptionName 
    write-host $subscription.SubscriptionName 
    $sqlServers = @(Get-AzureSqlDatabaseServer | Select ServerName, Location)

    foreach($sqlServer in $sqlServers)
    {
        Get-AzureSqlDatabase -ServerName $sqlServer.ServerName -Verbose |`
         Where-Object {$_.ServiceObjectiveName -ne "System"} | `
         SELECT @{name="Subscription Name";expression={$subscription.SubscriptionName.ToString()}}, `
         @{name="SubscriptionId";expression={$subscription.SubscriptionId.ToString()}}, `
         @{name="Server Name";expression={$sqlServer.ServerName }}, `
         @{name="Location";expression={$sqlServer.Location }}, `
         Name, CollationName, Edition, MaxSizeGB, CreationDate | Export-Csv $outputFilePath -NoTypeInformation -Append
    }
}
```

## ARM, Azure Resource Manager

```PowerShell
Login-AzureRmAccount

$subscriptions = Get-AzureRmSubscription | Select SubscriptionName, SubscriptionId
$outputFilePath = "C:\temp\SQLAzureARM.csv" 

ForEach($subscription in $subscriptions)
{
    Select-AzureRmSubscription -SubscriptionName $subscription.SubscriptionName 
    write-host $subscription.SubscriptionName 
    
    Get-AzureRmResourceGroup | Get-AzureRmSqlServer | Get-AzureRmSqlDatabase | Where-Object {$_.DatabaseName -ne "master"} | `
        SELECT @{name="Subscription Name";expression={$subscription.SubscriptionName.ToString()}}, `
        @{name="SubscriptionId";expression={$subscription.SubscriptionId.ToString()}}, `
        ResourceGroupName, Location, ServerName, `
        DatabaseName, CollationName, Edition, CurrentServiceObjectiveName, MaxSizeBytes, CreationDate | Export-Csv $outputFilePath -NoTypeInformation -Append
}
```
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
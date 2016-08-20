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
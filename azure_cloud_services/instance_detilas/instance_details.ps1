
$subscriptionName = "your subscription name"
$service_name="cloud service name"

Select-AzureSubscription -SubscriptionName $subscriptionName

Get-AzureRole -ServiceName $service_name -Slot Production -InstanceDetails 
Get-AzureRole -ServiceName $service_name -Slot Production -InstanceDetails | Select InstanceName, IPAddress
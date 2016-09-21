Add-AzureAccount

$outputFilePath = "C:\temp\CloudServices.csv" 
$namespace=@{ns="http://schemas.microsoft.com/ServiceHosting/2008/10/ServiceConfiguration"} 

foreach($subscription in Get-AzureSubscription) { 

    Select-AzureSubscription -SubscriptionName $subscription.SubscriptionName 

    $deployments = Get-AzureService | Get-AzureDeployment -slot Production -ErrorAction Ignore 
    $deployments | SELECT @{Name="SubscriptionName";Expression={$subscription.SubscriptionName}},ServiceName, SdkVersion, Slot, 
                            @{Name="osFamily";Expression={(select-xml -content $_.configuration -xpath "/ns:ServiceConfiguration/@osFamily" -namespace $namespace).node.value }},
                             osVersion, Status, URL |  Export-Csv $outputFilePath -NoTypeInformation -Append

    $deployments = Get-AzureService | Get-AzureDeployment -slot Staging -ErrorAction Ignore 
    $deployments | SELECT @{Name="SubscriptionName";Expression={$subscription.SubscriptionName}}, ServiceName, SdkVersion, Slot,  
                            @{Name="osFamily";Expression={(select-xml -content $_.configuration -xpath "/ns:ServiceConfiguration/@osFamily" -namespace $namespace).node.value }}, 
                            osVersion, Status, URL |  Export-Csv $outputFilePath -NoTypeInformation -Append
}
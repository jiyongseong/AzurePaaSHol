# Cloud services의 Guest OS family 확인

다음의 PowerShell 스크립트는 로그인한 계정에 있는 모든 구독의 Cloud Services의 Guest OS family 정보를 반환합니다.

관련 정보를 수집하여, $outputFilePath에 지정된 파일로 저장합니다(아래의 스크립트에서는 "C:\temp\CloudServices.csv"로 경로를 지정하였습니다. 필요에 따라서 경로와 파일 이름을 변경하여 사용하면 됩니다).

```PowerShell
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
```
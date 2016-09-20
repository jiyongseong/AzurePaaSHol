# Cloud services의 instance 상세 정보 확인

Get-AzureRole cmdlet을 이용하여, Cloud Services의 상세 정보를 반환합니다.

```PowerShell

$subscriptionName = "your subscription name"
$service_name="cloud service name"

Select-AzureSubscription -SubscriptionName $subscriptionName

Get-AzureRole -ServiceName $service_name -Slot Production -InstanceDetails 
Get-AzureRole -ServiceName $service_name -Slot Production -InstanceDetails | Select InstanceName, IPAddress
```
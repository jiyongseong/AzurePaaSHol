# Azure Resource Group 간에 Resource 옮기기

특정 Azure Resorce Group에 속한 리소스 또는 리소스들을 다른 Resource Group으로 이동해야 하는 경우가 종종 발생됩니다.

이전에는 달리 방법이 없는 경우가 많았는데, Azure PowerShell에서 Move-AzureRmResource라는 새로운 cmdlet이 발표되어서 사용이 가능해졌습니다.

아래의 코드는 특정 Resource Group에 있는 모든 리소스들을 다른 Resource Group으로 이동시키는 작업을 수행합니다.

```
Login-AzureRmAccount #Azure로 로그인

$subscriptionName = “your subscription name” #작업하려는 구독(subscription)의 이름

Select-AzureRmSubscription -SubscriptionName $subscriptionName #구독 선택

$resourceGroupName = “source resource group”    #옮기려는 원본 리소스가 위치하고 있는 리소스 그룹
$destResourceGroupName = “destination resource group” #옮길 대상 리소스 그룹 

Get-AzureRmResource | Where-Object {$_.ResourceGroupName -eq $resourceGroupName} | Select Name, ResourceType | ForEach-Object {
$resource = Get-AzureRmResource –ResourceName $_.Name -ResourceGroupName $srcResourceGroupName
Move-AzureRmResource -DestinationResourceGroupName $destResourceGroupName -ResourceId $resource.ResourceId
}
```
특정 리소스만 이동시키는 경우에는 다음의 cmdlet을 사용하시면 되겠습니다.

```
Login-AzureRmAccount #Azure로 로그인

$subscriptionName = “your subscription name” #작업하려는 구독(subscription)의 이름

Select-AzureRmSubscription -SubscriptionName $subscriptionName #구독 선택

$resourceName = “your resource name” #옮기려는 리소스의 이름
$srcResourceGroupName = “source resource group”    #옮기려는 원본 리소스가 위치하고 있는 리소스 그룹
$destResourceGroupName = “destination resource group” #옮길 대상 리소스 그룹

$resource = Get-AzureRmResource -ResourceName $resourceName -ResourceGroupName $srcResourceGroupName
Move-AzureRmResource -DestinationResourceGroupName $destResourceGroupName -ResourceId $resource.ResourceId
```

현재 시점에서 이동이 가능한 리소스 목록과 포털을 이용하는 방법은 아래의 문서를 참고하시기 바랍니다.

**새 리소스 그룹 또는 구독으로 리소스 이동**
![resource-group-move-resources](https://azure.microsoft.com/ko-kr/documentation/articles/resource-group-move-resources)
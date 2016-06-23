Login-AzureRmAccount #Azure로 로그인

$subscriptionName = “your subscription name” #작업하려는 구독(subscription)의 이름

Select-AzureRmSubscription -SubscriptionName $subscriptionName #구독 선택

$resourceName = “your resource name” #옮기려는 리소스의 이름
$srcResourceGroupName = “source resource group”    #옮기려는 원본 리소스가 위치하고 있는 리소스 그룹
$destResourceGroupName = “destination resource group” #옮길 대상 리소스 그룹

$resource = Get-AzureRmResource -ResourceName $resourceName -ResourceGroupName $srcResourceGroupName
Move-AzureRmResource -DestinationResourceGroupName $destResourceGroupName -ResourceId $resource.ResourceId
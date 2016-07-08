Login-AzureRmAccount

$subscriptionName = "your subscription name"
Select-AzureRmSubscription -SubscriptionName $subscriptionName

$rgName = "your resource group name"
$storageAccountName = "storage account name"
$location = "location"

$storage = New-AzureRmStorageAccount -ResourceGroupName $rgName -Name $storageAccountName -SkuName Standard_LRS -Location $location -Kind Storage

$containerName = "eventfile"
$container = New-AzureStorageContainer -Context $storage.Context -Name $containerName -Permission Off

$policySasStartTime = [datetime](((Get-Date).ToUniversalTime()).ToString("yyyy-MM-ddTHH:mm:ssZ"))
$policySasExpiryTime  = [datetime]((Get-Date).ToUniversalTime().AddYears(1).ToString("yyyy-MM-ddTHH:mm:ssZ"))
$policySasToken         = 'policysastoken'
$policySasPermission = 'rwl'

New-AzureStorageContainerStoredAccessPolicy -Context $storage.Context -Container $containerName `
                                            -Policy $policySasToken -Permission $policySasPermission `
                                            -StartTime $policySasStartTime -ExpiryTime $policySasExpiryTime

Try
{
    $sasTokenWithPolicy = New-AzureStorageContainerSASToken `
        -Name    $containerName `
        -Context $storage.Context `
        -Policy  $policySasToken
}
Catch 
{
    $Error[0].Exception.ToString()
}

Write-Host $sasTokenWithPolicy
#?sv=2015-04-05&sr=c&si=policysastoken&sig=jTKHig%2FGerWqU4yPKaujLz0FDfBLfOeaqAhTXoRRpLY%3D
Write-Host ($storage.Context.BlobEndPoint + $containerName)
#https://<your storage account>.blob.core.windows.net/eventfile

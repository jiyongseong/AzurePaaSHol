Login-AzAccount
Select-AzureRmSubscription -Subscription "<<subscription name>>"

Clear-Host

#resource group
$resourceGroup = "<<resource group name>>"
$location = "<<location>>"

New-AzureRmResourceGroup -Name $resourceGroup -Location $location

#blob info
$folder='E:\basefiles\'
$containerName = "upload"
$extension = 'dat'
$amount=4

#creating base blob storage and container
$storageAccountName = -join ((97..122) | Get-Random -Count 8 | % {[char]$_})

Write-Host $storageAccountName
$storage = New-AzureRmStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName -SkuName Standard_LRS -Location $location -Kind StorageV2 
$key = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroup -Name $storage.Context.Name).Value[0]

$container = New-AzureRmStorageContainer -StorageAccount $storage -Name $containerName -PublicAccess None
$srcStorage = $storage.StorageAccountName.ToString()

#upload blobs to base storage account using azcopy
$command = "'C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy\azcopy.exe' /Source:'"+$folder+"' /Dest:"+$storage.Context.BlobEndPoint.ToString()+$container.Name.ToString()+" /DestKey:"+$key+" /S"

Write-Host $command
#$commands += $storage.Context.BlobEndPoint.ToString() + '+' + $key.ToString()
Invoke-Expression "& $command"

#copying base storage account
for($seq=0;$seq -lt $amount;$seq++)
{
    $storageAccountName = -join ((97..122) | Get-Random -Count 8 | % {[char]$_})

    Write-Host $storageAccountName

    $storage = New-AzureRmStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName -SkuName Standard_LRS -Location $location -Kind StorageV2 
    New-AzureRmStorageContainer -StorageAccount $storage -Name $containerName -PublicAccess None

    $srcStorageContext = (Get-AzureRmStorageAccount -ResourceGroupName $resourceGroup -Name $srcStorage).Context
    $destStorageContext = $storage.Context

    Get-AzureStorageBlob -Container $containerName -Context $srcStorageContext | ForEach-Object { 
    $newName = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 12 | % {[char]$_}) + '.' + $extension
    Start-AzureStorageBlobCopy -Context $srcStorageContext -SrcContainer $containerName -SrcBlob $_.Name.ToString() -DestContainer $containerName -DestBlob $newName -DestContext $destStorageContext }
}

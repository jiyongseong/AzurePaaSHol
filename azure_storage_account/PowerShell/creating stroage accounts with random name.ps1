#https://blogs.technet.microsoft.com/heyscriptingguy/2015/11/05/generate-random-letters-with-powershell/

$resourceGroup = "<<resource group name>>"
$location = "<<location>>"

Remove-AzureRmResourceGroup -Name $resourceGroup -Force
New-AzureRmResourceGroup -Name $resourceGroup -Location $location

$seq = 0
$count = 10

while($seq -lt $count)
{
    $storageAccountNamePrefix = -join ((97..122) | Get-Random -Count 8 | % {[char]$_})
    $storageAccountNamePostfix = "0" * (3- $seq.ToString().Length) + $seq.ToString()

    Write-Host $storageAccountNamePrefix$storageAccountNamePostfix
    New-AzureRmStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountNamePrefix$storageAccountNamePostfix -SkuName Standard_LRS -Location $location -Kind StorageV2 
    $seq += 1
}
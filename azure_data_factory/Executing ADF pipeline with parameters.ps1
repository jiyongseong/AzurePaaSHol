Login-AzAccount

Select-AzSubscription -Subscription "<<subscription name>>"

#Data Factory metadata
$rgNameADF = "<<resource group name - ADF>>"
$dataFactoryName = "<<data factory name>>"
$pipelineName = "<<pipeline name>>"

#Storaeg account metadata
$rgNameStorage = "<<resource group name - storage account>>"
$storageAccountName = "<<storage account name>>"
$ContainerName = "<<container name>>"

#getting all the blobs from Azure Storage Account
$storageAccount = Get-AzStorageAccount -ResourceGroupName $rgNameStorage -Name $storageAccountName 
$blobs = Get-AzStorageBlob -Container $ContainerName -Context $storageAccount.Context 

#execute ADF pipeline
foreach($blob in $blobs)
{
    $sourceFolder = $ContainerName.ToString()+"/"+$blob.Name.Substring(0, $blob.name.LastIndexOf("/") + 1)
    $sourceFile = $blob.Name.Substring($blob.name.LastIndexOf("/") + 1, $blob.name.Length - $blob.name.LastIndexOf("/")-1)

    $parameters = @{
        "sourceFolder" = $sourceFolder
        "sourceFile" = $sourceFile
    }

    Invoke-AzDataFactoryV2Pipeline -ResourceGroupName $rgNameADF -DataFactoryName $dataFactoryName -PipelineName $pipelineName -Parameter $parameters
}
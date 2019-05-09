Login-AzAccount

Select-AzSubscription -Subscription "<<subscription name>>"

#Data Factory metadata
$rgNameADF = "<<resource group name - ADF>>"
$dataFactoryName = "<<data factory name>>"
$pipelineName = "<<pipeline name>>"
$threshold = 20

#Storage account metadata
$rgNameStorage = "<<resource group name - storage account>>"
$storageAccountName = "<<storage account name>>"
$ContainerName = "<<container name>>"

$defaultBackgroud = $Host.UI.RawUI.BackgroundColor

while (1 -eq 1)
{
    $p = Get-AzureRmDataFactoryV2PipelineRun -ResourceGroupName $rgNameADF -DataFactoryName $dataFactoryName -PipelineName $pipelineName -LastUpdatedAfter (Get-Date).ToUniversalTime().AddHours(-1) -LastUpdatedBefore (Get-Date).ToUniversalTime() 
    $list = $p | Where-Object {$_.Status -eq "InProgress"}

    Write-Output("Processing : {0}" -f $list.Count.ToString())
    
    if ($list.Count -lt $threshold)
    {
        #getting all the blobs from Azure Storage Account
        $storageAccount = Get-AzStorageAccount -ResourceGroupName $rgNameStorage -Name $storageAccountName 
        $blobs = Get-AzStorageBlob -Container $ContainerName -Context $storageAccount.Context -MaxCount $threshold

        $Host.UI.RawUI.BackgroundColor = "Yellow"

        $now = Get-Date
        Write-Output ("{0} : Executing {1} pieplines" -f $now.ToString("yyyy-MM-dd HH:mm:ss"), $blobs.Count.ToString())
        
        $Host.UI.RawUI.BackgroundColor = $defaultBackgroud

        if ($blobs.Count -eq 0)
        {
            break
        }

        #execute ADF pipeline
        foreach($blob in $blobs)
        {
            Write-Output $blob.ICloudBlob.Properties.LeaseState.ToString()
            if ($blob.ICloudBlob.Properties.LeaseState -eq "Expired")
            {
                $sourceFolder = $ContainerName.ToString()+"/"+$blob.Name.Substring(0, $blob.name.LastIndexOf("/") + 1)
                $sourceFile = $blob.Name.Substring($blob.name.LastIndexOf("/") + 1, $blob.name.Length - $blob.name.LastIndexOf("/")-1)

                $obj = ($list | Where-Object {$_.Parameters['sourceFolder'] -eq $sourceFolder -and $_.Parameters['sourceFile'] -eq $sourceFile})
                if (!$obj) #if blob does not be processing, run pipeline
                {
                
                    $parameters = @{
                        "sourceFolder" = $sourceFolder
                        "sourceFile" = $sourceFile
                    }

                    Write-Output ("Folder : {0}, `nFile : {1}" -f $sourceFolder, $sourceFile)

                    Invoke-AzDataFactoryV2Pipeline -ResourceGroupName $rgNameADF -DataFactoryName $dataFactoryName -PipelineName $pipelineName -Parameter $parameters                
                }
            }
        }
    }    
    Write-Output "Waiting for 30 seconds"
    Start-Sleep -Seconds 30
}
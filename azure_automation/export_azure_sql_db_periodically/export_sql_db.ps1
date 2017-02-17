$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

$resourceGroup = "<<your resource group name>>"
$sqlServerName = "<<azure sql db server name>>"
$databaseName = "<<database name>>"

$serverAdmin = "<<azure sql login name>>"
$serverPassword = "<<azure sql login password>>" 
$securePassword = ConvertTo-SecureString -String $serverPassword -AsPlainText -Force
$creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $serverAdmin, $securePassword

# Generate a unique filename for the BACPAC
$bacpacFilename = $sqlServerName + "_" + $databaseName + (Get-Date).ToString("_yyyyMMddHHmm") + ".bacpac"

# Storage account info for the BACPAC
$baseStorageUri = "https://<<your storage account name>>.blob.core.windows.net/<<container>>/"
$bacpacUri = $BaseStorageUri + $bacpacFilename
$storageKeytype = "StorageAccessKey"
$storageKey = "<<storage account key>>"

Write-Output ("Start exporting database into storage account.")
Write-Output (Get-Date)

$exportRequest = New-AzureRmSqlDatabaseExport -ResourceGroupName $resourceGroup -ServerName $sqlServerName `
    -DatabaseName $databaseName -StorageKeytype $storageKeytype -StorageKey $storageKey -StorageUri $bacpacUri `
    -AdministratorLogin $creds.UserName -AdministratorLoginPassword $creds.Password

try
{
    while ($true)
    {
        # Check status of the export
        $status = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $exportRequest.OperationStatusLink
        if ($status.Status -eq "Succeeded") 
        {
            Break
        }
        else
        {
            Write-Output ($status) 
            Start-Sleep -Seconds 5
        }
    }
}
catch 
{
    Write-Error -Message $_.Exception
    throw $_.Exception
}

Write-Output ("Completed...")
Write-Output (Get-Date)
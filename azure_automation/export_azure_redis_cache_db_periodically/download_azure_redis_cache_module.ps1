##http://blog.coretech.dk/jgs/azure-automation-script-for-downloading-and-preparing-azurerm-modules-for-azure-automation/

$folder = "C:\azurePS"

Find-Module -Name AzureRM.RedisCache | Save-Module -force -Path $folder

$dirs = dir $folder -Directory

$dirs | Foreach {
    $source = $_.FullName
    $destination = "$($_.FullName).zip"
    
    If(Test-path $destination) {Remove-item $destination}
    
    Add-Type -assembly "system.io.compression.filesystem"
    [io.compression.zipfile]::CreateFromDirectory($Source, $destination,[System.IO.Compression.CompressionLevel]::Optimal,$true) 
}
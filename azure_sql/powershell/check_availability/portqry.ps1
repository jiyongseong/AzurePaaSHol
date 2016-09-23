$location = "C:\temp\portquery"
$duration = 0
$sleep = 10
$outputfile = "C:\temp\portquery\log.txt"
$dbServerName = "<<your db server name>>.database.windows.net"

$end = if ($duration -eq 0) {"9999-12-31 23:59:59"} else {(Get-Date).AddSeconds($duration)}

Set-Location -Path $location

while((Get-Date) -ile $end)
{
    $content1 = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
    $content2 = cmd /c PortQry.exe -n $dbServerName -p tcp -e 1433 

    Clear-Host
    Write-Host -Object $content1 -BackgroundColor Gray
    $content2 
    $content1 + $content2 | Out-File -FilePath $outputfile -Append

    Start-Sleep -Seconds $sleep
}
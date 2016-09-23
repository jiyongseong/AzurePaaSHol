$location = "C:\temp\portquery"
$duration = 0
$sleep = 10
$outputfile = "C:\temp\portquery\log.txt"
$dbServerName = "<<your db server name>>.database.windows.net"

$end = if ($duration -eq 0) {"9999-12-31 23:59:59"} else {(Get-Date).AddSeconds($duration)}

Set-Location -Path $location


function Write-PortQryResult([string] $result)
{
    $regexPattern = "LISTENING"
    $index = 0
    $regexPattern = "(?i)$regexPattern" 
    $regex = New-Object System.Text.RegularExpressions.Regex $regexPattern

    $match = $regex.Match($result, $index)
    if($match.Success -and $match.Length -gt 0)
	{
        Write-Host ""
		Write-Host $match.Value.ToString() -ForegroundColor DarkGreen -BackgroundColor Yellow 
	}
	else
	{
        Write-Host ""
		Write-Host "Something is wrong!!!!!" -ForegroundColor Red -BackgroundColor Yellow
	}

}

while((Get-Date) -ile $end)
{
    $content1 = Get-Date -Format "yyyy-MM-dd HH:mm:ss" 
    $content2 = cmd /c PortQry.exe -n $dbServerName -p tcp -e 1433 

    Clear-Host
    Write-Host -Object $content1 -BackgroundColor Gray
    $content2
    Write-PortQryResult $content2 
    $content1 + $content2 | Out-File -FilePath $outputfile -Append

    Start-Sleep -Seconds $sleep
}

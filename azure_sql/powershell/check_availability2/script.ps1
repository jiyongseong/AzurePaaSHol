$dbServerName = "<<your db server name>>.database.windows.net"
$port = 1433
$sleep = 10

Clear-Host

while ($true)
{
    $TCPClient = New-Object -TypeName System.Net.Sockets.TCPClient
    try 
    {
        $TCPClient.Connect($dbServerName,$port)
        if ($TCPClient.Connected -eq $true)
        {
            Write-Host ([string]::Format("{0}    '{1}' is listening on {2}.", (Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString(), $dbServerName, $port))
        }
        else
        {
            Write-Host ([string]::Format("{0}    '{1}' is not listening on {2}.", (Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString(), $dbServerName, $port))
        }
    }
    catch
    {
        Write-Host ([string]::Format("{0}    Error occured ({1}): {2}", (Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString(), $_.Exception.Message, $_.Exception.ItemName))
    }
    finally
    {
        $TCPClient.Close()
        $TCPClient.Dispose()
    }

    Start-Sleep -Seconds $sleep
}


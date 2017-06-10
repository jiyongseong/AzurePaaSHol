# Azure SQL Databases 연결 모니터링하기

종종, Azure SQL Databases 서버에 대한 연결이 단절 여부를 모니터링 하는 경우가 있습니다.

C#과 같은 프로그래밍 언어를 이용해서 간단하게 command 응용 프로그램을 작성하여 사용하시기도 하는데요.

portqry.exe를 이용하여 연결 가능 여부를 확인도 가능합니다. portqry.exe를 이용한 확인 방법은 [여기](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_sql/powershell/check_availability)에서 확인할 수 있습니다.

다른 방법으로는 .NET의 System.Net.Sockets.TCPClient를 이용하는 것입니다. portqry.exe를 설치할 필요없이 바로 실행할 수 있다는 장점이 있습니다.

```powershell
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


```
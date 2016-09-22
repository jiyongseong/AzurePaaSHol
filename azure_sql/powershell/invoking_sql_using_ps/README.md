# PowerShell을 이용하여 원격으로 Azure SQL Databases에 쿼리하기

PowerShell을 이용하여 Azure SQL Databases에 쿼리하는 방법은 다음과 같습니다.

```PowerShell

$serverName = "your Azure SQL database Server name. eg,. yourserver.database.windows.net"
$databaseName ="database name"
$userName = "user name"
$password = "password"
$query = "SELECT * FROM sys.objects WHERE is_ms_shipped = 0"

Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -Username $userName -Password $password -Query $query | Format-Table
```
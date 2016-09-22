
$serverName = "your Azure SQL database Server name. eg,. yourserver.database.windows.net"
$databaseName ="database name"
$userName = "user name"
$password = "password"
$query = "SELECT * FROM sys.objects WHERE is_ms_shipped = 0"

Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -Username $userName -Password $password -Query $query | Format-Table
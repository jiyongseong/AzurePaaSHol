$MySQLAdminUserName = '<<user name>>'
$MySQLAdminPassword = '<<password>>'
$MySQLDatabase = '<<database name>>'
$MySQLHost = '<<your server name>>.mysql.database.windows.net'
$ConnectionString = "server=" + $MySQLHost + ";port=3306;uid=" + $MySQLAdminUserName + ";pwd=" + $MySQLAdminPassword + ";database="+$MySQLDatabase
$Query = "INSERT tb_test(col1, col2, col3) VALUES('1', '11', '111')"

Try {
  [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
  $Connection = New-Object -TypeName MySql.Data.MySqlClient.MySqlConnection
  $Connection.ConnectionString = $ConnectionString
  $Connection.Open()

  $Command = New-Object MySql.Data.MySqlClient.MySqlCommand($Query, $Connection)
  
  $stopWatch = New-Object -TypeName System.Diagnostics.Stopwatch
  $stopWatch.Start()

  for ($i=0; $i -le 10000; $i++)
  {
    $Command.ExecuteNonQuery()
  }
  $stopWatch.Elapsed
}

Catch {
  Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
 }

Finally {
  $Connection.Close()
  }
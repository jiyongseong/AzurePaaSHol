# Azure Database for MySQL 데이터 입력 테스트

ADO.NET driver for MySQL 다운로드 : [ADO.NET driver for MySQL](https://dev.mysql.com/downloads/connector/net/)

### 테이블 구조
```sql
create table tb_test 
(
                seq int not null AUTO_INCREMENT,
                col1 char(1),
    col2 char(2),
    col3 char(3),
    primary key (seq)
);
```

### 테스트 스크립트
```powershell
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
```

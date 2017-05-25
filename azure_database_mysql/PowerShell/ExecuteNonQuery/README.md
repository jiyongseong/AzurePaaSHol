# Azure Database for MySQL 데이터 입력 테스트

[ADO.NET driver for MySQL](https://dev.mysql.com/downloads/connector/net/) 다운로드 및 설치

### 테이블 구조

다음의 테이블을 MySQL 사용자 데이터베이스에 생성

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
다음의 스크립트는 앞서 생성한 테이블에 1만개의 데이터를 입력하는 테스트를 수행하고 수행 시간을 결과로 반환

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

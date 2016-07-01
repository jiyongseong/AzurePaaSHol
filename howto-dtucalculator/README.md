# Azure SQL Database DTU Calculator 

[Azure SQL Databases](https://azure.microsoft.com/ko-kr/documentation/articles/sql-database-technical-overview/)를 도입하는 초기에 가장 궁금해 하시는 부분들은 바로 DTU라는 것입니다.

[DTU](https://azure.microsoft.com/ko-kr/documentation/articles/sql-database-service-tiers/#dtu)는 Database Transaction Unit을 의미하며, 데이터베이스 단위로 제공받을 수 있는 성능을 상대적인 수치로 표현한 값을 의미합니다.

앞서, "데이터베이스 단위"라는 표현을 하였습니다. Azure SQL Databases의 [서버](https://azure.microsoft.com/ko-kr/documentation/articles/sql-data-warehouse-get-started-new-server/)는 논리적인 개념이기 때문에, 기존의 SQL Server 인스턴스와는 다른 개념이며, 실질적인 컴퓨팅 자원은 데이터베이스 단위로 할당이 됩니다. 또한 컴퓨팅 자원에 따라서 비용도 발생하게 됩니다.

현재 Azure SQL Databases에서 제공되는 서비스 계층과 성능 수준은 다음과 같습니다.

![](https://acom.azurecomcdn.net/80C57D/cdn/mediahandler/docarticles/dpsmedia-prod/azure.microsoft.com/ko-kr/documentation/articles/sql-database-service-tiers/20160623073503/includes/sql-database-service-tiers-table/sql-database-service-tiers-table.png)

이렇게 온-프레미스와는 다른 방식으로 측정이 이루어지기 때문에, 온-프레미스의 데이터베이스를 Azure SQL Databases로 마이그레이션하려는 경우 DTU를 산정하기 어렵습니다.

때문에, DTU 결정에 도움을 주기 위해서 [Azure SQL Database DTU Calculator](http://dtucalculator.azurewebsites.net/)라는 3rd party 도구가 만들어졌습니다.

__주의 - Azure SQL Database DTU Calculator는 Microsoft에서 제공하는 도구가 아닙니다.___

Azure SQL Database DTU Calculator는 크게 다음과 같이 두 단계에 걸쳐서 실행이 됩니다.
1. 온-프레미스의 리소스 사용량 측정
2. 측정된 리소스 사용량을 기준으로 DTU 산정

첫 번째 단계인 온-프레미스의 리소스 사용량 측정은 다음과 같은 성능 카운터의 값들을 수집하는 단계로, PowerShell 스크립트를 통해서 실행이 이루어집니다.

* Processor - % Processor Time
* Logical Disk - Disk Reads/sec
* Logical Disk - Disk Writes/sec
* Database - Log Bytes Flushed/sec

Azure SQL Database DTU Calculator에서 제공하는 스크립트는 [요기](http://dtucalculator.azurewebsites.net/Downloads/sql-perfmon.zip)에서 다운로드 할 수 있습니다.
해당 스크립트의 단점은 __"server이름\인스턴스"__ 와 같이, 명명된 인스턴스에 대한 부분은 PowerShell cmdlets을 수정해야만 실행할 수 있습니다.
이를 수정한 코드를 작성해보았는데요.. 아래와 같습니다.

```PowerShell

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

cls

$sqlInstances = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL" | Select Property

if ($sqlInstances.Property.Count -eq 1)
{
    $instance = $sqlInstances.Property[0].ToString()
}
else
{
    Write-Host "Installed SQL Server instances"
    Write-Host "-------------------------------"
    $sqlInstances.Property
    Write-Host "-------------------------------"
    $instance = Read-Host -Prompt "Please select SQL Server instance to collect"
}


if ($instance -eq "MSSQLSERVER")
{
    $server = "SQLServer"
}
else
{
    $server = "MSSQL$" + $instance
}

$server

Write-Output "Collecting counters..."
Write-Output "Press Ctrl+C to exit."

$logBytes = "\"+$server+":Databases(_Total)\Log Bytes Flushed/sec"

$counters = @("\Processor(_Total)\% Processor Time", 
"\LogicalDisk(_Total)\Disk Reads/sec", 
"\LogicalDisk(_Total)\Disk Writes/sec", 
$logBytes) 

Get-Counter -Counter $counters -SampleInterval 1 -MaxSamples 3600 | 
    Export-Counter -FileFormat csv -Path "C:\sql-perfmon-log.csv" -Force

```

위의 내용을 사이트에서 다운로드 하신 sql-perfmon.ps1 파일에 덮어 쓰거나, 다른 이름으로 ps1 파일로 저장하고 관리자 권한으로 실행합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/howto-dtucalculator0.jpg)

스크립트를 실행하면, 로컬에 설치된 SQL Server 인스턴스들을 검색하여, 인스턴스 목록을 출력합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/howto-dtucalculator1.jpg)

수집하려는 대상 인스턴스의 이름(아래의 예제에서는 'SQL2016')을 입력하고 엔터를 입력하면, 성능 로그의 수집이 시작됩니다(사이트에서는 최소한 1시간 이상을 수집할 것을 권장하고 있습니다).

![](https://jyseongfileshare.blob.core.windows.net/images/howto-dtucalculator2.jpg)

수집이 완료되면, C:\ 드라이브에 sql-perfmon-log.csv라는 이름의 파일이 생성됩니다.

[http://dtucalculator.azurewebsites.net/](http://dtucalculator.azurewebsites.net/) 사이트로 다시 가서, SQL Server가 설치된 H/W의 CPU 개수와 앞서 수집한 성능 로그 파일을 입력하고 "Calculate" 버튼을 클릭합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/howto-dtucalculator3.jpg)

분석이 완료되면, 다음과 같이 분석 결과가 보여집니다.

![](https://jyseongfileshare.blob.core.windows.net/images/howto-dtucalculator4.jpg)

![](https://jyseongfileshare.blob.core.windows.net/images/howto-dtucalculator4.jpg)

테스트해보고 싶은 분들을 위해서, 예제 성능 로그 파일([sql-perfmon-log.csv](https://github.com/jiyongseong/AzurePaaSHol/blob/master/howto-dtucalculator/sql-perfmon-log.csv))을 같이 올려 두었습니다.
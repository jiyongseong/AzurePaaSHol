# PortQry를 이용한 Azure SQL Databases 연결 모니터링하기

종종, Azure SQL Databases 서버에 대한 연결이 단절 여부를 모니터링 하는 경우가 있습니다.

C#과 같은 프로그래밍 언어를 이용해서 간단하게 command 응용 프로그램을 작성하여 사용하시기도 하는데요.

portqry.exe를 이용하여 연결 가능 여부를 확인도 가능합니다.

#### portqry 설치

먼저, portqry의 설치가 필요합니다.

portqry는 [http://www.microsoft.com/download/details.aspx?id=17148](http://www.microsoft.com/download/details.aspx?id=17148)에서 다운로드 할 수 있습니다.

다운로드 하신 이후에는 별도의 경로에 해당 파일의 압축을 해제하도록 합니다.

파일 압축이 해제되면, 다음과 같이 3개의 파일이 복사됩니다.

![](https://jyseongfileshare.blob.core.windows.net/images/portqry-01.png)

#### PowerShell 실행

다음의 PowerShell을 복사하여, PowerShell 창에 붙여 넣기 합니다.

```PowerShell
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
```

 다음의 매개 변수들을 환경에 맞게 수정합니다.

* $location : poertqry.exe 파일이 있는 경로를 지정합니다.
* $duration : 모니터링 하려는 시간을 초단위로 입력합니다. 0으로 입력하는 경우에는 무한대로 실행이 되며, 사용자가 직접 중지 버튼을 누르거나 Ctrl+C를 눌러서 종료해주어야 합니다.
* $sleep : portqry를 실행 주기를 초 단위로 지정합니다. 10이라고 명시하면, 10초 단위로 portqry 명령을 실행합니다.
* $outputfile : 실행 결과를 저장할 파일과 경로를 입력합니다.
* $dbServerName : __your db server name__.database.windows.net 형식으로 Azure SQL Database 서버의 이름을 입력합니다.

매개 변수 값을 변경한 이후에 실행을 하면, 다음의 그림과 같이 화면에 최신 모니터링 정보가 표시되며, 

![](https://jyseongfileshare.blob.core.windows.net/images/portqry-04.png)

지정된 경로에는 해당 내용이 파일로 저장됩니다.

![](https://jyseongfileshare.blob.core.windows.net/images/portqry-03.png)

PortQry에 대한 자세한 설명은 다음의 자료를 참고하시기 바랍니다.

[Description of the Portqry.exe command-line utility ](https://support.microsoft.com/en-us/kb/310099)

PortQry는 UI 도구로도 제공이 되고 있습니다.

[PortQryUI - User Interface for the PortQry Command Line Port Scanner](https://www.microsoft.com/en-us/download/details.aspx?id=24009)
# JSON 형식의 로그를 CSV 형식으로 변환

Azure Application Gateway에서는 다양한 종류의 로그 정보를 기록할 수 있도록 제공하고 있습니다.

관련 정보는 [다음](https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-diagnostics)을 참고하시기 바랍니다.

해당 로그들은 JSON 형식의 파일로 저장이 됩니다. 로그를 테이블 형식으로 확인하는 것이 편한 경우도 있는데, 이를 위해서 JSON 형식의 로그를 CSV 형식으로 변환하는 코드를 작성하였습니다.


```powershell
$file = "csv file name and location"
$records = Get-Content -Path "application gateway log and location"| ConvertFrom-Json | Select-Object -Expand records | select time, properties

foreach ($record in $records)
{
    $record.properties | Add-Member -NotePropertyName "time" -NotePropertyValue  $record.time
    $record.properties | Export-Csv -Path $file -NoTypeInformation -Append
}
```
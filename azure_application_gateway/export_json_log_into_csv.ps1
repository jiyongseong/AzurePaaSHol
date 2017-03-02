$file = "csv file name and location"
$records = Get-Content -Path "application gateway log and location"| ConvertFrom-Json | Select-Object -Expand records | select time, properties

foreach ($record in $records)
{
    $record.properties | Add-Member -NotePropertyName "time" -NotePropertyValue  $record.time
    $record.properties | Export-Csv -Path $file -NoTypeInformation -Append
}
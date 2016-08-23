
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

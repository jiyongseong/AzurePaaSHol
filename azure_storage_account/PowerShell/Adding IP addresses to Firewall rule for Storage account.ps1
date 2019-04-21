﻿Login-AzAccount

Select-AzSubscription -Subscription "<<subscription name>>"

$rgName = "<<resource group name>>"
$storageName = "<<storage account name>>"

(Get-AzStorageAccountNetworkRuleSet -ResourceGroupName $rgName -AccountName $storageName).IPRules

#uksouth
$ips = "20.38.106.0/23" ,
"20.39.208.0/20" ,
"20.39.224.0/21" ,
"20.190.143.0/25" ,
"40.79.215.0/24" ,
"40.80.0.0/22" ,
"40.81.128.0/19" ,
"40.82.88.0/22" ,
"40.90.17.32/27" ,
"40.90.17.160/27" ,
"40.90.128.112/28" ,
"40.90.128.160/28" ,
"40.90.131.64/27" ,
"40.90.139.64/27" ,
"40.90.153.64/27" ,
"40.90.154.0/26" ,
"40.120.32.0/19" ,
"40.126.15.0/25" ,
"51.104.0.0/19" ,
"51.104.192.0/18" ,
"51.105.0.0/18" ,
"51.105.64.0/20" ,
"51.140.0.0/17" ,
"51.140.128.0/18" ,
"51.141.128.32/27" ,
"51.141.129.64/26" ,
"51.141.130.0/25" ,
"51.141.135.0/24" ,
"51.141.144.0/22" ,
"51.141.192.0/18" ,
"51.143.128.0/18" ,
"51.145.0.0/17" ,
"52.108.50.0/23" ,
"52.109.28.0/22" ,
"52.114.80.0/22" ,
"52.114.88.0/22" ,
"52.136.21.0/24" ,
"52.151.64.0/18" ,
"52.239.187.0/25" ,
"52.239.231.0/24" ,
"52.245.64.0/22" ,
"52.253.162.0/23" ,
"104.44.89.224/27" ,
"13.87.0.0/18" ,
"40.79.201.0/24" ,
"40.80.12.0/22" ,
"40.81.160.0/20" ,
"40.90.130.128/28" ,
"40.90.143.64/27" ,
"40.90.150.96/27" ,
"51.141.129.0/27" ,
"51.141.129.192/26" ,
"51.141.132.0/24" ,
"51.141.156.0/22" ,
"51.142.0.0/17" ,
"51.143.192.0/18" ,
"52.109.40.0/22" ,
"52.136.18.0/24" 

<#
#korea central
$ips = "20.39.184.0/21" ,
"20.39.192.0/20" ,
"20.41.64.0/18" ,
"20.44.24.0/21" ,
"20.150.4.0/23" ,
"20.190.144.128/25" ,
"20.190.148.128/25" ,
"40.79.221.0/24" ,
"40.80.36.0/22" ,
"40.82.128.0/19" ,
"40.90.17.224/27" ,
"40.90.128.176/28" ,
"40.90.131.128/27" ,
"40.90.139.128/27" ,
"40.90.156.64/27" ,
"40.126.16.128/25" ,
"40.126.20.128/25" ,
"52.108.48.0/23" ,
"52.109.44.0/22" ,
"52.114.44.0/22" ,
"52.141.0.0/18" ,
"52.231.0.0/17" ,
"52.232.145.0/24" ,
"52.239.148.0/27" ,
"52.239.164.192/26" ,
"52.239.190.128/26" ,
"52.245.112.0/22" ,
"52.253.173.0/24" ,
"52.253.174.0/24" ,
"104.44.90.160/27" 
#>

$seq = 1

foreach($ip in $ips)
{
    Write-Host $seq.ToString() " out of " $ips.Count.ToString() " : ip range(s) " $ip.ToString()
    Add-AzStorageAccountNetworkRule -ResourceGroupName $rgName -AccountName $storageName -IPAddressOrRange $ip.ToString()
    #Remove-AzStorageAccountNetworkRule -ResourceGroupName $rgName -Name $storageName -IPAddressOrRange $ip.ToString()
    $seq += 1
}
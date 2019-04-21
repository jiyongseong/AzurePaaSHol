
Select-AzSubscription -Subscription "<<subscription name>>"

$rg = "<<resource group name>>"
$dataFactoryName = "<<data factory name>>"
$location = "EAST US"

##Create Integration Runtime
for ($seq = 0; $seq -le 19;$seq++)
{
    $irName = "IR-EASTUS-"+ "0"*(2-$seq.ToString().Length) + $seq.ToString()
    Set-AzDataFactoryV2IntegrationRuntime -ResourceGroupName $rg -DataFactoryName $dataFactoryName -Name $irName -Type Managed -Location $location
}
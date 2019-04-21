Login-AzAccount
Select-AzSubscription -Subscription "<<subscription name>>"

$rg = "<<resource group name>>"
$dataFactoryName = "<<data factory name>>"
$pipelineName = "<<pipeline name>>"

$startAfter = ([DateTime]::UtcNow).AddHours(-24)
$startBefore  = ([DateTime]::UtcNow).AddSeconds(-1)

$filePath = (Get-Date).ToString("yyyyMMddHHmmss")
$pipelineRunFile = $filePath+"_"+$pipelineName+"_ADFPipelineRuns.csv"


#pileline, activity 실행 결과 확인
$pipelineRuns = Get-AzureRmDataFactoryV2PipelineRun -ResourceGroupName $rg -DataFactoryName $DataFactoryName -PipelineName $pipelineName -LastUpdatedAfter $startAfter -LastUpdatedBefore $startBefore

New-Item -ItemType "File" -Path $pipelineRunFile -Force

if ($pipelineRuns.Count -gt 0)
{
    "Pipeline Name`tPipeline Run Start`tPipeline Run End`tPipeline Duration in MS`tParameter[Source folder]`tParameter[Source file]`tPipeline Status" | Out-File -FilePath $pipelineRunFile
}

foreach ($runs in $pipelineRuns)
{
    "{0}`t{1}`t{2}`t{3}`t{4}`t{5}`t{6}" -f $runs.PipelineName, $runs.RunStart, $runs.RunEnd, $runs.DurationInMs, $runs.Parameters["sourceFolder"], $runs.Parameters["sourceFile"], $runs.Status| Out-File -FilePath $pipelineRunFile -Append
}
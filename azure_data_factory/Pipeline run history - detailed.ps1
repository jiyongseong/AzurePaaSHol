Login-AzAccount

Select-AzureRmSubscription -Subscription "<<subscription name>>"

$rg = "<<resource group name>>"
$dataFactoryName = "<<data factory name>>"
$pipelineName = "<<pipeline name>>"

$startAfter = ([DateTime]::UtcNow).AddHours(-24)
$startBefore  = ([DateTime]::UtcNow).AddSeconds(-1)

$filePath = (Get-Date).ToString("yyyyMMddHHmmss")
$pipelineRunFile = $filePath+"_ADFPipelineRuns.csv"
$activityRunFile = $filePath+"_ADFActivityRuns.csv"

#pileline, activity 실행 결과 확인
$pipelineRuns = Get-AzureRmDataFactoryV2PipelineRun -ResourceGroupName $rg -DataFactoryName $DataFactoryName -PipelineName $pipelineName -LastUpdatedAfter $startAfter -LastUpdatedBefore $startBefore

New-Item -ItemType "File" -Path $pipelineRunFile -Force
New-Item -ItemType "File" -Path $ActivityRunFile -Force

if ($pipelineRuns.Count -gt 0)
{
    "Pipeline Name`tPipeline Run Start`tPipeline Run End`tPipeline Duration in MS`tParameter[Source folder]`tParameter[Source file]`tPipeline Status" | Out-File -FilePath $pipelineRunFile
    "Pipeline Name`tPipeline Run Start`tPipeline Run End`tPipeline Duration in MS`tParameter[Source folder]`tParameter[Source file]`tPipeline Status`tActivity Name`tActivity Run Start`tActivity Run End`tActivity Duration in Ms`tActivity Status`tData Read`tData Written`tFiles Read`tFiles Written`tCopy Duration(s)`tSource Type`tSink Type`tStatus`tDuration`tError Code`tMessage`tFailure Type`tTarget" `
    | Out-File -FilePath $activityRunFile
}

foreach ($runs in $pipelineRuns)
{
    "{0}`t{1}`t{2}`t{3}`t{4}`t{5}`t{6}" -f $runs.PipelineName, $runs.RunStart, $runs.RunEnd, $runs.DurationInMs, $runs.Parameters["sourcefolder"], $runs.Parameters["sourcefile"], $runs.Status| Out-File -FilePath $pipelineRunFile -Append

    $activitieRuns = Get-AzureRmDataFactoryV2ActivityRun -ResourceGroupName $rg -DataFactoryName $DataFactoryName -PipelineRunId $runs.RunId -RunStartedAfter $startAfter -RunStartedBefore $startBefore

    foreach ($activityRun in $activitieRuns)
    {
        #activity run output
        if (![String]::IsNullOrEmpty($activityRun.Output))
        {
            $activityRunOutput = $activityRun.Output.ToString() | ConvertFrom-Json

            $dataRead = $activityRunOutput.dataRead
            $dataWritten = $activityRunOutput.dataWritten 
            $filesRead = $activityRunOutput.filesRead
            $filesWritten = $activityRunOutput.filesWritten
            $copyDuration = $activityRunOutput.copyDuration
        }
        else
        {
            $dataRead = ""
            $dataWritten = ""
            $filesRead = ""
            $filesWritten = ""
            $copyDuration = ""
        }

        #execution Details
        if (![String]::IsNullOrEmpty($activityRun.Output.executionDuration))
        {
            $activityRun.Output

            $executionDetails = $activityRun.Output.executionDetails.ToString() | ConvertFrom-Json

            $sourceType = $executionDetails[0].source.type
            $sinkType = $executionDetails[0].sink.type
            $status = $executionDetails[0].status
            $duration = $executionDetails[0].duration
        }
        else
        {
            $sourceType = ""
            $sinkType = ""
            $status = ""
            $duration = ""
        }

        #activity run error
        $activityRunError = $activityRun.Error.ToString() | ConvertFrom-Json

        $errorCode = $activityRunError.errorCode
        $message = $activityRunError.message -replace "\n", " "
        $failureType = $activityRunError.failureType
        $target = $activityRunError.target

        "{0}`t{1}`t{2}`t{3}`t{4}`t{5}`t{6}`t{7}`t{8}`t{9}`t{10}`t{11}`t{12}`t{13}`t{14}`t{15}`t{16}`t{17}`t{18}`t{19}`t{20}`t{21}`t{22}`t{23}`t{24}" `
        -f $runs.PipelineName, $runs.RunStart, $runs.RunEnd, $runs.DurationInMs, $runs.Parameters["sourcefolder"], $runs.Parameters["sourcefile"], $runs.Status, `
        $activityRun.ActivityName, $activityRun.ActivityRunStart, $activityRun.ActivityRunEnd, $activityRun.DurationInMs, $activityRun.Status, `
        $dataRead, $dataWritten, $filesRead, $filesWritten, $copyDuration, `
        $sourceType, $sinkType,$status, $duration, `
        $errorCode, $message, $failureType, $target `
        | Out-File -FilePath $activityRunFile -Append
    }
}

Login-AzAccount
Select-AzSubscription -Subscription "<<subscription name>>"

#https://stackoverflow.com/questions/5156883/indenting-format-table-output-in-powershell-scripts
 function Indent-ConsoleOutput($output, $indent=4){
    if(!($output -eq $null)){
        if(!( $indent -is [string])){
            $indent = ''.PadRight($indent)
        }
        $width = (Get-Host).UI.RawUI.BufferSize.Width - $indent.length
        ($output| out-string).trim().replace( "`r", "").split("`n").trimend()| %{
            for($i=0; $i -le $_.length; $i+=$width){
                if(($i+$width) -le $_.length){ 
                    "$indent"+$_.substring($i, $width)
                }else{
                    "$indent"+$_.substring($i, $_.length - $i)
                }
            }
        }
    }
}

$rg = "<<reousrce group name>>"
$dataFactoryName = "<<data factory name>>"
$pipelineName = "<<pipeline name>>"

while (1 -eq 1)
{
    $startAfter = ([DateTime]::UtcNow).AddHours(-24)
    $startBefore  = ([DateTime]::UtcNow).AddSeconds(-1)
    $now = Get-Date
    $utcNow = [DateTime]::UtcNow
    
    $inProgress = 0
    $failed = 0
    $succeeded = 0     

    #pileline, activity 실행 결과 확인
    $pipelineRuns = Get-AzureRmDataFactoryV2PipelineRun -ResourceGroupName $rg -DataFactoryName $DataFactoryName -PipelineName $pipelineName -LastUpdatedAfter $startAfter -LastUpdatedBefore $startBefore

    $row = New-Object PSObject

    $row | Add-Member -MemberType NoteProperty -Name "PipelineName" -Value ""
    $row | Add-Member -MemberType NoteProperty -Name "RunStart" -Value ""
    $row | Add-Member -MemberType NoteProperty -Name "RunEnd" -Value ""
    $row | Add-Member -MemberType NoteProperty -Name "Duration(Minutes)" -Value ""
    $row | Add-Member -MemberType NoteProperty -Name "Status" -Value ""
    $row | Add-Member -MemberType NoteProperty -Name "SourceFolder" -Value ""
    $row | Add-Member -MemberType NoteProperty -Name "SourceFile" -Value ""
    $row | Add-Member -MemberType NoteProperty -Name "RunId" -Value ""
    $row | Add-Member -MemberType NoteProperty -Name "Message" -Value ""

    $resultSet = [System.Collections.ArrayList]@()

    Clear-Host
    "Time Range : {0} ~ {1}, Now : {2}(UTC) / {3}(Current Timezone)" -f $startAfter, $startBefore, $utcNow, $now

    foreach ($runs in $pipelineRuns)
    {
            
        switch ($runs.Status)
        {
            "InProgress" { $inProgress+=1    }
            "Failed" { $failed+=1    }
            "Succeeded" { $succeeded+=1   }
        }

        if ($runs.Status -ne "Succeeded")
        {
            #$activitieRuns = Get-AzureRmDataFactoryV2ActivityRun -ResourceGroupName $rg -DataFactoryName $DataFactoryName -PipelineRunId $runs.RunId -RunStartedAfter $startAfter -RunStartedBefore $startBefore
            
            $row.PipelineName = $runs.PipelineName
            $row.SourceFolder = $runs.Parameters["sourceFolder"]
            $row.SourceFile = $runs.Parameters["sourceFile"]
            $row.RunStart = $runs.RunStart
            $row.RunEnd = $runs.RunEnd

            switch ($runs.Status)
            {
                "InProgress" { $row.'Duration(Minutes)' = ($utcNow - $runs.RunStart).TotalMinutes }
                "Failed" { $row.'Duration(Minutes)' = $runs.DurationInMs/60000    }
            }
            
            $row.Status = $runs.Status
            $row.RunId = $runs.RunId
            $row.Message = $runs.Message

            $resultSet.Add($row.PsObject.Copy()) | Out-Null

            #$status = "{0} out of {1}" -f ($inProgress+$failed+$succeeded).ToString(), $pipelineRuns.Count.ToString()

            #Write-Progress -Activity "Querying pipeline runs" -Status $status -PercentComplete (($inProgress+$failed+$succeeded)/ $pipelineRuns.Count * 100)

            <#
            foreach ($activityRun in $activitieRuns)
            {
                #activity run output
                if (![String]::IsNullOrEmpty($activityRun.Output))
                {
                    Indent-ConsoleOutput ($activityRun.Output.ToString() | ConvertFrom-Json) 5
                    Write-Host ""
                }

                #execution Details
                if (![String]::IsNullOrEmpty($activityRun.Output.executionDuration))
                {
                    Indent-ConsoleOutput ($activityRun.Output) 5

                    Indent-ConsoleOutput ($activityRun.Output.executionDetails.ToString() | ConvertFrom-Json) 5
                    Write-Host ""
                }
            }
            #>
        }
    }    
    $resultSet | Format-Table
    "Running : {0}, Failed : {1}, Succeeded : {2}" -f $inProgress.ToString(), $failed.ToString(), $succeeded.ToString()
    Start-Sleep -Seconds 120
}
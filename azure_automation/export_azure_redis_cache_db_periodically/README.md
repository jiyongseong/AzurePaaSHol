# Azure Automation을 이용하여 Azure Redis Cache 데이터베이스를 주기적으로 export하기 

Azure Redis Cache는 RDB를 주기적으로 백업할 수 있는 기능을 제공합니다. 

해당 기능을 이용하면, 가장 최근의 RDB 데이터를 이용하여 RDB를 복원할 수 있습니다. 자세한 내용은 다음의 링크를 참고하시기 바랍니다.

[How to configure data persistence for a Premium Azure Redis Cache](https://azure.microsoft.com/en-us/documentation/articles/cache-how-to-premium-persistence/)

RDB 백업은 가장 최근의 백업 파일만 저장하고 있게 됩니다.

따라서, 주기적으로 백업된 RDB의 파일들을 그대로 유지하기 위해서는 Azure Redis Cache의 Export 기능을 이용해야 합니다.

[Import and Export data in Azure Redis Cache](https://azure.microsoft.com/en-us/documentation/articles/cache-how-to-import-export-data/)

Azure Redis Cache의 Export 기능은 UI를 통해서도 가능하고, Azure PowerShell을 이용해서도 가능합니다.

특히, Azure Portal에서 제공되는 Azure Redis Cache Export는 주기적으로 실행할 수 있는 옵션을 제공하지 않습니다.

해당 기능은 Azure Automation을 이용하여 구현이 가능하며, 다음과 같은 순서에 따라서 진행할 수 있습니다.

### 사전 조건

RDB를 Export한 파일을 저장할 Storage Account가 필요합니다. 해당 Storage Account는 Azure Redis Cache 서버가 위치한 것과 동일한 Region에 생성하거나, 생성된 Storage Account가 있어야 합니다.


### 백업 컨테이너 및 SAS 작성하기

먼저, Export한 Azure Redis Cache RDB를 저장할 컨테이너를 만들게 됩니다.

[Microsoft zure Storage Explorer](http://storageexplorer.com/)를 열고, 해당 계정을 추가합니다.

Storage account에서 다음과 같이 백업용 컨테이너를 만듭니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_33.png)

해당 컨테이너에서 오른쪽 마우스를 클릭하고, "Get Shared Access Signature"를 선택합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_20.png)

다음과 같이 설정하고, "Create" 버튼을 클릭합니다. 시작 및 종료 일자는 상황에 맞게 조정합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_21.png)

URL 부분은 복사하여, 잘 저장해두시기 바랍니다. Azure Automation의 Runbook 스크립트(아직은 이것이 무엇인지 몰라도 됩니다)에서 사용하게 됩니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_22.png)

### Azure Automation 계정 생성

먼저, Azure Automation 계정을 생성합니다.

Azure Portal에서 생성하고자 하는 Resource Group에서 "Add" 버튼을 누르고, 상단의 검색 창에서 "Azure Automation"을 입력합니다.

결과 창에서, "Automation"을 선택합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_01.png)

"Create" 버튼을 클릭합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_02.png)

다음의 그림과 같이, Azure Automation Account의 이름, 리소스 그룹, 위치 등을 선택하고 "Create" 버튼을 클릭합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_03.png)

Azure Automation Account가 생성되면, Azure Portal에서는 다음과 같은 화면이 보여집니다.   

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_04.png)

### Azure Redis Cache Module 준비

___해당 작업은 여러 분의 로컬 PC에서 수행해야 합니다.___

Azure Redis Cache의 RDB는 Azure PowerShell을 이용하여 Export하게 됩니다.

Azure Automation은 기본적은 PowerShell module들을 자동으로 Assets에 추가하지만, Azure Redis Cache module은 포함되지 않습니다.

따라서, 이를 수동으로 등록을 해주어야 합니다.

먼저, Azure Redis Cache PowerShell module을 다운로드 하여야 합니다.

Azure PowerShell module을 다운로드 하는 방법은 다음의 링크에서 잘 설명하고 있습니다.

[Azure Automation: Script for downloading and preparing AzureRM modules for Azure Automation!](http://blog.coretech.dk/jgs/azure-automation-script-for-downloading-and-preparing-azurerm-modules-for-azure-automation/)

여기서는 Azure Redis Cache module만 사용할 것이기 때문에, 상기 URL의 PowerShell 스크립트를 다음과 같이 수정합니다.

```PowerShell
$folder = "C:\azurePS"

Find-Module -Name AzureRM.RedisCache | Save-Module -force -Path $folder

$dirs = dir $folder -Directory

$dirs | Foreach {
    $source = $_.FullName
    $destination = "$($_.FullName).zip"
    
    If(Test-path $destination) {Remove-item $destination}
    
    Add-Type -assembly "system.io.compression.filesystem"
    [io.compression.zipfile]::CreateFromDirectory($Source, $destination,[System.IO.Compression.CompressionLevel]::Optimal,$true) 
}
```

PowerShell command line 도구나 PowerShell ISE를 열고, 위의 스크립트를 복사하여 붙여 넣기하고 실행합니다.

실행 전에, C:\azurePS 경로가 없다면, 해당 폴더를 생성합니다.

스크립트를 실행하면, 다음과 같이 관련 모듈들을 다운로드 하게 됩니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_05.png)

실행이 완료되면, C:\azurePS 경로는 다음과 같이 보여지게 됩니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_06.png)

지정한, AzureRM.RedisCache module외에도, AzureRM.profile module도 같이 다운로드 된 것을 볼 수 있습니다. AzureRM.RedisCache module이 AzureRM.profile module에 의존도를 가지기 때문입니다.

### Azure Redis Cache Module 등록

Azure Portal로 돌아와서, 다음의 그림과 같이 Azure Automation Account의 Assets 버튼을 클릭합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_07.png)

다음에는 Module을 선택합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_08.png)

메뉴 상단의 "Add a module"을 클릭합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_09.png)

우측에 있는 파일철 아이콘을 클릭하고,

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_10.png)

AzureRM.profile.zip을 선택하고, OK 버튼을 클릭합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_11.png)

OK 버튼을 클릭하면, 파일이 업로드되고 설치되기 시작합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_12.png)

AzureRM.Profile의 상태가 Available이 되기까지 기다립니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_13.png)

상기와 같은 상태가 되면, AzureRM.RedisCache.zip 파일을 같은 과정으로 업로드 및 설치합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_14.png)

### Azure Automation Runbook 만들기

이제 실제 수행될 PowerShell 스크립트를 작성해보도록 하겠습니다.

Azure Automation 메인 화면으로 돌아와서, Runbook 메뉴를 선택합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_15.png)

상단의 "Add a runbook"을 선택합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_16.png)

"Quick Create" 메뉴를 선택하고, 다음과 같이 이름을 기술하고, Runbook type은 "PowerShell"을 선택하고, "Create" 버튼을 클릭합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_17.png)

생성이 완료되면, 다음과 같이 PowerShell 스크립트를 입력할 수 있는 찾이 보여집니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_18.png)

여기에 다음의 스크립트들을 추가합니다.

```PowerShell
$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

$resourceGroupName = "your resource group name"
$redisServerName = "redis cache server name"
$prefix = (Get-Date -Format yyyyMMddhhmm).ToString()
$container = "SAS string"

Export-AzureRmRedisCache -ResourceGroupName $resourceGroupName -Name $redisServerName -Prefix $prefix -Container $container
```

다음의 항목들을 수정해주어야 합니다.

* $subscriptionName = "your subscription name" : 여러 분의 구독 명칭
* $resourceGroupName = "your resource group name" : 리소스 그룹 이름
* $redisServerName = "redis cache server name" : Azure Redis Server 이름(전체가 아닌 prefix 명칭)
* $prefix = (Get-Date -Format yyyyMMddhhmm).ToString() : export되는 파일의 이름 
* $container = "SAS string" : 앞서 생성한 SAS 문자열 전체

수정이 완료되면, 상단의 "Test Pane"을 선택합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_24.png)

"Test Pane"의 상단에 있는 "Start" 버튼을 클릭하여 테스트를 실행합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_25.png)

정상적인 테스트가 완료되면, 다음과 같이 성공되었다는 표시가 보여지고,

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_26.png)

Redis Cache database의 export된 파일이 보여집니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_32.png)

이전 blade로 넘어와서, 상단에 있는 "Publish" 버튼을 클릭합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_27.png)

### Azure Automation Runbook에 일정 추가

이제는 주기적으로 실행하기 위한 일정을 추가합니다.

Runbook 화면에서, "Schedules" > "Add a schedule"을 클릭합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_28.png)

아래와 같은 순서대로 메뉴를 선택합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_29.png)

원하는 이름과 요구 사항에 맞는 일정을 지정합니다.

아래에서는 한국시간으로 2016년 11월 4일 오후 2시부터(종료 날짜 없음), 1시간마다 한번씩 실행되는 것으로 설정을 하였습니다. 

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_30.png)

차례로 OK 버튼을 눌러서 추가합니다.

![](https://jyseongfileshare.blob.core.windows.net/images/export_azure_redis_cache_db_periodically_31.png)

이제 주기적으로 Azure Redis Cache의 RDB가 Storage Account에 export 되어 집니다.
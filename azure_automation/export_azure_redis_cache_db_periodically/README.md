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

Azure Redis Cache의 RDB는 Azure PowerShell을 이용하여 Export하게 됩니다.

Azure Automation은 기본적은 PowerShell module들을 자동으로 Assets에 추가하지만, Azure Redis Cache module은 포함되지 않습니다.

따라서, 이를 수동으로 등록을 해주어야 합니다.

먼저, Azure Redis Cache PowerShell module을 다운로드 하여야 합니다.

 
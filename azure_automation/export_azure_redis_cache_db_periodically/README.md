# Azure Automation을 이용하여 Azure Redis Cache 데이터베이스를 주기적으로 export하기 

Azure Redis Cache는 RDB를 주기적으로 백업할 수 있는 기능을 제공합니다. 

해당 기능을 이용하면, 가장 최근의 RDB 데이터를 이용하여 RDB를 복원할 수 있습니다. 자세한 내용은 다음의 링크를 참고하시기 바랍니다.

[How to configure data persistence for a Premium Azure Redis Cache](https://azure.microsoft.com/en-us/documentation/articles/cache-how-to-premium-persistence/)

RDB 백업은 가장 최근의 백업 파일만 저장하고 있게 됩니다.

따라서, 주기적으로 백업된 RDB의 파일들을 그대로 유지하기 위해서는 Azure Redis Cache의 Export 기능을 이용해야 합니다.

[Import and Export data in Azure Redis Cache](https://azure.microsoft.com/en-us/documentation/articles/cache-how-to-import-export-data/)

Azure Redis Cache의 Export 기능은 UI를 통해서도 가능하고, Azure PowerShell을 이용해서도 가능합니다.

특히, Azure Portal에서 제공되는 Azure Redis Cache Export는 주기적으로 실행할 수 있는 옵션을 제공하지 않습니다.

해당 기능은 Azure Automation을 이용하여 구현이 가능합니다.


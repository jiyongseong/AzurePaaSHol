# Azure Function App을 이용하여 WAD(Windows Azure Diagnostics) 성능 데이터 정리하기 - Windows 인스턴스 버전

Windows Azure VM과 Cloud Service(Web/Worker Role), Service Fabric의 성능 정보를 Azure Storage Account에 저장할 수 있도록 설정이 가능합니다.

관련되어서 자세한 정보는 다음의 링크들을 참고하시기 바랍니다.

* [What is Microsoft Azure Diagnostics](https://azure.microsoft.com/en-us/documentation/articles/azure-diagnostics/)
* [Enabling Azure Diagnostics in Azure Cloud Services](https://azure.microsoft.com/en-us/documentation/articles/cloud-services-dotnet-diagnostics/)
* [Enabling Diagnostics in Azure Virtual Machines](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-dotnet-diagnostics/)

VM 또는 인스턴스들이 Windows 운영 체제를 사용하는 경우에는 성능 카운터 정보가 지정된 Storage Account의 WADPerformanceCountersTable라는 테이블에 저장이 됩니다.

해당 데이터를 이용하여 각 인스턴스의 성능과 관련된 정보를 수집하여 볼 수 있습니다.

WADPerformanceCountersTable 테이블을 사용하면서 자주 받는 질문 중에 하나가, 오래된 로그 데이터를 삭제하거나 데이터의 retention 기간을 지정할 수 있는지입니다.

안타깝게도 현재는 Azure Storage Table의 데이터에 대해서는 retention 기간을 지정할 수 없습니다.

따라서, 직접 오래된 데이터는 삭제해야 하는데, 여간 번거로운 것이 아닙니다. 

이를 자동화할 수 있는 방법을 고민하다가, Azure Function으로 구현을 해보았습니다.

Azure Function을 생성하는 절차에 대해서는 다음의 문서를 참고하시기 바랍니다.

[Create your first Azure Function](https://azure.microsoft.com/en-us/documentation/articles/functions-create-first-azure-function/)

이와 유사한 방식으로, AWS S3의 데이터를 Azure Storage Blob로 가져오는 방법을 구현한 적이 있습니다. 
이 역시도 참고하시기 바랍니다.

[Azure Function App을 이용하여 AWS S3 파일을 Storage account로 복사하기](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_function/copy-awss3-to-azure-storageaccount-using-functionapp)

이제 코드로 들어가겠습니다.

Azure Storage를 사용하여야 하기 때문에, 다음과 같이 project.json 파일을 만들고(만드는 방법은 바로 위에 있는 링크를 참고하세요), 아래의 코드를 붙여 넣기 합니다.

**project.json**
```JSON
{
  "frameworks": {
    "net46":{
        "dependencies": {
    "WindowsAzure.Storage": "7.0.0"
  }
    }
  }
}
```

다음은 실제 코드입니다.

*주의 : 저는 개발자가 아닙니다. 따라서, 이번 포스트에서는 이렇게 가능하다 정도의 수준에서 작성된 코드를 설명하고 있습니다. 따라서 완성된 방식으로 동작하는 코드에 대해서는 전문 개발자와 상담하십쇼.*

다음의 코드에서는 아래 부분을 수정해주어야 합니다.

* AccountName=<<여기에 Azure 저장소 계정 이름을 넣습니다.>>
* AccountKey=<<상기 저장소 계정의 키를 입력합니다.>>

string connectionString = "DefaultEndpointsProtocol=https;AccountName=<<Storage Account Name>>;AccountKey=<<Storage account key>>";

다음의 코드에서는 7일 이전의 데이터는 모두 삭제하도록 설정을 하였습니다. 

필요에 따라서, 날짜를 변경하여 사용하시면 됩니다.

string startTicks = "0" + DateTime.UtcNow.AddDays(**-7**).Date.Ticks.ToString();

**run.csx**
```C#
using System;
using System.Collections.Generic;

using Microsoft.Azure;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Table;

public static void Run(TimerInfo myTimer, TraceWriter log)
{
    log.Info($"C# Timer trigger function executed at: {DateTime.Now}");  
    job(log);
}

private static void job(TraceWriter log)
{
    
    string connectionString = "DefaultEndpointsProtocol=https;AccountName=<<Storage Account Name>>;AccountKey=<<Storage account key>>";
    CloudStorageAccount storageAccount = CloudStorageAccount.Parse(connectionString);

    CloudTableClient tableClient = storageAccount.CreateCloudTableClient();

    CloudTable table = tableClient.GetTableReference("WADPerformanceCountersTable");

    string startTicks = "0" + DateTime.UtcNow.AddDays(-7).Date.Ticks.ToString();

    TableQuery<PerformanceCountersEntity> query = new TableQuery<PerformanceCountersEntity>()
        .Where(TableQuery.GenerateFilterCondition("PartitionKey", QueryComparisons.LessThan, startTicks)).Select(new List<string>() { "RowKey" }).Take(100);

    bool moreTogo = true;
	
	DateTime start = DateTime.UtcNow;
	
	while (moreTogo == true)
    {
        TableBatchOperation batchDelete = new TableBatchOperation();
        
        bool hasMoreEntities = true;

        string ptKey = "";
        foreach (PerformanceCountersEntity entity in table.ExecuteQuery(query))
        {
            
            if (ptKey == "")
                ptKey = entity.PartitionKey;
            if (ptKey != entity.PartitionKey)
            {
 
                hasMoreEntities = false;
                break;
            }

            batchDelete.Delete(entity);
        }

        if (hasMoreEntities == true)
            moreTogo = (batchDelete.Count >= 100);
        else
        {
            hasMoreEntities = true;
        
            DateTime workingKey = new DateTime(Convert.ToInt64(ptKey.Substring(1, ptKey.Length - 1)));
            log.Info(workingKey.ToString() + " will be deleted");
        }
        
        if (batchDelete.Count > 0)
        {
            table.ExecuteBatch(batchDelete);
            log.Info("deleted row(s) : " + batchDelete.Count.ToString());
        }
    }
    
    DateTime completed = DateTime.UtcNow;
    
    log.Info("Started at " + start.ToString());
	log.Info("Completed at " + completed.ToString());
	
}

public class PerformanceCountersEntity : TableEntity
{
    public long EventTickCount { get; set; }
    public string DeploymentId { get; set; }
    public string Role { get; set; }
    public string RoleInstance { get; set; }
    public string CounterName { get; set; }
    public double CounterValue { get; set; }
}
```

마지막으로 해당 Azure Function이 수행될 시간을 지정하는 부분입니다. 아래의 코드에서는 UTC 기준으로 15시에 실행이 되도록 되어 있으니, KST로는 오전 0시에 실행이 되겠습니다.

**function.json**
```json
{
  "bindings": [
    {
      "name": "myTimer",
      "type": "timerTrigger",
      "direction": "in",
      "schedule": "0 0 15 * * *"
    }
  ],
  "disabled": false
}
```

timer trigger의 CRON 표현식에 대해서는 다음의 링크를 참고하시기 바랍니다.

[Azure Functions timer trigger](https://azure.microsoft.com/en-us/documentation/articles/functions-bindings-timer/)

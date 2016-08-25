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
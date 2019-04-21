using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Rest;
using Microsoft.Azure.Management.ResourceManager;
using Microsoft.Azure.Management.DataFactory;
using Microsoft.Azure.Management.DataFactory.Models;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Newtonsoft.Json.Linq;

namespace ConsoleAppDataFactory
{
    class Program
    {
        static string tenantID = "tenant id";
        static string applicationId = "application id";
        static string authenticationKey = "authentication key";
        static string subscriptionId = "subscription id";
        static string resourceGroupName = "resource group name";
        static string dataFactoryName = "data factory name";
        static string pipelineName = "pipeline name";

        static DateTime endAfter = DateTime.Now;
        static DateTime startAfter = endAfter.AddHours(-120);

        static void Main(string[] args)
        {
            var context = new AuthenticationContext("https://login.windows.net/" + tenantID);
            ClientCredential cc = new ClientCredential(applicationId, authenticationKey);
            AuthenticationResult result = context.AcquireTokenAsync("https://management.azure.com/", cc).Result;
            ServiceClientCredentials cred = new TokenCredentials(result.AccessToken);
            var client = new DataFactoryManagementClient(cred) { SubscriptionId = subscriptionId };

            Console.WriteLine("Pipeline Name : {0}, From {1} to {2}", pipelineName, startAfter.ToString(), endAfter.ToString());
            PipelineRunsQueryResponse pipeRuns =  client.PipelineRuns.QueryByFactory(resourceGroupName, dataFactoryName, new RunFilterParameters(startAfter, endAfter));

            printPipelines(client, pipeRuns);

            while (pipeRuns.ContinuationToken != null)
            {
                pipeRuns = client.PipelineRuns.QueryByFactory(resourceGroupName, dataFactoryName, new RunFilterParameters(startAfter, endAfter, pipeRuns.ContinuationToken));
                printPipelines(client, pipeRuns);
            }
            Console.WriteLine("-----------------------------------------------------------------------------");
            Console.ReadLine();
        }

        static void printPipelines(DataFactoryManagementClient client, PipelineRunsQueryResponse pipelineRuns)
        {
            var enumerator = pipelineRuns.Value.GetEnumerator();
            string runId;

            PipelineRun pipelineRun;

            while (enumerator.MoveNext())
            {
                pipelineRun = enumerator.Current;
                if (pipelineRun.PipelineName == pipelineName)
                {
                    Console.BackgroundColor = ConsoleColor.White;
                    Console.ForegroundColor = ConsoleColor.Black;

                    runId = pipelineRun.RunId;
                    Console.Write("Start:{1}, End:{2}, Duration(ms):{3}, RunID : {0} - ", runId.ToString(), pipelineRun.RunStart.ToString(), pipelineRun.RunEnd.ToString(), pipelineRun.DurationInMs);
                    if (pipelineRun.Status != "Succeeded")
                    {
                        Console.BackgroundColor = ConsoleColor.Yellow;
                        Console.ForegroundColor = ConsoleColor.Red;
                    }
                    Console.WriteLine("{0}", pipelineRun.Status);

                    Console.BackgroundColor = ConsoleColor.Black;
                    Console.ForegroundColor = ConsoleColor.White;

                    Console.WriteLine("Folder Name :{0}", pipelineRun.Parameters.Count == 0? "N/A" : pipelineRun.Parameters["sourcefolder"].ToString());
                    Console.WriteLine("File Name :{0}", pipelineRun.Parameters.Count == 0 ? "N/A" : pipelineRun.Parameters["sourcefile"].ToString());

                    ActivityRunsQueryResponse activities = client.ActivityRuns.QueryByPipelineRun(resourceGroupName, dataFactoryName, runId, new RunFilterParameters(startAfter, endAfter));
                    printActivities(client, activities);

                    while (activities.ContinuationToken != null)
                    {
                        activities = client.ActivityRuns.QueryByPipelineRun(resourceGroupName, dataFactoryName, runId, new RunFilterParameters(startAfter, endAfter, activities.ContinuationToken));
                        printActivities(client, activities);
                    }
                }
            }
        }

        static void printActivities(DataFactoryManagementClient client, ActivityRunsQueryResponse activity)
        {
            var activityEnumerator = activity.Value.GetEnumerator();
            ActivityRun activityRun;

            while (activityEnumerator.MoveNext())
            {
                activityRun = activityEnumerator.Current;

                //Console.WriteLine("Activity Name:{0}, Start:{1}, End:{2}, Duration(ms):{3}, Status:{4}", activityRun.ActivityName, activityRun.ActivityRunStart.ToString(), activityRun.ActivityRunEnd.ToString(), activityRun.DurationInMs.ToString(), activityRun.Status);
                Console.Write("     {0} : {1} ~ {2}({3} ms) - ", activityRun.ActivityName, activityRun.ActivityRunStart.ToString(), activityRun.ActivityRunEnd.ToString(), activityRun.DurationInMs.ToString());

                if (activityRun.Status != "Succeeded")
                {
                    Console.BackgroundColor = ConsoleColor.Yellow;
                    Console.ForegroundColor = ConsoleColor.Red;
                }
                Console.WriteLine("{0}", activityRun.Status);
                Console.BackgroundColor = ConsoleColor.Black;
                Console.ForegroundColor = ConsoleColor.White;

                if (activityRun.Output != null)
                {
                    JObject jObject = JObject.Parse(activityRun.Output.ToString());
                    Console.WriteLine("         Data Read : {0}", jObject.SelectToken("dateRead"));
                    Console.WriteLine("         Files read : {0}", jObject.SelectToken("filesRead"));
                    Console.WriteLine("         Files written : {0}", jObject.SelectToken("filesWritten"));
                    Console.WriteLine("         Copy duration : {0}(s)", jObject.SelectToken("copyDuration"));

                    if (jObject.SelectToken("errors") != null)
                    {
                        if (jObject.SelectToken("errors").Count() > 0)
                        {
                            JArray jErrorArray = JArray.Parse(jObject.SelectToken("errors").ToString());
                            foreach (JObject jError in jErrorArray)
                            {
                                JObject jErrorObject = JObject.Parse(jError.ToString());

                                Console.ForegroundColor = ConsoleColor.Red;
                                Console.WriteLine("Error Code: {0}, Error Message : {1}", jErrorObject.SelectToken("Code").ToString(), jErrorObject.SelectToken("Message").ToString());
                                Console.ForegroundColor = ConsoleColor.White;
                            }
                        }
                    }
                    /*jObject.SelectToken("dateRead");
                    dataWritten
                    filesRead
                    filesWritten
                    sourcePeakConnections
                    sinkPeakConnections
                    copyDuration
                    throughput
                    errors
                    effectiveIntegrationRuntime
                    usedDataIntegrationUnits
                    usedParallelCopies
                    */

                    //Execution Details
                    JArray executionDetails = (JArray)jObject.SelectToken("executionDetails");
                    if (executionDetails != null)
                    {
                        foreach (JToken executionDetail in executionDetails)
                        {
                            Console.WriteLine("             Source Type : {0}", executionDetail.SelectToken("source").SelectToken("type"));
                            Console.WriteLine("             Sink Type : {0}", executionDetail.SelectToken("sink").SelectToken("type"));
                            Console.WriteLine("             Status : {0}", executionDetail.SelectToken("status"));
                            Console.WriteLine("             Duration : {0}", executionDetail.SelectToken("duration"));
                            Console.WriteLine("             UsedParallelCopies : {0}", executionDetail.SelectToken("usedParallelCopies"));
                            /*
                            Console.WriteLine(executionDetail.SelectToken("sink").SelectToken("type"));
                            Console.WriteLine(executionDetail.SelectToken("status"));
                            sink.type
                            start
                            duration
                            usedDataIntegrationUnits
                            usedParallelCopies
                            detailedDurations.queuingDuration
                            detailedDurations.transferDuration
                            */
                        }
                    }
                }
            }
        }
    }
}
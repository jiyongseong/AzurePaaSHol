using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Globalization;

using Amazon.S3;
using Amazon.S3.Model;
using Amazon.S3.Transfer;
using Amazon.S3.Util;

using Microsoft.WindowsAzure;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
    
public static void Run(string input, TraceWriter log)
{
    log.Info($"C# manually triggered function called with input: {input}");
    CopyToAzure(log);
}

private static void CopyToAzure(TraceWriter log)
{    
    string awsAccessKey = "AKIAIZDK5LW3X5ZAUWZQ";
    string awsSecretKey = "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";
    string awsBucketName = "jyseongbucket";
    string objectUrlFormat = "https://{0}.s3.amazonaws.com/{1}";

    string storageAccountName = "usingdockerstorage";
    string storageAccountKey = "cNhRboSgBzzkPXkllcYs9n36/RHdmp+mJzMA+1COePsiLskxUZMHx5SJFLDKaL0yvF6GEb6pMGUq0L5Evt+dlQ==";
    string containerName = "s3container";
    string connectionString = $"DefaultEndpointsProtocol=https;AccountName={storageAccountName};AccountKey={storageAccountKey}";

    AmazonS3Client awsClient = new AmazonS3Client(awsAccessKey, awsSecretKey, Amazon.RegionEndpoint.USEast1);
    
    CloudStorageAccount storageAccount = CloudStorageAccount.Parse(connectionString);
    CloudBlobClient blobClient = storageAccount.CreateCloudBlobClient();
    CloudBlobContainer container = blobClient.GetContainerReference(containerName);

    string nextObj = null;
    bool hasObjects = true;

    while (hasObjects)
            {
                 
                ListObjectsRequest s3ListObjects = new ListObjectsRequest()
                {
                    BucketName = awsBucketName,
                    Marker = nextObj,
                    MaxKeys = 1000,
                };

                log.Info("-------------------------------------------------------------------------------------");
                log.Info("Listing objects of S3 Bucket....");

                var objectList = awsClient.ListObjects(s3ListObjects);
                var s3ObjectCol = objectList.S3Objects;

                log.Info("Copying starts....");
                nextObj = objectList.NextMarker;
                foreach (var s3Object in s3ObjectCol)
                {
                    string objectKey = s3Object.Key;
                    if (!objectKey.EndsWith("/"))
                    {
                        string objectUri = string.Format(CultureInfo.InvariantCulture, objectUrlFormat, awsBucketName, objectKey);
                        
                        log.Info(objectUri);

                        CloudBlockBlob blockBlob = container.GetBlockBlobReference(objectKey);
                        var blockBlobUrl = blockBlob.Uri.AbsoluteUri;
                        try
                        {
                            blockBlob.BeginStartCopy(new Uri(objectUri), null, null);
                        }
                        catch (System.Exception e)
                        {
                            log.Error(e.Message);
                        }
                        
                        log.Info("copied.");
                    }
                }
                log.Info("");
                log.Info("-------------------------------------------------------------------------------------");
                
                 if (string.IsNullOrWhiteSpace(nextObj))
                {
                    hasObjects = false;
                }
            }    
        log.Info("completed..");
}
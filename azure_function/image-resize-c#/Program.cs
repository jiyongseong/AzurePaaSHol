using System.Collections.Generic;
using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
 
using Microsoft.Extensions.Configuration; 
using System.Text.Json.Serialization;
using Azure.Core;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using System.Drawing;
using System.IO;
 
using System.ComponentModel;
 
namespace Microsoft.FunctionSample
{
    public class ImageData
    {
        public string imageName { get; set; }
        public int width { get; set; }
        public int height { get; set; }
    }
    
    public static class ImageResize
    {
        [Function("ImageResize")]
        public static HttpResponseData Run([HttpTrigger(AuthorizationLevel.Function, "get", "post")] HttpRequestData req,
            FunctionContext executionContext)
        {
            var logger = executionContext.GetLogger("ImageResize");
            logger.LogInformation("C# HTTP trigger function processed a request.");
 
            string requestBody = HttpRequestDataExtensions.ReadAsString(req);
            var body = System.Text.Json.JsonSerializer.Deserialize<ImageData>(requestBody);
            string imageName = body.imageName;
            int width = (int)body.width;
            int height = (int)body.height;
            HttpStatusCode httpStatus = HttpStatusCode.OK;
            string returnMessage = "";
            
            string ConnectionString = System.Environment.GetEnvironmentVariable("ConnectionString");
            string containerName = "image";
 
            logger.LogInformation(string.Format("Image Name : {0}, Width : {1}, Height : {2}", imageName, width.ToString(), height.ToString()));
            logger.LogInformation(string.Format("Connection String : {0}, Container : {1}", ConnectionString, containerName));
            
            BlobServiceClient serviceClient = new BlobServiceClient(ConnectionString);
            BlobContainerClient container = serviceClient.GetBlobContainerClient(containerName);   
 
            string currentPath = Path.GetTempPath();
            string localImagePath = Path.Combine(currentPath, imageName);
            string newImageName = width.ToString() + "x" + height.ToString() + "_" + imageName;
            string newImagePath = Path.Combine(currentPath, newImageName);
            string imageUri = container.Uri.ToString();
 
            logger.LogInformation(string.Format("Local Image : {0}, New Image : {1}", localImagePath, newImagePath));
 
            // Tag 검색 - container, Name, width, height 
            string queryString = string.Format(@"@container = '{0}' AND ""Name"" = '{1}' AND ""width"" = '{2}' AND ""height"" = '{3}'", containerName, imageName, width.ToString(), height.ToString());
 
            // 첫번째 결과만 반환
            List<string> images = new List<string>();
            foreach (TaggedBlobItem taggedBlobItem in serviceClient.FindBlobsByTags(queryString))
            {
                images.Add(taggedBlobItem.BlobName);
            }
            
            // 결과가 없는 경우, resize하고 upload /w tag
            if (images.Count == 0)
            {
                logger.LogInformation("Resizing image started.");
 
                BlobClient blobClient = container.GetBlobClient(imageName);
                if (blobClient.Exists())
                {              
                    // 해당 blob가 있는 경우에는 resize  
                    blobClient.DownloadTo(localImagePath);
 
                    Bitmap newBitmap = new Bitmap(width, height);
                    Graphics newImage = Graphics.FromImage(newBitmap);
                    newImage.DrawImage(Image.FromFile(localImagePath), 0, 0, width, height);
                    newBitmap.Save(newImagePath);
                    newBitmap.Dispose();
                    newImage.Dispose();
 
                    Dictionary<string, string> tags = new Dictionary<string, string>
                    {
                        { "Name", imageName },
                        { "width", width.ToString() },
                        { "height", height.ToString() }
                    };
 
                    blobClient = container.GetBlobClient(newImageName); 
                    blobClient.Upload(newImagePath);
                    blobClient.SetTags(tags);
                    imageUri += "/" + newImageName;
                    logger.LogInformation(string.Format("New image processed. : {0}", newImageName));
                    httpStatus = HttpStatusCode.OK;
                    returnMessage=imageUri;
                }
                else
                {
                    // blob이 없는 경우, 오류
                    httpStatus = HttpStatusCode.BadRequest;
                    returnMessage =string.Format("Blob '{0}' does not exist.", imageName);
 
                }
            }
            // 결과가 있는 경우, container name과 blob name을 반환
            else
            {
                imageUri += "/" + images[0];
                logger.LogInformation(string.Format("Found Blobs by Tags. : {0}", images[0]));
                httpStatus = HttpStatusCode.OK;
                returnMessage=imageUri;                
            }
            
            var response = req.CreateResponse(httpStatus);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");
            response.WriteString(returnMessage);
            return response;
        }
    }
}
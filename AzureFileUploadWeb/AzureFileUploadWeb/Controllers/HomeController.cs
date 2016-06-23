using AzureFileUploadWeb.Models;
using Microsoft.Azure;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace FileUploadViewer.Controllers
{
    public class HomeController : Controller
    {
        string containerName = "";
        string StorageConnectionString = string.Empty;
        CloudBlobContainer storageContainer;

        private readonly List<Client> blobs = new List<Client>();

        public HomeController()
        {
            //저장소 연결 문자열 가져오기
            StorageConnectionString = CloudConfigurationManager.GetSetting("StorageConnectionString");

            containerName = CloudConfigurationManager.GetSetting("ContainerName");

            // 저장소 계정 가져오기
            CloudStorageAccount storageAccount = CloudStorageAccount.Parse(StorageConnectionString);

            // blob 클라이언트 생성.
            CloudBlobClient blobClient = storageAccount.CreateCloudBlobClient();

            // 기존의 컨테이너 참조 가져오기
            storageContainer = blobClient.GetContainerReference(containerName);
        }

        public ActionResult Index()
        {
            this.LoadBlobLists();

            return View(blobs);
        }

        [HttpPost]
        public ActionResult UploadFiles(HttpPostedFileBase file)
        {
            if (Request.Files.Count > 0)
            {
                for (int fileNum = 0; fileNum < Request.Files.Count; fileNum++)
                {
                    string fileName = Path.GetFileName(Request.Files[fileNum].FileName);
                    if (Request.Files[fileNum] != null && Request.Files[fileNum].ContentLength > 0)
                    {
                        // Azure Storage로 파일 업로드 수행
                        CloudBlockBlob blockBlob = storageContainer.GetBlockBlobReference(fileName);
                        blockBlob.UploadFromStream(Request.Files[fileNum].InputStream);
                    }
                }
                return RedirectToAction("Index");
            }

            return View("Index");

        } 


        private void LoadBlobLists()
        {
            // Loop over items within the container and output the length and URI.
            foreach (IListBlobItem item in storageContainer.ListBlobs(null, false))
            {
                if (item.GetType() == typeof(CloudBlockBlob) || item.GetType() == typeof(CloudPageBlob))
                {
                    CloudBlockBlob blob = (CloudBlockBlob)item;

                    string blobType = blob.Properties.BlobType.ToString();
                    long blobSize =  blob.Properties.Length;
                    Uri blobUri = blob.Uri;
                    string blobName = blob.Name;

                    blobs.Add(new Client()
                        { Name = blobName, Type = blobType, Size = blobSize, URL = blobUri.ToString() }
                    );

                }
                else if (item.GetType() == typeof(CloudBlobDirectory))
                {
                    CloudBlobDirectory directory = (CloudBlobDirectory)item;

                    Console.WriteLine("Directory: {0}", directory.Uri);
                }
            }
        }
    }
}
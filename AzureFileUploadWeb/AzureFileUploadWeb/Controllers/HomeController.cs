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
        string containerName = "files";
        string StorageConnectionString = string.Empty;

        public HomeController()
        {
            StorageConnectionString = CloudConfigurationManager.GetSetting("StorageConnectionString");
        }

        public ActionResult Index()
        {
            return View();
        }

        [HttpPost]
        public ActionResult UploadFiles(HttpPostedFileBase file)
        {
            if (Request.Files.Count > 0)
            {
                CloudStorageAccount storageAccount = CloudStorageAccount.Parse(StorageConnectionString);

                // Create the blob client.
                CloudBlobClient blobClient = storageAccount.CreateCloudBlobClient();

                // Retrieve reference to a previously created container.
                CloudBlobContainer storageContainer = blobClient.GetContainerReference(containerName);

                for (int fileNum = 0; fileNum < Request.Files.Count; fileNum++)
                {
                    string fileName = Path.GetFileName(Request.Files[fileNum].FileName);
                    if (Request.Files[fileNum] != null && Request.Files[fileNum].ContentLength > 0)
                    {
                        CloudBlockBlob blockBlob = storageContainer.GetBlockBlobReference(fileName);
                        blockBlob.UploadFromStream(Request.Files[fileNum].InputStream);
                    }
                }
                return RedirectToAction("Index");
            }

            return View("Index");

        } 

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}
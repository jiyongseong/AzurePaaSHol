using System;
using System.Linq;

namespace AzureFileUploadWeb.Models
{
    public class BlobItem
    {
        public string Name { get; set; }
        public string Type { get; set; }
        public string URL { get; set; }

        public long Size { get; set; }
    }
}

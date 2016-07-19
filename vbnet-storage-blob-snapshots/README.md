# Create a blob snapshot - vb.net

천대받는 VB.NET을 위해서 만들어보았습니다.

아래의 코드는 [Create a blob snapshot](https://azure.microsoft.com/en-us/documentation/articles/storage-blob-snapshots/) 링크에 있는 C# 코드를 VB.NET으로 바꾼 것입니다.

```vbnet
''Create the blob service client object.
Const ConnectionString As String = "DefaultEndpointsProtocol=https;AccountName=account-name;AccountKey=account-key"

Dim storageAccount As CloudStorageAccount
Dim blobClient As CloudBlobClient

storageAccount = CloudStorageAccount.Parse(ConnectionString)
blobClient = storageAccount.CreateCloudBlobClient

''Get a reference to a container.
Dim container As CloudBlobContainer = blobClient.GetContainerReference("sample-container")
container.CreateIfNotExists()

''Get a reference to a blob.
Dim blob As CloudBlockBlob = container.GetBlockBlobReference("sampleblob.txt")
blob.UploadText("This is a blob.")

''Create a snapshot of the blob and write out its primary URI.
Dim blobSnapshot As CloudBlockBlob = blob.CreateSnapshot()
Console.WriteLine(blobSnapshot.SnapshotQualifiedStorageUri.PrimaryUri)
```

앞으로, Azure 문서 중에서 C#이나 Java와 같이 다른 언어로 작성된 코드들을 VB.NET으로 작성할 예정입니다.
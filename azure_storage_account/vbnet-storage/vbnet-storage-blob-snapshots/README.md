# Blob 스냅숏 만들기 - vb.net

아래의 코드는 [Blob 스냅숏 만들기](https://azure.microsoft.com/ko-kr/documentation/articles/storage-blob-snapshots/) 링크에 있는 C# 코드를 VB.NET으로 바꾼 것입니다.

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
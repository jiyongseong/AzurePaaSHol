# .NET을 사용하여 Azure Blob 저장소 시작 - vb.net

아래의 코드는 [.NET을 사용하여 Azure Blob 저장소 시작](https://azure.microsoft.com/ko-kr/documentation/articles/storage-dotnet-how-to-use-blobs/) 링크에 있는 C# 코드를 VB.NET으로 바꾼 것입니다.

## 개발 환경 설정

### 네임스페이스 선언 추가
```vbnet
Imports Microsoft.Azure     ''Namespace for CloudConfigurationManager
Imports Microsoft.WindowsAzure.Storage  ''Namespace for CloudStorageAccount
Imports Microsoft.WindowsAzure.Storage.Blob     ''Namespace for Blob storage types

Imports System.IO
```

## 컨테이너 만들기
```vbnet
''Retrieve storage account from connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))
''Create the blob client.
Dim blobClient As CloudBlobClient = storageAccount.CreateCloudBlobClient()
''Retrieve a reference to a container.
Dim container As CloudBlobContainer = blobClient.GetContainerReference("mycontainer")
''Create the container if it doesn't already exist.
container.CreateIfNotExists()

Dim containerPermission As New BlobContainerPermissions
containerPermission.PublicAccess = BlobContainerPublicAccessType.Blob
container.SetPermissions(containerPermission)
```

## 컨테이너에 Blob 업로드
```vbnet
''Retrieve storage account from connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))
''Create the blob client.
Dim blobClient As CloudBlobClient = storageAccount.CreateCloudBlobClient()
''Retrieve a reference to a container.
Dim container As CloudBlobContainer = blobClient.GetContainerReference("mycontainer")
''Retrieve reference to a blob named "myblob".
Dim blockBlob As CloudBlockBlob = container.GetBlockBlobReference("myblob")

''Create or overwrite the "myblob" blob with contents from a local file.
Using fileStream As FileStream = System.IO.File.OpenRead("path\myfile")
    blockBlob.UploadFromStream(fileStream)
End Using
```

## 컨테이너의 Blob 나열
```vbnet
''Retrieve storage account from connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))
''Create the blob client.
Dim blobClient As CloudBlobClient = storageAccount.CreateCloudBlobClient()
''Retrieve a reference to a container.
Dim container As CloudBlobContainer = blobClient.GetContainerReference("photos")

For Each item As IListBlobItem In container.ListBlobs(Nothing, False)

    If (TypeOf item Is CloudBlockBlob) Then

        Dim blob As CloudBlockBlob = CType(item, CloudBlockBlob)

        Console.WriteLine("Block blob of length {0}: {1}", blob.Properties.Length, blob.Uri)

    ElseIf (TypeOf item Is CloudPageBlob) Then

        Dim pageBlob As CloudPageBlob = CType(item, CloudPageBlob)

        Console.WriteLine("Block blob of length {0}: {1}", pageBlob.Properties.Length, pageBlob.Uri)

    ElseIf (TypeOf item Is CloudBlobDirectory) Then

        Dim directory As CloudBlobDirectory = CType(item, CloudBlobDirectory)

        Console.WriteLine("Directory: {0}", directory.Uri)

    End If

Next
```

## Blob 다운로드
```vbnet
''Retrieve storage account from connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))

''Create the blob client.
Dim blobClient As CloudBlobClient = storageAccount.CreateCloudBlobClient()

''Retrieve a reference to a container.
Dim container As CloudBlobContainer = blobClient.GetContainerReference("mycontainer")

''Retrieve reference to a blob named "photo1.jpg".
Dim blockBlob As CloudBlockBlob = container.GetBlockBlobReference("photo1.jpg")

''Save blob contents to a file.
Using fileStream As FileStream = System.IO.File.OpenWrite("path\myfile")
    blockBlob.DownloadToStream(fileStream)
End Using
```

```vbnet
''Retrieve storage account from connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))

''Create the blob client.
Dim blobClient As CloudBlobClient = storageAccount.CreateCloudBlobClient()

''Retrieve a reference to a container.
Dim container As CloudBlobContainer = blobClient.GetContainerReference("mycontainer")

''Retrieve reference to a blob named "myblob.txt"
Dim blockBlob2 As CloudBlockBlob = container.GetBlockBlobReference("myblob.txt")

Dim text As String
Using memoryStream As New MemoryStream

    blockBlob2.DownloadToStream(memoryStream)
    text = System.Text.Encoding.UTF8.GetString(memoryStream.ToArray())

End Using
```

## Blob 삭제
```vbnet
''Retrieve storage account from connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))

''Create the blob client.
Dim blobClient As CloudBlobClient = storageAccount.CreateCloudBlobClient()

''Retrieve a reference to a container.
Dim container As CloudBlobContainer = blobClient.GetContainerReference("mycontainer")

''Retrieve reference to a blob named "myblob.txt"
Dim blockBlob As CloudBlockBlob = container.GetBlockBlobReference("myblob.txt")

''Delete the blob.
blockBlob.Delete()
```

## 여러 페이지에서 비동기식으로 Blob 나열
```vbnet
Public Async Function ListBlobsSegmentedInFlatListing(container As CloudBlobContainer) As Task

    Console.WriteLine("List blobs in pages:")

    Dim i As Integer = 0
    Dim continuationToken As BlobContinuationToken = Nothing
    Dim resultSegment As BlobResultSegment = Nothing

    ''Call ListBlobsSegmentedAsync And enumerate the result segment returned, while the continuation token Is non-null.
    ''When the continuation token Is null, the last page has been returned And execution can exit the loop.
    Do While Not (IsNothing(continuationToken))
        ''This overload allows control of the page size. You can return all remaining results by passing null for the maxResults parameter,
        ''Or by calling a different overload.
        resultSegment = Await container.ListBlobsSegmentedAsync("", True, BlobListingDetails.All, 10, continuationToken, Nothing, Nothing)

        If (resultSegment.Results.Count > 0) Then
            Console.WriteLine("Page {0}:", ++i)
        End If

        For Each blobItem As IListBlobItem In resultSegment.Results
            Console.WriteLine("\t{0}", blobItem.StorageUri.PrimaryUri)
        Next

        Console.WriteLine()

        ''Get the continuation token.
        continuationToken = resultSegment.ContinuationToken

    Loop

End Function
```

## 추가 Blob에 쓰기
```vbnet
        ''Retrieve storage account from connection string.
        Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))

        ''Create the blob client.
        Dim blobClient As CloudBlobClient = storageAccount.CreateCloudBlobClient()

        ''Retrieve a reference to a container.
        Dim container As CloudBlobContainer = blobClient.GetContainerReference("my-append-blobs")

        ''Create the container if it doesn't already exist.
        container.CreateIfNotExists()

        ''Get a reference to an append blob.
        Dim appendBlob As CloudAppendBlob = container.GetAppendBlobReference("append-blob.log")

        ''Create the append blob. Note that if the blob already exists, the CreateOrReplace() method will overwrite it.
        ''You can check whether the blob exists to avoid overwriting it by using CloudAppendBlob.Exists().
        appendBlob.CreateOrReplace()

        Dim numBlocks As Integer = 10

        ''Generate an array of random bytes.
        Dim rnd As New Random
        Dim bytes(numBlocks) As Byte
        rnd.NextBytes(bytes)

        ''Simulate a logging operation by writing text data and byte data to the end of the append blob.
        For i As Integer = 0 To (numBlocks - 1) Step 1
            appendBlob.AppendText(String.Format("Timestamp: {0:u} \tLog Entry: {1}{2}", DateTime.UtcNow, bytes(i), Environment.NewLine))
        Next

        ''Read the append blob to the console window.
        Console.WriteLine(appendBlob.DownloadText())

    End Sub

```
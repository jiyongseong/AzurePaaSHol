Imports Microsoft.WindowsAzure.Storage
Imports Microsoft.WindowsAzure.Storage.Blob

Module Module1

    Sub Main()
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

    End Sub

End Module

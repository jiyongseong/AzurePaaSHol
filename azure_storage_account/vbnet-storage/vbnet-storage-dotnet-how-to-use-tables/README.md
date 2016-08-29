# .NET을 사용하여 Azure 테이블 저장소 시작 - vb.net

아래의 코드는 [.NET을 사용하여 Azure 테이블 저장소 시작](https://azure.microsoft.com/ko-kr/documentation/articles/storage-dotnet-how-to-use-tables/) 링크의 C# 코드를 VB.NET으로 바꾼 것입니다.

## 개발 환경 설정

### 네임스페이스 선언 추가
```vbnet
Imports Microsoft.Azure     ''Namespace for CloudConfigurationManager 
Imports Microsoft.WindowsAzure.Storage      ''Namespace for CloudStorageAccount
Imports Microsoft.WindowsAzure.Storage.Table        ''Namespace for Table storage types
```
### 테이블 만들기

```vbnet
''Retrieve the storage account from the connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))

''Create the table client.
Dim tableClient As CloudTableClient = storageAccount.CreateCloudTableClient()

''Retrieve a reference to the table.
Dim table As CloudTable = tableClient.GetTableReference("people")

''Create the table if it doesn't exist.
table.CreateIfNotExists()
```

### 테이블에 엔터티 추가


```vbnet
Public Class CustomerEntity
    Inherits TableEntity

    Public Sub New(ByVal lastName As String, ByVal firstName As String)
        Me.PartitionKey = lastName
        Me.RowKey = firstName
    End Sub

    Public Sub New()

    End Sub

    Public Property lastName As String
    Public Property firstName As String

    Public Property Email As String
    Public Property PhoneNumber As String

End Class
```

```vbnet
''Retrieve the storage account from the connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))

''Create the table client.
Dim tableClient As CloudTableClient = storageAccount.CreateCloudTableClient()

''Create the CloudTable object that represents the "people" table.
Dim table As CloudTable = tableClient.GetTableReference("people")

''Create a new customer entity.
Dim customer1 As New CustomerEntity("Harp", "Walter")
customer1.Email = "Walter@contoso.com"
customer1.PhoneNumber = "425-555-0101"

''Create the TableOperation object that inserts the customer entity.
Dim insertOperation As TableOperation = TableOperation.Insert(customer1)

''Execute the insert operation.
table.Execute(insertOperation)
```

### 엔터티 일괄 삽입

```vbnet
''Retrieve the storage account from the connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))

''Create the table client.
Dim tableClient As CloudTableClient = storageAccount.CreateCloudTableClient()

''Create the CloudTable object that represents the "people" table.
Dim table As CloudTable = tableClient.GetTableReference("people")

''Create the batch operation.
Dim batchOperation As New TableBatchOperation()

''Create a customer entity and add it to the table.
Dim customer1 As New CustomerEntity("Smith", "Jeff")
customer1.Email = "Jeff@contoso.com"
customer1.PhoneNumber = "425-555-0104"

''Create another customer entity and add it to the table.
Dim customer2 As New CustomerEntity("Smith", "Ben")
customer2.Email = "Ben@contoso.com"
customer2.PhoneNumber = "425-555-0102"

''Add both customer entities to the batch insert operation.
batchOperation.Insert(customer1)
batchOperation.Insert(customer2)

''Execute the batch operation.
table.ExecuteBatch(batchOperation)
```
 
### 파티션의 모든 엔터티 검색
```vbnet
''Retrieve the storage account from the connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))

''Create the table client.
Dim tableClient As CloudTableClient = storageAccount.CreateCloudTableClient()

''Create the CloudTable object that represents the "people" table.
Dim table As CloudTable = tableClient.GetTableReference("people")

''Construct the query operation for all customer entities where PartitionKey="Smith".
Dim query As TableQuery(Of CustomerEntity) = New TableQuery(Of CustomerEntity)
query.Where(TableQuery.GenerateFilterCondition("PartitionKey", QueryComparisons.Equal, "Smith"))

''Print the fields for each customer.
For Each entity As CustomerEntity In table.ExecuteQuery(query)
    Console.WriteLine("{0}, {1}\t{2}\t{3}", entity.PartitionKey, entity.RowKey, entity.Email, entity.PhoneNumber)
Next
```

### 파티션의 엔터티 범위 검색

```vbnet
''Retrieve the storage account from the connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))

''Create the table client.
Dim tableClient As CloudTableClient = storageAccount.CreateCloudTableClient()

''Create the CloudTable object that represents the "people" table.
Dim table As CloudTable = tableClient.GetTableReference("people")

''Create the table query.
Dim rangeQuery As TableQuery(Of CustomerEntity) = New TableQuery(Of CustomerEntity)
rangeQuery.Where(TableQuery.CombineFilters(TableQuery.GenerateFilterCondition("PartitionKey", QueryComparisons.Equal, "Smith"),
                                            TableOperators.And,
                                            TableQuery.GenerateFilterCondition("RowKey", QueryComparisons.LessThan, "E")))

''Loop through the results, displaying information about the entity.
For Each entity As CustomerEntity In table.ExecuteQuery(rangeQuery)
    Console.WriteLine("{0}, {1}\t{2}\t{3}", entity.PartitionKey, entity.RowKey, entity.Email, entity.PhoneNumber)
Next
```

### 단일 엔터티 검색

```vbnet
''Retrieve the storage account from the connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))

''Create the table client.
Dim tableClient As CloudTableClient = storageAccount.CreateCloudTableClient()

''Create the CloudTable object that represents the "people" table.
Dim table As CloudTable = tableClient.GetTableReference("people")

''Create a retrieve operation that takes a customer entity.
Dim retrieveOperation As TableOperation = TableOperation.Retrieve(Of CustomerEntity)("Smith", "Ben")

''Execute the retrieve operation.
Dim retrievedResult As TableResult = table.Execute(retrieveOperation)

''Print the phone number of the result.
If retrievedResult.Result IsNot Nothing Then
    Console.WriteLine(CType(retrievedResult.Result, CustomerEntity).PhoneNumber)
Else
    Console.WriteLine("The phone number could not be retrieved.")
End If
```

### 엔터티 바꾸기

```vbnet
''Retrieve the storage account from the connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))

''Create the table client.
Dim tableClient As CloudTableClient = storageAccount.CreateCloudTableClient()

''Create the CloudTable object that represents the "people" table.
Dim table As CloudTable = tableClient.GetTableReference("people")

''Create a retrieve operation that takes a customer entity.
Dim retrieveOperation As TableOperation = TableOperation.Retrieve(Of CustomerEntity)("Smith", "Ben")

''Execute the operation.
Dim retrievedResult As TableResult = table.Execute(retrieveOperation)

''Assign the result to a CustomerEntity object.
Dim updateEntity As CustomerEntity = CType(retrievedResult.Result, CustomerEntity)

If updateEntity IsNot Nothing Then
    ''Change the phone number.
    updateEntity.PhoneNumber = "425-555-0105"

    ''Create the Replace TableOperation.
    Dim updateOperation As TableOperation = TableOperation.Replace(updateEntity)

    ''Execute the operation.
    table.Execute(updateOperation)

    Console.WriteLine("Entity updated.")
Else
    Console.WriteLine("Entity could not be retrieved.")

End If
```

### 엔터티 삽입 또는 바꾸기

```vbnet
''Retrieve the storage account from the connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))

''Create the table client.
Dim tableClient As CloudTableClient = storageAccount.CreateCloudTableClient()

''Create the CloudTable object that represents the "people" table.
Dim table As CloudTable = tableClient.GetTableReference("people")

''Create a retrieve operation that takes a customer entity.
Dim retrieveOperation As TableOperation = TableOperation.Retrieve(Of CustomerEntity)("Smith", "Ben")

''Execute the operation.
Dim retrievedResult As TableResult = table.Execute(retrieveOperation)

''Assign the result to a CustomerEntity object.
Dim updateEntity As CustomerEntity = CType(retrievedResult.Result, CustomerEntity)

If updateEntity IsNot Nothing Then
    ''Change the phone number.
    updateEntity.PhoneNumber = "425-555-1234"

    ''Create the InsertOrReplace TableOperation.
    Dim insertOrReplaceOperation As TableOperation = TableOperation.InsertOrReplace(updateEntity)

    ''Execute the operation.
    table.Execute(insertOrReplaceOperation)

    Console.WriteLine("Entity was updated.")
Else
    Console.WriteLine("Entity could not be retrieved.")

End If
```

### 엔터티 속성 하위 집합 쿼리
```vbnet
''Retrieve the storage account from the connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))

''Create the table client.
Dim tableClient As CloudTableClient = storageAccount.CreateCloudTableClient()

''Create the CloudTable object that represents the "people" table.
Dim table As CloudTable = tableClient.GetTableReference("people")

''Define the query, and select only the Email property.
Dim projectionQuery As TableQuery(Of DynamicTableEntity) = New TableQuery(Of DynamicTableEntity)().Select(New String() {"Email"})

''Define an entity resolver to work with the entity after retrieval.
Dim resolver As EntityResolver(Of String) = Function(pk, rk, ts, props, etag) If(props.ContainsKey("Email"), props("Email").StringValue, Nothing)

For Each projectedEmail As String In table.ExecuteQuery(projectionQuery, resolver, Nothing, Nothing)
    Console.WriteLine(projectedEmail)
Next
```

### 엔터티 삭제
```vbnet
''Retrieve the storage account from the connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))

''Create the table client.
Dim tableClient As CloudTableClient = storageAccount.CreateCloudTableClient()

''Create the CloudTable object that represents the "people" table.
Dim table As CloudTable = tableClient.GetTableReference("people")

''Create a retrieve operation that takes a customer entity.
Dim retrieveOperation As TableOperation = TableOperation.Retrieve(Of CustomerEntity)("Smith", "Ben")

''Execute the operation.
Dim retrievedResult As TableResult = table.Execute(retrieveOperation)

''Assign the result to a CustomerEntity.
Dim deleteEntity As CustomerEntity = CType(retrievedResult.Result, CustomerEntity)

''Create the Delete TableOperation.
If deleteEntity Is Nothing Then
    Dim deleteOperation As TableOperation = TableOperation.Delete(deleteEntity)

    ''Execute the operation.
    table.Execute(deleteOperation)

    Console.WriteLine("Entity deleted.")
Else
    Console.WriteLine("Could not retrieve the entity.")
End If
```

### 테이블 삭제
```vbnet
''Retrieve the storage account from the connection string.
Dim storageAccount As CloudStorageAccount = CloudStorageAccount.Parse(CloudConfigurationManager.GetSetting("StorageConnectionString"))

''Create the table client.
Dim tableClient As CloudTableClient = storageAccount.CreateCloudTableClient()

''Create the CloudTable object that represents the "people" table.
Dim table As CloudTable = tableClient.GetTableReference("people")

''Delete the table it if exists.
table.DeleteIfExists()
```

### 페이지에서 엔터티를 비동기적으로 검색

```vbnet
'' Initialize a default TableQuery to retrieve all the entities in the table.
Dim tableQuery As New TableQuery(Of CustomerEntity)()

'' Initialize the continuation token to null to start from the beginning of the table.
Dim continuationToken As TableContinuationToken = Nothing

Do
'' Retrieve a segment (up to 1,000 entities).
Dim tableQueryResult As TableQuerySegment(Of CustomerEntity) = Await table.ExecuteQuerySegmentedAsync(tableQuery, continuationToken)

    '' Assign the new continuation token to tell the service where to
    '' continue on the next iteration (or null if it has reached the end).
    continuationToken = tableQueryResult.ContinuationToken

    ''Print the number of rows retrieved.

    	'' Loop until a null continuation token is received, indicating the end of the table.
    Console.WriteLine("Rows retrieved {0}", tableQueryResult.Results.Count)
Loop While continuationToken IsNot Nothing
```
# Azure Function App을 이용하여 AWS S3 파일을 Storage account로 복사하기

제목 그대로, S3 bucket에 있는 파일들을 Azure의 Storage account로 백업하고 싶다는 문의를 받았습니다.

이미 상용 솔루션도 있다는 얘기를 들었습니다만, 확인해본적은 없구요… Azure Data Factory와 같은 서비스에서 S3 connector가 만들어지면 좋겠다는 생각을 해봅니다.

아무튼.. 이런저런 생각을 하다가, Azure Function App으로 만들어보면 어떨까 하는 생각에 만들어보았습니다.

주의 : 저는 개발자가 아닙니다. 따라서, 이번 포스트에서는 이렇게 가능하다 정도의 수준에서 작성된 코드를 설명하고 있습니다. 따라서 완성된 방식으로 동작하는 코드에 대해서는 전문 개발자와 상담하십쇼.

먼저, Azure 포털(http://portal.azure.com)을 열고..

[새로 만들기] > 검색 창에 “Function App”(따옴표는 빼구요)이라고 입력하고..

![Function App](https://jiyongseong.files.wordpress.com/2016/06/image.png)

엔터….를 누르면, 마켓플레이스가 열리면서 다음과 같이 Function App이 첫번째 줄에 나타납니다.

![Function App](https://jiyongseong.files.wordpress.com/2016/06/image1.png)

[Function App]을 선택하고, Function App 블레이드가 나타나면, [만들기] 버튼을 클릭합니다.

![Function App](https://jiyongseong.files.wordpress.com/2016/06/image2.png)

관련 정보들을 입력하고, Function App을 만듭니다.

![Function App](https://jiyongseong.files.wordpress.com/2016/06/image3.png)

[만들기] 버튼을 누르면, 다음과 같이 짧은 시간 이내에 Function App이 만들어집니다.

![Function App](https://jiyongseong.files.wordpress.com/2016/06/image4.png)

새로 Function App이 만들어지면, 다음과 같은 화면이 나타나게 됩니다. 여기서 하단에 있는 [create your own custom function]을 클릭합니다.

![Function App](https://jiyongseong.files.wordpress.com/2016/06/image5.png)

다음에는 사용할 템플릿을 선택하게 되는데요. 여기서 저는 ManualTrigger를 선택할 겁니다. 저는 테스트 용도로 개발을 할 것이기 때문이죠. 주기적으로 실행을 시키고 싶으신 분은 TimerTrigger를 사용하시면 되겠죠. 다양한 템플릿들에서 제공되는 트리거와 바인딩에 대해서도 살펴보시기 바랍니다.

하단에 함수 이름을 입력하시고(저는 S3toAzure라고 지었습니다), [Create] 버튼을 클릭합니다.

![Function App](https://jiyongseong.files.wordpress.com/2016/06/image6.png)

이제, C# 코드를 입력할 수 있는 창이 보여집니다. 코드를 작성하기 전에, 환경 구성부터 필요합니다. 코드 작성에 필요한 패키지들을 설치할 필요가 있겠죠.

화면 중앙에 있는 [View files] 버튼을 클릭합니다.

![Function App](https://jiyongseong.files.wordpress.com/2016/06/image7.png)

짠, 다음과 같이 Function app을 구성하는 파일들이 보여집니다. 1) 하단에 있는 더하기 버튼을 누르고, 2) project.json 이라는 파일을 만듭니다.


![Function App](https://jiyongseong.files.wordpress.com/2016/06/image8.png)

project.json 파일을 열고, 다음의 내용을 입력하고, [Save] 버튼을 누릅니다.

```JSON
{
  "frameworks": {
    "net46":{
        "dependencies": {
    "WindowsAzure.Storage": "7.0.0",
    "AWSSDK.Core": "3.2.0-beta",
    "AWSSDK.S3": "3.2.0-beta"
  }
    }
  }
}
 ```

![Function App](https://jiyongseong.files.wordpress.com/2016/06/image9.png)

[Save] 버튼을 누르면, [Code] 창 아래에 있는 [Logs] 창에는 설치 과정에 대한 로그가 보여지게 됩니다. 오류가 발생되거나, 진행 상황 등을 확인할 수 있는 부분입니다.

![Function App](https://jiyongseong.files.wordpress.com/2016/06/image10.png)

Copy & Paste를 잘 하셨다면, 다음과 같은 로그가 마지막에 보여집니다.

![Function App](https://jiyongseong.files.wordpress.com/2016/06/image11.png)

이제는 [Code] 창에서 run.csx 파일을 열고, 다음의 코드를 복사하여 넣기를 합니다. 마지막에 [Save] 버튼 누르기도 잊지 마세요.

```C#
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
```

위의 코드는 수정이 필요한 부분이 있습니다. 수정이 필요한 부분은 노란색으로 하이라이트를 해두었습니다.

수정이 필요한 변수들은 다음과 같습니다.

먼저, 원본인 AWS의 S3에 대한 정보를 다음과 같이 입력해주어야 합니다.

```
string awsAccessKey = "AKIAIZDK5LW3X5ZAUWZQ";
string awsSecretKey = "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";
string awsBucketName = "jyseongbucket";
```
awsAccessKey는 Access Key ID를, awsSecretKey는 Secret Access Key를 입력해주시면 됩니다.

다음의 awsBucketName은 복사하려는 원본이 되는 Bucket의 이름으로 변경을 하면 됩니다.

위에 사용된 Access Key ID와 Secret Access  Key는 글을 올리는 시점에서는 이미 삭제하였습니다. 물론 Bucket도 삭제되었습니다. 

다음은, 복사의 대상이 되는 Azure Storage Account의 정보를 입력해주어야 합니다.

storageAccountName은 저장소 계정의 이름을, storageAccountKey는 저장소 계정의 액세스 키(1번 또는 2번 중에 하나)를 입력해주어야 합니다.

마지막으로, containerName은 복사하려는 대상 컨테이너의 이름을 입력해주어야 합니다(주의 : 해당 컨테이너는 미리 생성되어 있어야 합니다.).

```
string storageAccountName = "usingdockerstorage";
string storageAccountKey = "cNhRboSgBzzkPXkllcYs9n36/RHdmp+mJzMA+1COePsiLskxUZMHx5SJFLDKaL0yvF6GEb6pMGUq0L5Evt+dlQ==";
string containerName = "s3container";
```

![Function App](https://jiyongseong.files.wordpress.com/2016/06/image12.png)

[Save] 버튼을 누르면, 코드가 컴파일 됩니다. 이 과정에서 컴파일에 대한 로그는 [Logs] 창에 보여지게 됩니다.

![Function App](https://jiyongseong.files.wordpress.com/2016/06/image13.png)

여기까지 문제 없이 진행이 되었고, 컴파일이 완료되었다면… 실행을 해보도록 하죠

화면 하단에 있는 [Run] 창의 [Run] 버튼을 클릭합니다.

![Function App](https://jiyongseong.files.wordpress.com/2016/06/image14.png)

진행되는 과정 중에 로그로 기록된 내용 및 오류들이 [Logs] 창에 보여지게 됩니다.

정상적으로 작업이 완료되면, AWS의 S3에 있던 blob 파일들이 Azure의 Storage account로 복사가 이루어지게 됩니다.

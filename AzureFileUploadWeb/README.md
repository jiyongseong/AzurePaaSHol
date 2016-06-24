## Azure 파일 업로드 예제

* 웹 서버(IaaS, PaaS)로 파일 업로드 시, 파일을 Azure Storage로 저장하는 예제.
* 예제는 ASP.NET MVC로 작성됨(다른 언어 사용 시 하단의 참고문서를 참고하기 바람)
* MVC에서 그리드는 Grid.MVC를 활용: [Grid.MVC 링크](https://gridmvc.codeplex.com/)
* 웹 페이지를 통해서 업로드 되는 파일은 스트림 그대로 Azure Storage로 전송되도록 구현
* 예제 소스는 이해하기 쉽도록 동기(Sync) 메서드를 사용하여 구현하였음.

> **구현 시 참고할만한 문서**
>- [.NET로 개발 시에 참고문서](https://azure.microsoft.com/en-us/documentation/articles/storage-dotnet-how-to-use-blobs/)
>- [Java로 개발 시에 참고문서](https://azure.microsoft.com/en-us/documentation/articles/storage-java-how-to-use-blob-storage/)
>- [PHP로 개발 시에 참고문서](https://azure.microsoft.com/en-us/documentation/articles/storage-php-how-to-use-blobs/)
>- [Node.js로 개발 시에 참고문서](https://azure.microsoft.com/en-us/documentation/articles/storage-nodejs-how-to-use-blob-storage/)
>- [Python으로 개발 시에 참고문서](https://azure.microsoft.com/en-us/documentation/articles/storage-python-how-to-use-blob-storage/)


>**구현 시 고려한 사항**
>- 모든 파일은 Azure Blob Storage의 특정 컨테이너에 저장한다.
>- Azure Blob Storage의 특정 컨테이너는 읽기 전용으로 설정해야 한다.
>- 사용자가 웹 서버로 업로드하는 파일은 스트림 그대로 Azure Storage 쪽에 저장해야 한다.
>- 사용자가 파일 내역을 조회하고자 하는 경우에는 웹 서버는 파일 목록과 해당 파일로의 직접적인 하이퍼링크를 제공한다
>	- 웹 서버가 파일 다운로드를 중계하는 방식은 권장하지 않는다(메모리 낭비 및 CDN 적용 불가)
>- 사용자는 개별 파일에 대해서는 Azure Blob에 직접 접근하여 다운로드를 수행한다.


```
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
```

### 실행에 앞서 설정해야 할 사항들
- 여러분의 Azure Blob Storage에 파일 업로드/다운로드용 컨테이너를 하나 만들고 [액세스 형식]으로 [Blob]를 지정한다.

    ![실행화면](https://github.com/jiyongseong/AzurePaaSHol/blob/master/AzureFileUploadWeb/images/azureStorageUpload2.png?raw=true)

- Web.config 파일에 1)저장소 계정의 이름과 2)액세스 키와 3)대상 컨테이너 명을 입력한다.
```
    <!-- 저장서 계정 관련 설정 부분 -->
    <add key="ContainerName" value="<컨테이너 명>" />
    <add key="StorageConnectionString" value="DefaultEndpointsProtocol=https;AccountName=<저장소 계정 이름>;AccountKey=<저장소 계정 액세스 키>" />
```
### 실행 화면
  ![실행화면](https://github.com/jiyongseong/AzurePaaSHol/blob/master/AzureFileUploadWeb/images/azureStorageUpload.png?raw=true)

만일 웹서버와 Azure 저장소 간에 보안적인 부분도 고려해야 한다면, 웹서버와 Azure Storage의 통신 간에 SAS([Shared Access Signatures](https://azure.microsoft.com/ko-kr/documentation/articles/storage-dotnet-shared-access-signature-part-1/))를 적용하는 방안을 고려하기 바람.
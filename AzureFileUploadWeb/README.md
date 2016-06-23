## ASP.NET MVC로 파일 업로드하면 Azure Storage로 저장하는 예제
MVC에서 그리드는 Grid.MVC를 활용: [Grid.MVC 링크](https://gridmvc.codeplex.com/)

웹 페이지를 통해서 업로드 되는 파일은 스트림 그대로 Azure Storage로 전송되도록 구현
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
- Web.config 파일에 1)저장소 계정의 이름과 2)액세스 키와 3)대상 컨테이너 명을 입력한다.
```
	<!-- 저장서 계정 관련 설정 부분 -->
    <add key="ContainerName" value="<컨테이너 명>" />
    <add key="StorageConnectionString" value="DefaultEndpointsProtocol=https;AccountName=<저장소 계정 이름>;AccountKey=<저장소 계정 액세스 키>" />
```
### 실행 화면
  ![실행화면](https://github.com/jiyongseong/AzurePaaSHol/blob/master/AzureFileUploadWeb/images/azureStorageUpload.png?raw=true)

만일 웹서버와 Azure 저장소 간에 보안적인 부분도 고려해야 한다면, 웹서버에서 Azure Storage로 파일 저장하는 부분에 SAS([Shared Access Signatures](https://azure.microsoft.com/ko-kr/documentation/articles/storage-dotnet-shared-access-signature-part-1/))를 적용하는 방안을 고려하기 바람.
## ASP.NET MVC로 파일 업로드하면 Azure Storage로 저장하는 예제
MVC에서 그리드는 Grid.MVC를 활용: [Grid.MVC 링크](https://gridmvc.codeplex.com/)

웹 페이지를 통해서 업로드 되는 파일은 스트림 그대로 Azure Storage로 전송되도록 구현

### 실행에 앞서 설정해야 할 사항들
- Web.config 파일에 1)저장소 계정의 이름과 2)액세스 키와 3)대상 컨테이너 명을 입력한다.
```
	<!-- 저장서 계정 관련 설정 부분 -->
    <add key="ContainerName" value="<컨테이너 명>" />
    <add key="StorageConnectionString" value="DefaultEndpointsProtocol=https;AccountName=<저장소 계정 이름>;AccountKey=<저장소 계정 액세스 키>" />
```
### 실행 화면
  ![실행화면](https://github.com/jiyongseong/AzurePaaSHol/blob/master/AzureFileUploadWeb/images/azureStorageUpload.png?raw=true)


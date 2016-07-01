# Azure PaaS Hands on Lab

Micorosoft Azure에서 제공되는 PaaS(Platform as a Service) 서비스들에 대한 Hands on Lab을 제공합니다.

### [Azure 파일 업로드 예제](https://github.com/jiyongseong/AzurePaaSHol/tree/master/AzureFileUploadWeb)
- 기본 예제는 ASP.NET MVC 기본 파일 업로드 방식으로 작성됨
  - ASP.NET MVC에서 그리드는 Grid.MVC를 활용
- 추가 예제는 jQuery.Form을 활용한 HTML/Javascript 파일 업로드 방식으로 작성
  - 그리드는 Knockout을 활용하여 MVVM 으로 구현(Json 바인딩)
  - 서버 측은 Java나 Php 등으로 구현해도 무방함(예에서는 서버로 ASP.NET을 활용함)
- 웹 페이지 혹은 스크립트를 통해서 업로드 되는 파일은 스트림 그대로 Azure Storage로 전송되도록 구현
- 예제 소스는 이해하기 쉽도록 동기(Sync) 메서드를 사용하여 구현하였음

### [Azure Function App을 이용하여 AWS S3 파일을 Storage account로 복사하기](https://github.com/jiyongseong/AzurePaaSHol/tree/master/copy-awss3-to-azure-storageaccount-using-functionapp)

- Azure의 App service 중에 하나인, Function app을 이용하여 AWS S3에 있는 파일들을 Azure의 Storage account로 복사하는 방법을 설명하고 있습니다.

### [Azure Resource Group 간에 Resource 옮기기](https://github.com/jiyongseong/AzurePaaSHol/tree/master/moving-resources-between-azure-resource-groups)

- Azure PowerShell을 이용하여, 특정 Resource Group에 있는 모든 리소스들을 다른 Resource Group으로 이동시키는 방법을 설명하고 있습니다.

김태영(taeyo), 성지용(jiyongseong)

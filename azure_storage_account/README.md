# Azure Storage Account useful resources

Micorosoft Azure Storage Account와 관련된 유용한 정보와 쿼리/코드들을 제공합니다.

* [Azure 파일 업로드 예제 (C#)](https://github.com/jiyongseong/AzurePaaSHol/tree/master/azure_storage_account/AzureFileUploadWeb) by taeyo
    * ASP.NET MVC에서 그리드는 Grid.MVC를 활용
    * 추가 예제는 jQuery.Form을 활용한 HTML/Javascript 파일 업로드 방식으로 작성
    * 그리드는 Knockout을 활용하여 MVVM 으로 구현(Json 바인딩)
    * 서버 측은 Java나 Php 등으로 구현해도 무방함(예에서는 서버로 ASP.NET을 활용함)
    * 웹 페이지 혹은 스크립트를 통해서 업로드 되는 파일은 스트림 그대로 Azure Storage로 전송되도록 구현
    * 예제 소스는 이해하기 쉽도록 동기(Sync) 메서드를 사용하여 구현하였음

**성지용([jiyongseong](https://github.com/jiyongseong))**

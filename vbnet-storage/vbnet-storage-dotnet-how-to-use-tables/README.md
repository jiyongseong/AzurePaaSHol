# .NET을 사용하여 Azure 테이블 저장소 시작 - vb.net

아래의 코드는 [.NET을 사용하여 Azure 테이블 저장소 시작](https://azure.microsoft.com/ko-kr/documentation/articles/storage-dotnet-how-to-use-tables/) 링크의 C# 코드를 VB.NET으로 바꾼 것입니다.

## 개발 환경 설정

### 네임스페이스 선언 추가
```vbnet
Imports Microsoft.Azure     ''Namespace for CloudConfigurationManager 
Imports Microsoft.WindowsAzure.Storage      ''Namespace for CloudStorageAccount
Imports Microsoft.WindowsAzure.Storage.Table        ''Namespace for Table storage types
```

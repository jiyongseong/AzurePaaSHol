# 전통적인 시스템 개체들

**Database context : master database / user database**

SQL Server 2000 시절에 많이 사용되던 시스템 개체들이 있었는데요...

개인적으로는 master..sysprocesses와 sp_who2라는 시스템 저장 프로시저일 것입니다.

이런 전통적인 시스템 개체들도 Azure SQL Database에서 지원을 하네요.

```SQL
exec sp_who2;
GO

SELECT * FROM sysprocesses;
GO

```

특이한 점은 사용자 데이터베이스에서도 sysprocesses라고만 명시를 하여도 쿼리가 가능하다는 점입니다.
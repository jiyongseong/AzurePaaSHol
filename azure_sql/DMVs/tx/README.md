# 활성 트랜잭션 정보

**Database context : user database**

현재 실행 중인 트랜잭션의 정보를 반환하는 쿼리는 다음과 같습니다.

아래의 DMV/DMF들이 사용되었습니다.

- [sys.dm_tran_session_transactions](https://msdn.microsoft.com/en-us/library/ms188739.aspx)
- [sys.dm_tran_active_transactions](https://msdn.microsoft.com/en-us/library/ms174302.aspx)

```SQL
select st.session_id, at.transaction_id, at.name, datediff(ms, at.transaction_begin_time, getdate()) AS tx_duration_ms, at.transaction_begin_time, 
			CASE at.transaction_type 
					WHEN 1 THEN 'read/write'
					WHEN 2 THEN 'read-only'
					WHEN 3 THEN 'system'
					WHEN 4 THEN 'distributed'
			END AS transaction_type_desc,
			CASE at.transaction_state
				WHEN 0 THEN 'not completely initialized yet'
				WHEN 1 THEN 'initialized but has not started'
				WHEN 2 THEN 'active'
				WHEN 3 THEN 'ended, used for read-only transactions'
				WHEN 4 THEN 'commit process has been initiated on the distributed transaction'
				WHEN 5 THEN 'in a prepared state and waiting resolution'
				WHEN 6 THEN 'committed'
				WHEN 7 THEN 'being rolled back'
				WHEN 8 THEN 'been rolled back'
			END AS transaction_state_desc,
			CASE at.dtc_state
				WHEN 1 THEN 'ACTIVE'
				WHEN 2 THEN 'PREPARED'
				WHEN 3 THEN 'COMMITTED'
				WHEN 4 THEN 'ABORTED'
				WHEN 5 THEN 'RECOVERED'
			END AS dtc_state_desc
FROM sys.dm_tran_session_transactions AS st INNER JOIN sys.dm_tran_active_transactions AS at ON st.transaction_id = at.transaction_id	
WHERE st.is_user_transaction = 1;
GO
```
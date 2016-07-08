--session 2
BEGIN TRAN

	UPDATE DeadlockTest 
	SET id = 11
	WHERE id = 1

	WAITFOR DELAY '00:00:05'

	UPDATE DeadlockTest 
	SET id = 12
	WHERE id = 2
ROLLBACK
GO
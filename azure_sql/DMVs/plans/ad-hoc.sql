SELECT t.text AS sqlText, p.refcounts, p.usecounts, p.size_in_bytes
FROM sys.dm_exec_cached_plans AS p CROSS APPLY sys.dm_exec_sql_text(p.plan_handle) AS t
WHERE p.usecounts = 1 AND p.cacheobjtype = 'Compiled Plan' AND p.objtype = 'Adhoc';
GO

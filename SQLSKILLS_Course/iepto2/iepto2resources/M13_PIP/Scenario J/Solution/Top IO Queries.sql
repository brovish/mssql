SELECT  q.[query_hash],
        SUBSTRING(t.text, (q.[statement_start_offset] / 2) + 1,
                  ((CASE q.[statement_end_offset]
                      WHEN -1 THEN DATALENGTH(t.[text])
                      ELSE q.[statement_end_offset]
                    END - q.[statement_start_offset]) / 2) + 1),
        SUM(q.[total_physical_reads]) AS [total_physical_reads]
FROM    sys.[dm_exec_query_stats] AS q
CROSS APPLY sys.[dm_exec_sql_text](q.sql_handle) AS t
GROUP BY q.[query_hash],
        SUBSTRING(t.text, (q.[statement_start_offset] / 2) + 1,
                  ((CASE q.[statement_end_offset]
                      WHEN -1 THEN DATALENGTH(t.[text])
                      ELSE q.[statement_end_offset]
                    END - q.[statement_start_offset]) / 2) + 1)
ORDER BY SUM(q.[total_physical_reads]) DESC;
GO
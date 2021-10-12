CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM" (
   ticker_symbol varchar(4), 
   avg_change double);
CREATE OR REPLACE PUMP "STREAM_PUMP" AS INSERT INTO "DESTINATION_SQL_STREAM"
SELECT STREAM ticker_symbol, avg_change
FROM (
    SELECT STREAM
        ticker_symbol, 
        AVG(change) OVER W1 as avg_change
    FROM "SOURCE_SQL_STREAM_001"
    WINDOW W1 AS (PARTITION BY ticker_symbol RANGE INTERVAL '10' SECOND PRECEDING)
)
WHERE ABS(avg_change) > 1;

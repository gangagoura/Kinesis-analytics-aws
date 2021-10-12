-- ** Multi-step application **
-- Use parallel / serial processing steps.
-- Intermediate, in-application streams are useful for building multi-step applications.
 
--          .----------.   .------.   .------.   .----------.              
--          |  SOURCE  |   |IN-   |   |IN-   |   |  DESTIN. |              
-- Source-->|  STREAM  |-->|APP   |-->|APP   |-->|  STREAM  |-->Destination
--          |          |   |STREAM|   |STREAM|   |          |              
--          '----------'   '------'   '------'   '----------'               
-- STREAM (in-application): a continuously updated entity that you can SELECT from and INSERT into like a TABLE
-- PUMP: an entity used to continuously 'SELECT ... FROM' a source STREAM, and INSERT SQL results into an output STREAM
 
-- First in-app stream and pump
CREATE OR REPLACE STREAM "IN_APP_STREAM_001" (
   ingest_time   TIMESTAMP,
   ticker_symbol VARCHAR(4),
   sector        VARCHAR(16),
   price         REAL,
   change        REAL);
 
CREATE OR REPLACE PUMP "STREAM_PUMP_001" AS INSERT INTO "IN_APP_STREAM_001"
SELECT STREAM  APPROXIMATE_ARRIVAL_TIME, ticker_symbol, sector, price, change
FROM "SOURCE_SQL_STREAM_001";
 
-- Second in-app stream and pump
CREATE OR REPLACE STREAM "IN_APP_STREAM_02" (
   ingest_time   TIMESTAMP,
   ticker_symbol VARCHAR(4),
   sector        VARCHAR(16),
   price         REAL,
   change        REAL);
 
CREATE OR REPLACE PUMP "STREAM_PUMP_02" AS INSERT INTO "IN_APP_STREAM_02"
SELECT STREAM  ingest_time, ticker_symbol, sector, price, change
FROM "IN_APP_STREAM_001"; 
-- Destination in-app stream and third pump
CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM" (
   ingest_time   TIMESTAMP,
   ticker_symbol VARCHAR(4),
   sector        VARCHAR(16),
   price         REAL,
   change        REAL);
 
CREATE OR REPLACE PUMP "STREAM_PUMP_03" AS INSERT INTO "DESTINATION_SQL_STREAM"
SELECT STREAM  ingest_time, ticker_symbol, sector, price, change
FROM "IN_APP_STREAM_02";

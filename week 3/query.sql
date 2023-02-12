-- 1) What is the count for fhv vehicle records for year 2019?
WITH pickup_fhv_2019 as(
  SELECT date(pickup_datetime) FROM `fhv_2019.fhv_tripdata_2019-01`
  UNION ALL
  SELECT date(pickup_datetime) FROM `fhv_2019.fhv_tripdata_2019-02`
  UNION ALL
  SELECT date(pickup_datetime) FROM `fhv_2019.fhv_tripdata_2019-03`
  UNION ALL
  SELECT date(pickup_datetime) FROM `fhv_2019.fhv_tripdata_2019-04`
  UNION ALL
  SELECT date(pickup_datetime) FROM `fhv_2019.fhv_tripdata_2019-05`
  UNION ALL
  SELECT date(pickup_datetime) FROM `fhv_2019.fhv_tripdata_2019-06`
  UNION ALL
  SELECT date(pickup_datetime) FROM `fhv_2019.fhv_tripdata_2019-07`
  UNION ALL
  SELECT date(pickup_datetime) FROM `fhv_2019.fhv_tripdata_2019-08`
  UNION ALL
  SELECT date(pickup_datetime) FROM `fhv_2019.fhv_tripdata_2019-09`
  UNION ALL
  SELECT date(pickup_datetime) FROM `fhv_2019.fhv_tripdata_2019-10`
  UNION ALL
  SELECT date(pickup_datetime) FROM `fhv_2019.fhv_tripdata_2019-11`
  UNION ALL
  SELECT date(pickup_datetime) FROM `fhv_2019.fhv_tripdata_2019-12`
)

SELECT count(1) count_fhv_2019 FROM pickup_fhv_2019;

-- 2) Write a query to count the distinct number of affiliated_base_number for the entire dataset on both the tables.
-- What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?
WITH all_fhv_2019 as(
  SELECT 
    dispatching_base_num, 
    pickup_datetime, 
    dropOff_datetime, 
    PUlocationID, 
    DOlocationid, 
    cast(SR_Flag as string) SR_Flag, 
    Affiliated_base_number
      FROM `fhv_2019.fhv_tripdata_2019-01`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-02`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-03`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-04`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-05`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-06`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-07`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-08`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-09`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-10`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-11`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-12`
)

SELECT distinct count(Affiliated_base_number) cnt_aff FROM all_fhv_2019;

CREATE or replace TABLE fhv_2019.fhv_2019_full AS
  SELECT 
    dispatching_base_num, 
    pickup_datetime, 
    dropOff_datetime, 
    PUlocationID, 
    DOlocationid, 
    cast(SR_Flag as string) SR_Flag, 
    Affiliated_base_number
      FROM `fhv_2019.fhv_tripdata_2019-01`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-02`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-03`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-04`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-05`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-06`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-07`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-08`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-09`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-10`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-11`
  UNION ALL
  SELECT * FROM `fhv_2019.fhv_tripdata_2019-12`

SELECT distinct count(Affiliated_base_number) cnt_aff FROM fhv_2019_full;

-- 3) How many records have both a blank (null) PUlocationID and DOlocationID in the entire dataset?
SELECT COUNT(1) cnt_null_loc_id
FROM `fhv_2019.fhv_2019_full`
WHERE 
  PUlocationId is NULL 
  AND 
  DOlocationid is NULL

-- 5) Implement the optimized solution you chose for question 4. Write a query to retrieve the distinct affiliated_base_number between pickup_datetime 2019/03/01 and 2019/03/31 (inclusive).
-- Use the BQ table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 4 and note the estimated bytes processed. What are these values? Choose the answer which most closely matches.
SELECT DISTINCT Affiliated_base_number
FROM `fhv_2019.fhv_2019_full`
WHERE 
  pickup_datetime 
  BETWEEN 
    '2019-03-01 00:00:00' 
  AND 
    '2019-03-31 00:00:00'

CREATE OR REPLACE TABLE 
    fhv_2019.fhv_2019_partitioned
PARTITION BY date(pickup_datetime)
CLUSTER BY Affiliated_base_number
    AS
SELECT * FROM fhv_2019.fhv_2019_full

SELECT DISTINCT Affiliated_base_number
FROM `fhv_2019.fhv_2019_partitioned`
WHERE 
  pickup_datetime 
  BETWEEN 
    '2019-03-01 00:00:00' 
  AND 
    '2019-03-31 00:00:00'
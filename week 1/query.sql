create table taxi_zones (
    locationid int, 
    borough varchar, 
    zone varchar, 
    servicezone varchar
);

create table green_trips (
    vendorid int, 
    lpep_pickup_datetime timestamp, 
    lpep_dropoff_datetime timestamp,
    store_fwd varchar, 
    rate_code int, 
    puloc int, doloc int, 
    pass_count float,
    trip_distance float,
    fare_amount float,
    extra float,
    mta_tax float,
    tip_amount float,
    tolls_amount float,
    ehail_fee float,
    improvement_surcharge float,
    total_amount float,
    payment_type int,
    trip_type int,
    congestion_surcharge float
);

COPY green_trips
FROM '/etc/postgresql/green_tripdata_2019-01.csv'
DELIMITER ','
CSV HEADER;

COPY taxi_zones
FROM '/etc/postgresql/taxi+_zone_lookup.csv'
DELIMITER ','
CSV HEADER;

SELECT count (1) AS total_trips
FROM green_trips 
WHERE lpep_pickup_datetime >= '2019-01-15 00:00:00' 
    AND lpep_pickup_datetime < '2019-01-16 00:00:00' 
    AND lpep_dropoff_datetime >= '2019-01-15 00:00:00' 
    AND lpep_dropoff_datetime < '2019-01-16 00:00:00';

SELECT cast(lpep_pickup_datetime as date), MAX(trip_distance) as total_trip
    FROM green_trips
    WHERE lpep_pickup_datetime >= '2019-01-01' AND lpep_pickup_datetime < '2019-02-01'
    GROUP BY 1
    ORDER BY 2 desc;

select count(1) from green_trips
where pass_count = 3 
    and cast(lpep_pickup_datetime as date)='2019-01-01';

with gpbmax as (
    select doloc, max(tip_amount) as largest_tip 
    from green_trips 
        where puloc=7 
        group by 1 
        order by 2 desc
    )
select * from gpbmax 
    left join taxi_zones 
    on doloc=locationid 
    order by 2 desc limit 5;
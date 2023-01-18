wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-01.csv.gz
wget https://s3.amazonaws.com/nyc-tlc/misc/taxi+_zone_lookup.csv
gzip -dk green_tripdata_2019-01.csv.gz

docker build --help
docker run -it python:3.9 bash
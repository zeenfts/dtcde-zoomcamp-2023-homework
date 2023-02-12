[Homework Question](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2023/week_3_data_warehouse/homework.md)

# How to Ingest Data:
1. Open cloud shell on GCP (50 hours usage limit/week).
2. mkdir ~/mybucket on the shell.
3. gcsfuse <YOUR_BUCKET_NAME> ~/mybucket on the shell.
4. CD to ~/mybucket.
5. Then download + Extract the Files.
```
for a in 1 2 3 4 5 6 7 8 9; do wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/fhv/fhv_tripdata_2019-0$a.csv.gz; done
for a in 10 11 12; do wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/fhv/fhv_tripdata_2019-$a.csv.gz; done

for g in *.gz; do gunzip -dk $g; done
```
6. Create External Table (+Dataset)
```
bq --location=us-west1 mk -d \
    --default_table_expiration 3600 \
    --description "Dataset for FHV 2019 Trip Data." \
    fhv_2019

for j in 1 2 3 4 5 6 7 8 9;
do
bq mkdef --source_format=CSV --autodetect=true \
  gs://<GCP_BUCKET_NAME>/fhv_tripdata_2019-0$j.csv > mytable_def
done

for j in 1 2 3 4 5 6 7 8 9;
do
bq mk --table --external_table_definition=mytable_def \
  fhv_2019.fhv_tripdata_2019-0$j
done

for j in 10 11 12;
do
bq mkdef --source_format=CSV --autodetect=true \
  gs://<GCP_BUCKET_NAME>/fhv_tripdata_2019-$j.csv > mytable_def2
done

for j in 10 11 12;
do
bq mk --table --external_table_definition=mytable_def2 \
  fhv_2019.fhv_tripdata_2019-$j
done
```
7. Finish the Homework! -> [Query the Table on BigQuery](https://github.com/zeenfts/dtcde-zoomcamp-2023-homework/blob/main/week%203/query.sql)
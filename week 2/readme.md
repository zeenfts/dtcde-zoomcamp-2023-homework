[Homework Questions](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2023/week_2_workflow_orchestration/homework.md)

## Info:
1. `docker compose up` in this directory (on 1<sup>st</sup> terminal).
2. `docker exec -it prefect-app bash` on other (2<sup>nd</sup>) terminal.
3. Then on the 2<sup>nd</sup> terminal (already inside the **prefect-app** container): 
```
prefect block register -m prefect_gcp
python blocks/make_gcp_blocks.py
python flows/etl_web_to_gcs.py
prefect deployment build flows/etl_web_to_gcs.py:etl_web_to_gcs -n dezoomgreen -q test
prefect deployment set-schedule apply etl_web_to_gcs-deployment.yaml
prefect deployment set-schedule --cron "0 5 1 * *" etl-web-to-gcs/dezoomgreen
```
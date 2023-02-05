[Homework Questions](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/cohorts/2023/week_2_workflow_orchestration/homework.md)

## Info:
1. `docker compose up` in this directory (on 1<sup>st</sup> terminal).
2. `docker exec -it prefect-app bash` on other (2<sup>nd</sup>) terminal.
3. Then on the 2<sup>nd</sup> terminal (already inside the **prefect-app** container): <br>
* Extract dataset to GCS.
```
prefect block register -m prefect_gcp
python blocks/make_gcp_blocks.py
python flows/etl_web_to_gcs.py
```
* Deploy Prefect's Flow to Local Storage.
```
prefect deployment build flows/etl_web_to_gcs.py:etl_web_to_gcs -n dezoomgreen -q test
prefect deployment apply etl_web_to_gcs-deployment.yaml
prefect deployment set-schedule --cron "0 5 1 * *" etl-web-to-gcs/dezoomgreen
```
* Ingest data to BigQuery.
```
python flows/etl_gcs_to_bq.py
```
* Deploy Flow to Github Repository.
```
prefect block register -m prefect_github
python blocks/make_github_blocks.py
prefect deployment build flows/github/web_to_gcs.py:web_to_gcs -n gitzoomgreen --tag dev -sb github/zoom-github -a
prefect agent start -q 'default'
prefect deployment run web-to-gcs/gitzoomgreen -> on different terminal.
```
4. Open up the Prefect UI at [http://127.0.0.1:4200](http://127.0.0.1:4200).
5. Good Job! <br>
_**<sub><sup>* note: If you stop the container & re-start it, don't forget to do "prefect orion start --host 0.0.0.0" again for the first time!</sup></sub>**_
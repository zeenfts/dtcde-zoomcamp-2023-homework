from pathlib import Path
import re
import pandas as pd
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from random import randint


@task(retries=3)
def fetch(dataset_url: str) -> pd.DataFrame:
    """Read taxi data from web into pandas DataFrame"""
    # if randint(0, 1) > 0:
    #     raise Exception

    df = pd.read_csv(dataset_url)
    return df


@task(log_prints=True)
def clean(df: pd.DataFrame, color: str) -> pd.DataFrame:
    """Fix dtype issues"""
    pick_dt, drop_dt = '', ''
    if color == 'green':
        pick_dt = "lpep_pickup_datetime"
        drop_dt = "lpep_dropoff_datetime"
    elif color == 'yellow':
        pick_dt = "tpep_pickup_datetime"
        drop_dt = "tpep_dropoff_datetime"

    df[pick_dt] = pd.to_datetime(df[pick_dt])
    df[drop_dt] = pd.to_datetime(df[drop_dt])

    print(df.head(2))
    print(f"columns: {df.dtypes}")
    print(f"rows: {len(df)}")
    return df


@task()
def write_local(df: pd.DataFrame, color: str, dataset_file: str) -> Path:
    """Write DataFrame out locally as parquet file"""
    path = Path(f"/opt/prefect/data/{color}/{dataset_file}.parquet")
    df.to_parquet(path, compression="gzip")
    return path


@task()
def write_gcs(path: Path) -> None:
    """Upload local parquet file to GCS"""
    path_target = str(re.search('(green.+|yellow.+)', str(path)).group(1))
    gcs_block = GcsBucket.load("zoom-gcs")
    gcs_block.upload_from_path(from_path=path, to_path= path_target)
    return


@flow()
def web_to_gcs() -> None:
    """The main ETL function"""
    color = "green"
    year = 2020
    month = 11

    year = 2019
    month = 4

    dataset_file = f"{color}_tripdata_{year}-{month:02}"
    dataset_url = f"https://github.com/DataTalksClub/nyc-tlc-data/releases/download/{color}/{dataset_file}.csv.gz"

    df = fetch(dataset_url)
    df_clean = clean(df, color)
    path = write_local(df_clean, color, dataset_file)
    write_gcs(path)


if __name__ == "__main__":
    web_to_gcs()
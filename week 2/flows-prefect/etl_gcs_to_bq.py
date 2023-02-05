import os
from pathlib import Path
import pandas as pd
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from prefect_gcp import GcpCredentials


@task(retries=3)
def extract_from_gcs(color: str, year: int, month: int) -> Path:
    """Download trip data from GCS"""
    gcs_path = f"{color}/{color}_tripdata_{year}-{month:02}.parquet"
    main_data_path = "/opt/prefect/data/"
    data_path = os.listdir(main_data_path)

    if gcs_path in data_path:
        local_path = None
    else:
        local_path = main_data_path

    gcs_block = GcsBucket.load('zoom-gcs')
    gcs_block.get_directory(from_path=gcs_path, local_path=local_path)
    return Path(f"{main_data_path}{gcs_path}")


@task()
def load_parquet(path: Path) -> pd.DataFrame:
    """Data cleaning example"""
    df = pd.read_parquet(path)
    # print(f"pre: missing passenger count: {df['passenger_count'].isna().sum()}")
    # df["passenger_count"].fillna(0, inplace=True)
    # print(f"post: missing passenger count: {df['passenger_count'].isna().sum()}")

    # print(f"pre: out of bond datetime count: {df['passenger_count'].isna().sum()}")
    # df = df[df["tpep_pickup_datetime"] >= '2019-03-01 00:00:00' and df.loc["tpep_pickup_datetime"] < '2019-04-01 00:00:00']
    # print(f"post: out of bond datetime count: {df['passenger_count'].isna().sum()}")
    return df


@task()
def write_bq(df: pd.DataFrame) -> None:
    """Write DataFrame to BiqQuery"""

    gcp_credentials_block = GcpCredentials.load("zoom-gcp-creds")

    df.to_gbq(
        destination_table="yellow_trips.dezoom23",
        project_id="fellowship-8",
        credentials=gcp_credentials_block.get_credentials_from_service_account(),
        chunksize=500_000,
        if_exists="append",
    )


@flow(log_prints=True)
def etl_gcs_to_bq():
    """Main ETL flow to load data into Big Query"""
    color = "yellow"
    year = 2019
    month = (2, 3)
    rows = 0

    for mth in month:
        path = extract_from_gcs(color, year, mth)
        df = load_parquet(path)
        rows = rows + len(df)
        write_bq(df)

    print(df.head(2))
    print(f"columns: {df.dtypes}")
    print(f"rows: {rows}")


if __name__ == "__main__":
    etl_gcs_to_bq()
import json
from prefect_gcp import GcpCredentials
from prefect_gcp.cloud_storage import GcsBucket

# alternative to creating GCP blocks in the UI
# insert your own service_account_file path or service_account_info dictionary from the json file
# IMPORTANT - do not store credentials in a publicly available repository!

# JSON file
f = open ('/root/.google/creds.json', "r")
  
# Reading from file
creds_data = json.loads(f.read())

credentials_block = GcpCredentials(
    service_account_info=creds_data
)
credentials_block.save("zoom-gcp-creds", overwrite=True)


bucket_block = GcsBucket(
    gcp_credentials=GcpCredentials.load("zoom-gcp-creds"),
    bucket="dezoomcamp-2023_fellowship-8",  # CHANGE TO YOUR GCS (BUCKET) NAME!
)

bucket_block.save("zoom-gcs", overwrite=True)

# Closing file
f.close()
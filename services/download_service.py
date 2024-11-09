import http.client
#import os
import ssl
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient
from services import azSettings, settings

class DownloadService:
    def __init__(self):
        pass

    def download_report(self):
        # Implement the logic to download the report using the report_id
        # Create an unverified SSL context
        context = ssl._create_unverified_context()
        
        # Azure Blob Storage connection string and container name
        connection_string = azSettings.azure_storage_connection_string
        container_name = settings.azure_storage_container_name
        blob_name = settings.blob_name

        conn = http.client.HTTPSConnection("340bopais.hrsa.gov", context=context)

        payload = settings.payload
        headers = settings.headers

        conn.request("POST", "/reports?AspxAutoDetectCookieSupport=1", payload, headers)
        res = conn.getresponse()

        # Check if the response is successful and content type is Excel
        if res.status == 200 and res.getheader('Content-Type').startswith('application/vnd'):
            print("Starting file download...")

            # Read data from the response
            data = res.read()

            # Create a BlobServiceClient object
            blob_service_client = BlobServiceClient.from_connection_string(connection_string)

            # Get a container client
            container_client = blob_service_client.get_container_client(container_name)

            # Upload the file to the container
            blob_client = container_client.get_blob_client(blob_name)
            blob_client.upload_blob(data, overwrite=True)    
            print("File uploaded to Azure Blob Container successfully.")
        else:
            print(f"Failed to download file: {res.status} {res.reason}")  

        # Close the connection
        conn.close()                  
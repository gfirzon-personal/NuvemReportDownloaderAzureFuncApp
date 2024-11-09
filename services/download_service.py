#import http.client
#import os
import ssl
from azure.storage.blob import BlobServiceClient, BlobClient, ContainerClient
# import settings
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
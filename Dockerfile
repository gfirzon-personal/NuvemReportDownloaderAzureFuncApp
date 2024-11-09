# Use the official Azure Functions Python base image
FROM mcr.microsoft.com/azure-functions/python:4-python3.11

# Set the working directory inside the container
WORKDIR /home/site/wwwroot

# Copy the requirements.txt file and install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy the rest of your function app code
COPY . .

# Set the environment variables for Azure Functions
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

# Expose the port for the Functions runtime
EXPOSE 80

# Start the Azure Functions host
#CMD ["func", "host", "start", "--verbose"]

# Use the built-in runtime host command instead of "func host start"
# CMD ["python", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost"]

# Use the default entry point of the Azure Functions runtime (no CMD needed)
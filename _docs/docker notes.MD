```sh
docker build -t my-azure-function .
```

```sh
docker run -p 7071:80 -it my-azure-function
```

curl http://localhost:8080/api/http_trigger_download_report?name=YourName
http://localhost:7071/api/http_trigger_download_report?name=YourName